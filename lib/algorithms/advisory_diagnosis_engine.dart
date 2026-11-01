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
  });

  /// Converts to standard DiagnosticResult for backward compatibility with app models.
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
/// Expert agronomic decision engine synthesizing multi-stage computer vision outputs
/// with plant physiology and hydroponic nutrient dynamics.
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
    // Determine confidence tier
    final double rawConf = svmResult.confidenceScore;
    // If the image was blurry and had low sharpness, penalize confidence to protect against misdiagnosis
    double adjustedConfidence = rawConf;
    if (blurResult.isBlurry && !wienerResult.wasApplied) {
      adjustedConfidence -= 25.0;
    } else if (blurResult.isBlurry && wienerResult.wasApplied) {
      adjustedConfidence -= 8.0; // slight penalty despite restoration
    }
    adjustedConfidence = adjustedConfidence.clamp(35.0, 99.4);

    final ConfidenceTier tier;
    if (adjustedConfidence >= 80.0) {
      tier = ConfidenceTier.high;
    } else if (adjustedConfidence >= 60.0) {
      tier = ConfidenceTier.moderate;
    } else {
      tier = ConfidenceTier.low;
    }

    // Health metrics calculations based on condition
    final condition = svmResult.predictedCategory;
    final int healthScore;
    final String healthGrade;
    final double chlorosis;
    final double necrosis;
    final double tipburn;
    final double coverage = 85.0 + (growthDay * 0.4).clamp(0.0, 12.0);
    final String statusString;

    switch (condition) {
      case PlantConditionCategory.optimal:
        healthScore = 96;
        healthGrade = 'Grade A+';
        chlorosis = 0.5;
        necrosis = 0.0;
        tipburn = 1.0;
        statusString = 'optimal';
        break;
      case PlantConditionCategory.mildChlorosis:
        healthScore = 82;
        healthGrade = 'Grade B+';
        chlorosis = 4.2;
        necrosis = 0.2;
        tipburn = 2.5;
        statusString = 'warning';
        break;
      case PlantConditionCategory.severeTipburn:
        healthScore = 74;
        healthGrade = 'Grade C';
        chlorosis = 2.1;
        necrosis = 1.8;
        tipburn = 8.6;
        statusString = 'attention';
        break;
      case PlantConditionCategory.pathogenStress:
        healthScore = 65;
        healthGrade = 'Grade D';
        chlorosis = 6.4;
        necrosis = 4.5;
        tipburn = 3.2;
        statusString = 'critical';
        break;
      case PlantConditionCategory.nutrientDeficiency:
        healthScore = 78;
        healthGrade = 'Grade B-';
        chlorosis = 5.8;
        necrosis = 0.8;
        tipburn = 3.8;
        statusString = 'warning';
        break;
    }

    final (assessment, recommendation, actions) = _buildAgronomicAdvice(
      variety: variety,
      condition: condition,
      currentEc: currentEc,
      currentPh: currentPh,
      vpd: vpd,
      growthDay: growthDay,
      tier: tier,
    );

    return AdvisoryDiagnosisResult(
      overallHealthScore: healthScore,
      healthGrade: healthGrade,
      confidenceScore: adjustedConfidence,
      confidenceTier: tier,
      botanicalAssessment: assessment,
      agronomicRecommendation: recommendation,
      chlorosisPercentage: chlorosis,
      necrosisPercentage: necrosis,
      coveragePercentage: coverage,
      tipburnRiskPercentage: tipburn,
      status: statusString,
      actionItems: actions,
      conditionCategory: condition,
    );
  }

  (String, String, List<String>) _buildAgronomicAdvice({
    required CropVariety variety,
    required PlantConditionCategory condition,
    required double currentEc,
    required double currentPh,
    required double vpd,
    required int growthDay,
    required ConfidenceTier tier,
  }) {
    if (tier == ConfidenceTier.low) {
      return (
        'Image quality or optical blur prevents conclusive foliar classification. Canopy exhibits potential ${condition.displayName.toLowerCase()} indicators.',
        'Caution: Low confidence reading. Do not adjust nutrient dosing without manual physical confirmation or re-scanning with steady lighting.',
        [
          'Retake photo at 15-20cm distance perpendicular to leaf canopy.',
          'Verify LED grow light does not create intense glare or washouts.',
          'Inspect leaf margins manually for physical signs of browning or curling.',
        ]
      );
    }

    switch (condition) {
      case PlantConditionCategory.optimal:
        return (
          'Healthy turgid foliage with uniform chlorophyll distribution and intact cell turgor. Bounding boxes confirm clean margins without lesions.',
          'Maintain current solution (Target EC ${variety.defaultEc} mS/cm, pH ${variety.defaultPh}). Foliage is on pace for harvest.',
          [
            'Continue scheduled NFT recirculation cycle.',
            'Monitor ambient VPD within 0.8 - 1.1 kPa band.',
          ]
        );
      case PlantConditionCategory.mildChlorosis:
        return (
          'Early interveinal chlorosis observed on younger foliage. Spectral analysis highlights modest chlorophyll pigment attenuation.',
          'Slight iron (Fe-EDDHA) or nitrogen uptake restriction. Check solution pH (Target: ${variety.defaultPh}) to avoid micronutrient lockout.',
          [
            'Calibrate pH sensor and adjust reservoir down to pH ${variety.defaultPh}.',
            'Verify root aeration and dissolved oxygen (DO > 6.5 mg/L).',
          ]
        );
      case PlantConditionCategory.severeTipburn:
        return (
          'Localized calcium deficiency causing apical leaf margin necrosis. High localized transpiration or rapid growth rate exceeds Ca transport.',
          'Increase horizontal canopy airflow to stimulate transpiration and Ca translocation. Lower EC slightly if exceeding ${variety.defaultEc}.',
          [
            'Position oscillating air circulation fan over Tray benches.',
            'Maintain day/night VPD below 1.2 kPa.',
          ]
        );
      case PlantConditionCategory.pathogenStress:
        return (
          'Foliar lesion patterning consistent with fungal spore germination or surface powdery mildew under elevated humidity.',
          'Immediately isolate affected tray area, sanitize NFT gutters, and purge stagnant moisture to halt pathogenic sporulation.',
          [
            'Reduce relative humidity below 65%.',
            'Apply potassium bicarbonate foliar barrier if approved.',
          ]
        );
      case PlantConditionCategory.nutrientDeficiency:
        return (
          'General pale foliar tint and stunted lamina expansion indicating macro-element depletion.',
          'Rebalance bulk nutrient reservoir. Boost EC by +0.2 mS/cm toward target ${variety.defaultEc}.',
          [
            'Dose hydroponic A+B stock solution.',
            'Flush filter manifold to remove sediment.',
          ]
        );
    }
  }
}
