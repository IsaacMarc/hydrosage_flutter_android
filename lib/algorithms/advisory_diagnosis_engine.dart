import '../models/crop_forecast_models.dart';
import 'variance_of_laplacian.dart';
import 'wiener_deconvolution.dart';
import 'clahe_equalization.dart';
import 'yolov11_eca_detector.dart';
import 'rbf_svm_classifier.dart';

/// Confidence tiers for agronomic decision support
enum ConfidenceTier {
  high,
  moderate,
  low,
}

extension ConfidenceTierExtension on ConfidenceTier {
  String get label {
    switch (this) {
      case ConfidenceTier.high:
        return 'High Certainty';
      case ConfidenceTier.moderate:
        return 'Moderate Certainty';
      case ConfidenceTier.low:
        return 'Low Confidence (Caution)';
    }
  }

  String get guidance {
    switch (this) {
      case ConfidenceTier.high:
        return 'Diagnosis verified with high statistical certainty. Recommended agronomic actions are safe to apply directly.';
      case ConfidenceTier.moderate:
        return 'Acceptable detection accuracy. Verify symptoms with manual canopy inspection before major nutrient adjustments.';
      case ConfidenceTier.low:
        return 'Low diagnostic confidence. Retake canopy photo under steady uniform lighting at 15-20cm distance with focused leaves.';
    }
  }
}

/// Final synthesized advisory disease diagnosis result.
class AdvisoryDiagnosisResult {
  final int overallHealthScore;
  final String healthGrade;
  final double confidenceScore;
  final ConfidenceTier confidenceTier;
  final String botanicalAssessment;
  final String agronomicRecommendation;
  final double chlorosisPercentage;
  final double necrosisPercentage;
  final double coveragePercentage;
  final double tipburnRiskPercentage;
  final String status;
  final List<String> actionItems;
  final PlantConditionCategory conditionCategory;
  final bool isDiseasedDetected;
  final bool hasFoliageDetected;
  final FoliarDetectionClass? primaryDetectedClass;
  final String detectedCropLabel;

  const AdvisoryDiagnosisResult({
    required this.overallHealthScore,
    required this.healthGrade,
    required this.confidenceScore,
    required this.confidenceTier,
    required this.botanicalAssessment,
    required this.agronomicRecommendation,
    required this.chlorosisPercentage,
    required this.necrosisPercentage,
    required this.coveragePercentage,
    required this.tipburnRiskPercentage,
    required this.status,
    required this.actionItems,
    required this.conditionCategory,
    required this.isDiseasedDetected,
    required this.hasFoliageDetected,
    required this.primaryDetectedClass,
    required this.detectedCropLabel,
  });

  /// Factory helper when Stage 1 aborts (no valid leaf detected)
  factory AdvisoryDiagnosisResult.error({required String message}) {
    return AdvisoryDiagnosisResult(
      overallHealthScore: 0,
      healthGrade: 'Error',
      confidenceScore: 0.0,
      confidenceTier: ConfidenceTier.low,
      botanicalAssessment: message,
      agronomicRecommendation:
          'Re-align camera directly over crop leaves and ensure adequate lighting.',
      chlorosisPercentage: 0.0,
      necrosisPercentage: 0.0,
      coveragePercentage: 0.0,
      tipburnRiskPercentage: 0.0,
      status: 'error',
      actionItems: const [
        'Center the crop leaf within the camera frame.',
        'Ensure the leaf occupies at least 5% of the total camera viewfinder.',
      ],
      conditionCategory: PlantConditionCategory.optimal,
      isDiseasedDetected: false,
      hasFoliageDetected: false,
      primaryDetectedClass: null,
      detectedCropLabel: 'No Leaf Detected',
    );
  }

  /// Factory helper when Stage 2 rejects (max probability < 0.60)
  factory AdvisoryDiagnosisResult.uncertain({
    required String message,
    required double confidence,
  }) {
    return AdvisoryDiagnosisResult(
      overallHealthScore: 0,
      healthGrade: 'Uncertain',
      confidenceScore: confidence,
      confidenceTier: ConfidenceTier.low,
      botanicalAssessment: message,
      agronomicRecommendation:
          'Low confidence match. Non-plant or unclassifiable leaf state detected. Please verify target crop.',
      chlorosisPercentage: 0.0,
      necrosisPercentage: 0.0,
      coveragePercentage: 0.0,
      tipburnRiskPercentage: 0.0,
      status: 'uncertain',
      actionItems: const [
        'Ensure the camera is focused on a supported crop (Bok Choy, Lettuce, or Spinach).',
        'Avoid capturing non-plant objects, grow sponge cubes, or hydroponic PVC gutters.',
        'Clean lens and steady the device to eliminate motion blur.',
      ],
      conditionCategory: PlantConditionCategory.optimal,
      isDiseasedDetected: false,
      hasFoliageDetected: true,
      primaryDetectedClass: null,
      detectedCropLabel: 'Uncertain State',
    );
  }

  /// Factory helper when confidence is not above 80%
  factory AdvisoryDiagnosisResult.lowConfidence({
    required double confidence,
    String message = 'Low confidence detection. Retake canopy photo.',
  }) {
    return AdvisoryDiagnosisResult(
      overallHealthScore: 0,
      healthGrade: 'Low Confidence',
      confidenceScore: confidence,
      confidenceTier: ConfidenceTier.low,
      botanicalAssessment: 'Low confidence detected.',
      agronomicRecommendation: message,
      chlorosisPercentage: 0.0,
      necrosisPercentage: 0.0,
      coveragePercentage: 0.0,
      tipburnRiskPercentage: 0.0,
      status: 'low_confidence',
      actionItems: const [
        'Retake canopy photo at 15-20cm distance with steady focus.',
        'Ensure uniform lighting across the canopy without glare or harsh shadows.',
      ],
      conditionCategory: PlantConditionCategory.optimal,
      isDiseasedDetected: false,
      hasFoliageDetected: true,
      primaryDetectedClass: null,
      detectedCropLabel: 'Low Confidence',
    );
  }

  DiagnosticResult toDiagnosticResult() {
    return DiagnosticResult(
      overallHealthScore: overallHealthScore,
      healthGrade: healthGrade,
      confidenceScore: confidenceScore,
      botanicalAssessment: botanicalAssessment,
      chlorosisPercentage: chlorosisPercentage,
      necrosisPercentage: necrosisPercentage,
      coveragePercentage: coveragePercentage,
      tipburnRiskPercentage: tipburnRiskPercentage,
      agronomicRecommendation: agronomicRecommendation,
      status: status,
    );
  }
}

/// [Advisory Disease Diagnosis]
/// Synthesizes prototype YOLOv11 detections + RBF-SVM classification + environmental telemetry.
class AdvisoryDiagnosisEngine {
  const AdvisoryDiagnosisEngine();

  AdvisoryDiagnosisResult generateDiagnosis({
    required CropVariety variety,
    required String tray,
    required int growthDay,
    required double currentEc,
    required double currentPh,
    required double vpd,
    required LaplacianBlurResult blurResult,
    required WienerDeconvolutionResult wienerResult,
    required ClaheResult claheResult,
    required YoloDetectionResult yoloResult,
    required RbfSvmResult svmResult,
  }) {
    final bool hasFoliage = yoloResult.hasValidLeaf;

    // Use actual detector confidence directly
    final double actualConfidence =
        hasFoliage ? yoloResult.overallConfidence : 20.0;

    // Strict Confidence Gate: If confidence is not above 80%, do not output model detection result
    if (!hasFoliage || actualConfidence <= 80.0) {
      return AdvisoryDiagnosisResult.lowConfidence(confidence: actualConfidence);
    }

    final ConfidenceTier tier = actualConfidence >= 88.0
        ? ConfidenceTier.high
        : ConfidenceTier.moderate;

    final FoliarDetectionClass? primaryClass = yoloResult.primaryDetectedClass;
    final bool isBokChoy = primaryClass?.cropFamily == 'Bok Choy' ||
        primaryClass == FoliarDetectionClass.bokchoy ||
        primaryClass == FoliarDetectionClass.bokChoyDiseased;

    // Bok Choy 85% Gate: If Bok Choy has confidence < 85%, label as non-leaf or random object
    if (isBokChoy && actualConfidence < 85.0) {
      return AdvisoryDiagnosisResult.lowConfidence(
        confidence: actualConfidence,
        message: 'Non-leaf or random object detected. Retake canopy photo.',
      );
    }

    // Ground Truth from YOLO model detection classes:
    // Healthy classes: bokchoy (1), lettuce (2), spinach (4) -> isDiseased = false
    // Diseased classes: Bok-Choy-Diseased (0), Lettuce-Diseased (3), Spinach-Diseased (5) -> isDiseased = true
    final bool isDiseased = primaryClass != null
        ? primaryClass.isDiseased
        : yoloResult.hasDiseasedDetection;

    final PlantConditionCategory condition = isDiseased
        ? PlantConditionCategory.diseased
        : (svmResult.predictedCategory == PlantConditionCategory.borderlineStress
            ? PlantConditionCategory.borderlineStress
            : PlantConditionCategory.optimal);

    final String cropName = primaryClass?.cropFamily ?? variety.displayName;
    final String cropLabel = primaryClass != null
        ? primaryClass.label
        : (isDiseased ? '$cropName (Diseased)' : '$cropName (Healthy)');

    final int healthScore;
    final String healthGrade;
    final String statusString;

    if (!hasFoliage) {
      healthScore = 0;
      healthGrade = 'No Plant';
      statusString = 'unrecognized';
    } else if (isDiseased) {
      final int deduction = ((yoloResult.measuredChlorosis * 2.0) +
              (yoloResult.measuredNecrosis * 3.5))
          .round();
      healthScore = (72 - deduction).clamp(38, 70);
      healthGrade = 'Grade C (Alert)';
      statusString = 'diseased';
    } else if (condition == PlantConditionCategory.borderlineStress) {
      healthScore =
          (85 - (yoloResult.measuredChlorosis * 1.5)).round().clamp(75, 87);
      healthGrade = 'Grade B';
      statusString = 'warning';
    } else {
      // Optimal / Healthy leaf
      healthScore =
          (90 + (yoloResult.measuredGreenness * 0.08)).round().clamp(88, 99);
      healthGrade = 'Grade A+';
      statusString = 'optimal';
    }

    final double tipburnCalc =
        ((yoloResult.measuredNecrosis * 1.8) + (vpd > 1.2 ? 3.0 : 0.8))
            .clamp(0.5, 15.0);

    final (assessment, recommendation, actions) = _buildAgronomicAdvice(
      cropName: cropName,
      variety: variety,
      condition: condition,
      isDiseased: isDiseased,
      hasFoliage: hasFoliage,
      currentEc: currentEc,
      currentPh: currentPh,
      vpd: vpd,
      growthDay: growthDay,
      tier: tier,
      confidence: actualConfidence,
    );

    return AdvisoryDiagnosisResult(
      overallHealthScore: healthScore,
      healthGrade: healthGrade,
      confidenceScore: actualConfidence,
      confidenceTier: tier,
      botanicalAssessment: assessment,
      agronomicRecommendation: recommendation,
      chlorosisPercentage:
          double.parse(yoloResult.measuredChlorosis.toStringAsFixed(1)),
      necrosisPercentage:
          double.parse(yoloResult.measuredNecrosis.toStringAsFixed(1)),
      coveragePercentage:
          double.parse(yoloResult.measuredCoverage.toStringAsFixed(0)),
      tipburnRiskPercentage: double.parse(tipburnCalc.toStringAsFixed(1)),
      status: statusString,
      actionItems: actions,
      conditionCategory: condition,
      isDiseasedDetected: isDiseased,
      hasFoliageDetected: hasFoliage,
      primaryDetectedClass: primaryClass,
      detectedCropLabel: cropLabel,
    );
  }

  (String, String, List<String>) _buildAgronomicAdvice({
    required String cropName,
    required CropVariety variety,
    required PlantConditionCategory condition,
    required bool isDiseased,
    required bool hasFoliage,
    required double currentEc,
    required double currentPh,
    required double vpd,
    required int growthDay,
    required ConfidenceTier tier,
    required double confidence,
  }) {
    if (!hasFoliage) {
      return (
        'No recognizable crop foliage detected in the captured image. The image appears to show background surfaces, empty channels, or extreme glare.',
        'Please position the phone camera directly over the hydroponic canopy at a distance of 15-20cm and recapture.',
        [
          'Center the leaf canopy within the viewfinder.',
          'Ensure adequate ambient lighting without blinding LED glare.',
        ]
      );
    }

    if (tier == ConfidenceTier.low) {
      return (
        'Low diagnostic certainty (${confidence.toStringAsFixed(1)}%). Optical blur or uneven lighting prevents confident classification of $cropName foliage.',
        'Caution: Do not alter nutrient dosing based on this scan alone. Retake canopy photo under steady uniform lighting.',
        [
          'Hold phone steady perpendicular to canopy at 15-20cm distance.',
          'Verify grow light doesn\'t cast extreme shadows.',
          'Inspect leaf margins manually for physical signs of browning or curling.',
        ]
      );
    }

    if (isDiseased) {
      return (
        'Foliar disease or tissue stress detected on $cropName canopy. (Prototype Model: Flags general diseased foliage; specific pathogen classification pending secondary inspection).',
        'Initiate foliar triage: Check NFT gutter root zone and maintain solution at EC ${variety.defaultEc} mS/cm and pH ${variety.defaultPh}. Isolate affected crops if lesions expand.',
        [
          'Inspect leaf undersides and apical growth for fungal spores, powdery film, or necrotic edges.',
          'Verify root health in NFT channel (check for discoloration or root rot).',
          'Ensure canopy humidity remains below 70% with active air circulation fans.',
          'Sanitize pruning tools before working on neighboring NFT trays.',
        ]
      );
    }

    if (condition == PlantConditionCategory.borderlineStress) {
      return (
        'Canopy exhibits slight foliar stress or minor color variation. Foliage is largely viable but showing early deviation from baseline.',
        'Monitor tray conditions closely. Verify solution pH (Target: ${variety.defaultPh}) and ensure EC has not drifted above ${variety.defaultEc}.',
        [
          'Test reservoir EC & pH calibration.',
          'Verify dissolved oxygen levels (DO > 6.0 mg/L) in nutrient stream.',
          'Re-scan in 48 hours to track foliar canopy development.',
        ]
      );
    }

    // Healthy
    return (
      'Healthy, vigorous $cropName foliage with uniform cellular structure and clean leaf margins. Zero diseased foliar zones detected.',
      'Maintain current cultivation regime (Target EC ${variety.defaultEc} mS/cm, pH ${variety.defaultPh}). Foliage is developing normally toward harvest.',
      [
        'Continue scheduled NFT recirculation cycle.',
        'Maintain ambient VPD within the 0.8 - 1.1 kPa optimal growth band.',
      ]
    );
  }
}
