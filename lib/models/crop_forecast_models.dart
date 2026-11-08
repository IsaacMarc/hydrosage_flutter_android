enum CropVariety {
  butterheadLettuce,
  spinach,
  bokChoy,
}

extension CropVarietyExtension on CropVariety {
  String get displayName {
    switch (this) {
      case CropVariety.butterheadLettuce:
        return 'Butterhead Lettuce';
      case CropVariety.spinach:
        return 'Spinach';
      case CropVariety.bokChoy:
        return 'Bok Choy';
    }
  }

  String get botanicalName {
    switch (this) {
      case CropVariety.butterheadLettuce:
        return 'Lactuca sativa';
      case CropVariety.spinach:
        return 'Spinacia oleracea';
      case CropVariety.bokChoy:
        return 'Brassica rapa subsp. chinensis';
    }
  }

  String get baselineMetric {
    switch (this) {
      case CropVariety.butterheadLettuce:
        return '180–195g (28d cycle)';
      case CropVariety.spinach:
        return '140–160g (24d cycle)';
      case CropVariety.bokChoy:
        return '220–250g (30d cycle)';
    }
  }

  double get defaultEc {
    switch (this) {
      case CropVariety.butterheadLettuce:
        return 1.4;
      case CropVariety.spinach:
        return 1.6;
      case CropVariety.bokChoy:
        return 1.8;
    }
  }

  double get defaultPh {
    switch (this) {
      case CropVariety.butterheadLettuce:
        return 6.0;
      case CropVariety.spinach:
        return 6.2;
      case CropVariety.bokChoy:
        return 6.4;
    }
  }
}

class DiagnosticResult {
  final int overallHealthScore;
  final String healthGrade;
  final double confidenceScore;
  final String botanicalAssessment;
  final double chlorosisPercentage;
  final double necrosisPercentage;
  final double coveragePercentage;
  final double tipburnRiskPercentage;
  final String agronomicRecommendation;
  final String status;

  const DiagnosticResult({
    required this.overallHealthScore,
    required this.healthGrade,
    required this.confidenceScore,
    required this.botanicalAssessment,
    required this.chlorosisPercentage,
    required this.necrosisPercentage,
    required this.coveragePercentage,
    required this.tipburnRiskPercentage,
    required this.agronomicRecommendation,
    required this.status,
  });
}
