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
  final LaplacianBlurResult blurResult;
  final WienerDeconvolutionResult wienerResult;
  final ClaheResult claheResult;
  final YoloDetectionResult yoloResult;
  final RbfSvmResult svmResult;
  final AdvisoryDiagnosisResult advisoryResult;
  final int totalExecutionTimeMs;

  const PipelineExecutionResult({
    required this.blurResult,
    required this.wienerResult,
    required this.claheResult,
    required this.yoloResult,
    required this.svmResult,
    required this.advisoryResult,
    required this.totalExecutionTimeMs,
  });

  List<YoloBoundingBox> get detectedBoundingBoxes => yoloResult.boundingBoxes;
  double get finalConfidence => advisoryResult.confidenceScore;
  ConfidenceTier get confidenceTier => advisoryResult.confidenceTier;
}

/// Orchestrator for the HydroSage Visual Diagnostic Pipeline:
///
/// [Mobile Canopy Image] ──> [Variance of Laplacian (Blur Check)]
///                                       │
///                              [Wiener Deconvolution] (If Blurry)
///                                       │
///                              [CLAHE Contrast Equalization]
///                                       │
///                              [YOLOv11s-ECA Feature Extraction]
///                                       │
///                              [RBF-SVM Condition Classifier]
///                                       │
///                              [Advisory Disease Diagnosis]
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
  /// Notifies [onStepProgress] at each stage for smooth UI progress rendering.
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
    await Future.delayed(const Duration(milliseconds: 150));

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
    await Future.delayed(const Duration(milliseconds: 150));

    // Stage 3: CLAHE Contrast Equalization
    onStepProgress?.call('CLAHE Contrast Equalization (Balancing Grow Lighting)...', 0.55);
    final claheResult = await clahe.processImage(imageFile);
    await Future.delayed(const Duration(milliseconds: 150));

    // Stage 4: YOLOv11s-ECA Feature Extraction
    onStepProgress?.call('YOLOv11s-ECA Feature Extraction (Canopy & Lesion Localization)...', 0.75);
    final yoloResult = await yolo.detectFoliage(
      imageFile: imageFile,
      isBlurry: blurResult.isBlurry,
      contrastRatio: claheResult.dynamicRangeExpansion,
    );
    await Future.delayed(const Duration(milliseconds: 150));

    // Stage 5: RBF-SVM Condition Classifier
    onStepProgress?.call('RBF-SVM Condition Classifier (Hyperplane Assessment)...', 0.90);
    final svmResult = rbfSvm.classify(
      featureVector: yoloResult.extractedFeatureVector,
      baseConfidence: yoloResult.overallConfidence,
    );
    await Future.delayed(const Duration(milliseconds: 100));

    // Stage 6: Advisory Disease Diagnosis
    onStepProgress?.call('Advisory Disease Diagnosis (Synthesizing Nutrition & Pathogen Care)...', 1.0);
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

    return PipelineExecutionResult(
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

