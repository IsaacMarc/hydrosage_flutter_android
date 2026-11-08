import 'dart:io';
import '../models/crop_forecast_models.dart';
import 'variance_of_laplacian.dart';
import 'wiener_deconvolution.dart';
import 'clahe_equalization.dart';
import 'yolov11_eca_detector.dart';
import 'rbf_svm_classifier.dart';
import 'advisory_diagnosis_engine.dart';

export 'variance_of_laplacian.dart';
export 'wiener_deconvolution.dart';
export 'clahe_equalization.dart';
export 'yolov11_eca_detector.dart';
export 'rbf_svm_classifier.dart';
export 'advisory_diagnosis_engine.dart';

/// Comprehensive execution result returned by the Visual Diagnostic Pipeline.
class PipelineExecutionResult {
  /// Execution status: "ok", "error", or "uncertain"
  final String status;

  /// Explanatory message from pipeline validation
  final String message;

  final LaplacianBlurResult blurResult;
  final WienerDeconvolutionResult wienerResult;
  final ClaheResult claheResult;
  final YoloDetectionResult yoloResult;
  final RbfSvmResult svmResult;
  final AdvisoryDiagnosisResult advisoryResult;
  final int totalExecutionTimeMs;

  const PipelineExecutionResult({
    required this.status,
    required this.message,
    required this.blurResult,
    required this.wienerResult,
    required this.claheResult,
    required this.yoloResult,
    required this.svmResult,
    required this.advisoryResult,
    required this.totalExecutionTimeMs,
  });

  bool get isError => status == 'error';
  bool get isUncertain => status == 'uncertain';
  bool get isLowConfidence => status == 'low_confidence' || finalConfidence <= 80.0;
  bool get isSuccess => status == 'ok' && finalConfidence > 80.0;

  /// Bounding boxes are only exposed when confidence is strictly above 80%
  List<YoloBoundingBox> get detectedBoundingBoxes =>
      (isSuccess && finalConfidence > 80.0) ? yoloResult.boundingBoxes : const [];
  double get finalConfidence => advisoryResult.confidenceScore;
  ConfidenceTier get confidenceTier => advisoryResult.confidenceTier;

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}

/// Orchestrator for the Leafify Visual Diagnostic Pipeline:
///
/// [Mobile Canopy Image] ──> [Variance of Laplacian (Blur Check)]
///                                       │
///                              [Wiener Deconvolution] (If Blurry)
///                                       │
///                              [CLAHE Contrast Equalization]
///                                       │
///                              [YOLOv11s-ECA Feature Extraction]
///                                 └─> [Stage 1: Conf >= 0.30 & Area >= 5% Validation]
///                                       │
///                              [RBF-SVM Condition Classifier]
///                                 └─> [Stage 2: Softmax Proba >= 0.60 Validation]
///                                       │
///                              [Advisory Disease Diagnosis]
///
/// Post-Processing Parameters:
/// - conf=0.30: Discards faint or phantom YOLO detections below 30% confidence.
/// - min_area_ratio=0.05: Rejects tiny noise, background gravel, or distant leaves (< 5% frame).
/// - svm_proba_threshold=0.60: Rejects ambiguous/non-plant embeddings with < 60% probability.
class VisualDiagnosticPipeline {
  final VarianceOfLaplacian laplacian;
  final WienerDeconvolution wiener;
  final ClaheEqualization clahe;
  final YoloV11EcaDetector yolo;
  final RbfSvmClassifier rbfSvm;
  final AdvisoryDiagnosisEngine advisory;

  VisualDiagnosticPipeline({
    VarianceOfLaplacian? laplacian,
    WienerDeconvolution? wiener,
    ClaheEqualization? clahe,
    YoloV11EcaDetector? yolo,
    RbfSvmClassifier? rbfSvm,
    AdvisoryDiagnosisEngine? advisory,
  })  : laplacian = laplacian ?? const VarianceOfLaplacian(),
        wiener = wiener ?? const WienerDeconvolution(),
        clahe = clahe ?? const ClaheEqualization(),
        yolo = yolo ?? const YoloV11EcaDetector(),
        rbfSvm = rbfSvm ?? const RbfSvmClassifier(),
        advisory = advisory ?? const AdvisoryDiagnosisEngine();

  /// Runs the full end-to-end computer vision and agronomic diagnosis pipeline.
  Future<PipelineExecutionResult> execute({
    required File imageFile,
    required CropVariety variety,
    required String tray,
    required int growthDay,
    required double currentEc,
    required double currentPh,
    required double vpd,
    void Function(String stepDescription, double progressFraction)? onStepProgress,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Stage 1: Variance of Laplacian (Blur Check)
    onStepProgress?.call('Variance of Laplacian (Blur Check)...', 0.15);
    final blurResult = await laplacian.analyzeImage(imageFile);
    await Future.delayed(const Duration(milliseconds: 120));

    // Stage 2: Wiener Deconvolution (If Blurry)
    onStepProgress?.call(
      blurResult.isBlurry
          ? 'Wiener Deconvolution (Restoring Motion/Defocus Blur)...'
          : 'Wiener Deconvolution (Bypassed: Sharp Canopy)...',
      0.35,
    );
    final wienerResult = await wiener.processImage(
      imageFile: imageFile,
      isBlurry: blurResult.isBlurry,
      initialSharpness: blurResult.sharpnessScore,
    );
    await Future.delayed(const Duration(milliseconds: 120));

    // Stage 3: CLAHE Contrast Equalization
    onStepProgress?.call('CLAHE Contrast Equalization (Balancing Lighting)...', 0.50);
    final claheResult = await clahe.processImage(imageFile);
    await Future.delayed(const Duration(milliseconds: 120));

    // Stage 4: YOLOv11s-ECA Feature Extraction & Two-Stage Size/Confidence Validation
    onStepProgress?.call('YOLOv11s-ECA Localization & Filter Check...', 0.70);
    final yoloResult = await yolo.detectFoliage(
      imageFile: imageFile,
      isBlurry: blurResult.isBlurry,
      contrastRatio: claheResult.dynamicRangeExpansion,
      defaultCropHint: variety.displayName,
    );
    await Future.delayed(const Duration(milliseconds: 120));

    // -------------------------------------------------------------------------
    // CHECKPOINT 1: Two-Stage Confidence & Size Validation
    // Primary threshold: conf < 0.30
    // Minimum area filter: (box_width * box_height) / total_image_area < 0.05
    // -------------------------------------------------------------------------
    if (yoloResult.status == 'error' || !yoloResult.hasValidLeaf) {
      stopwatch.stop();
      final errorMsg = yoloResult.message.isNotEmpty
          ? yoloResult.message
          : 'No valid leaf detected in frame. Please re-align your crop.';

      // Abort the pipeline immediately
      return PipelineExecutionResult(
        status: 'error',
        message: errorMsg,
        blurResult: blurResult,
        wienerResult: wienerResult,
        claheResult: claheResult,
        yoloResult: yoloResult,
        svmResult: RbfSvmResult.uncertain(
          message: errorMsg,
          maxProbability: 0.0,
          classProbabilities: const {},
          gamma: rbfSvm.gamma,
        ),
        advisoryResult: AdvisoryDiagnosisResult.error(
          message: errorMsg,
        ),
        totalExecutionTimeMs: stopwatch.elapsedMilliseconds,
      );
    }

    // Stage 5: RBF-SVM Condition Classifier Head
    onStepProgress?.call('RBF-SVM Condition Classifier (predict_proba)...', 0.85);
    final svmResult = rbfSvm.classify(
      featureVector: yoloResult.extractedFeatureVector,
      baseConfidence: yoloResult.overallConfidence,
      hasDiseasedYoloDetection: yoloResult.hasDiseasedDetection,
    );
    await Future.delayed(const Duration(milliseconds: 80));

    // -------------------------------------------------------------------------
    // CHECKPOINT 2: Softmax Probability Rejection Threshold (svm_proba_threshold=0.60)
    // If max(probabilities) < 0.60, override class label and reject
    // -------------------------------------------------------------------------
    if (svmResult.status == 'uncertain' || svmResult.isUncertain) {
      stopwatch.stop();
      return PipelineExecutionResult(
        status: 'uncertain',
        message: 'Low confidence match. Non-plant or unclassifiable leaf state detected.',
        blurResult: blurResult,
        wienerResult: wienerResult,
        claheResult: claheResult,
        yoloResult: yoloResult,
        svmResult: svmResult,
        advisoryResult: AdvisoryDiagnosisResult.uncertain(
          message: 'Low confidence match. Non-plant or unclassifiable leaf state detected.',
          confidence: svmResult.confidenceScore,
        ),
        totalExecutionTimeMs: stopwatch.elapsedMilliseconds,
      );
    }

    // Stage 6: Advisory Disease Diagnosis (Only reached when both validations pass)
    onStepProgress?.call('Advisory Disease Diagnosis...', 1.0);
    final advisoryResult = advisory.generateDiagnosis(
      variety: variety,
      tray: tray,
      growthDay: growthDay,
      currentEc: currentEc,
      currentPh: currentPh,
      vpd: vpd,
      blurResult: blurResult,
      wienerResult: wienerResult,
      claheResult: claheResult,
      yoloResult: yoloResult,
      svmResult: svmResult,
    );

    stopwatch.stop();

    // Checkpoint 3: Strict 80% Confidence Gate
    // When confidence level is not above 80%, do not show model detection result.
    if (advisoryResult.status == 'low_confidence' || advisoryResult.confidenceScore <= 80.0) {
      return PipelineExecutionResult(
        status: 'low_confidence',
        message: 'Low confidence detection. Retake canopy photo.',
        blurResult: blurResult,
        wienerResult: wienerResult,
        claheResult: claheResult,
        yoloResult: yoloResult,
        svmResult: svmResult,
        advisoryResult: AdvisoryDiagnosisResult.lowConfidence(
          confidence: advisoryResult.confidenceScore,
        ),
        totalExecutionTimeMs: stopwatch.elapsedMilliseconds,
      );
    }

    return PipelineExecutionResult(
      status: 'ok',
      message: 'Canopy foliar diagnosis verified.',
      blurResult: blurResult,
      wienerResult: wienerResult,
      claheResult: claheResult,
      yoloResult: yoloResult,
      svmResult: svmResult,
      advisoryResult: advisoryResult,
      totalExecutionTimeMs: stopwatch.elapsedMilliseconds,
    );
  }
}
