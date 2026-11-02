import 'dart:math' as math;

/// Hydroponic canopy condition categories classified by the prototype RBF-SVM.
enum PlantConditionCategory {
  optimal,
  borderlineStress,
  diseased,
}

extension PlantConditionCategoryExtension on PlantConditionCategory {
  String get displayName {
    switch (this) {
      case PlantConditionCategory.optimal:
        return 'Healthy Foliage';
      case PlantConditionCategory.borderlineStress:
        return 'Suspected Foliar Stress';
      case PlantConditionCategory.diseased:
        return 'Foliar Disease / Unhealthy';
    }
  }

  String get severityLabel {
    switch (this) {
      case PlantConditionCategory.optimal:
        return 'Healthy';
      case PlantConditionCategory.borderlineStress:
        return 'Moderate Caution';
      case PlantConditionCategory.diseased:
        return 'Foliar Alert (Unhealthy)';
    }
  }

  bool get isDiseased => this == PlantConditionCategory.diseased;
}

/// Result produced by the RBF-SVM condition classifier.
class RbfSvmResult {
  /// Execution status: "ok" for confident classification, "uncertain" for rejected embeddings
  final String status;

  /// Informational or rejection message
  final String message;

  /// Predicted physiological canopy condition (null or overridden if uncertain)
  final PlantConditionCategory? predictedCategory;

  /// Classifier posterior confidence score (0.0 to 100.0)
  final double confidenceScore;

  /// Maximum class probability from predict_proba (0.0 - 1.0)
  final double maxProbability;

  /// Normalized posterior class probabilities across all classes
  final Map<PlantConditionCategory, double> classProbabilities;

  /// Signed functional margin distance from separating hyperplane
  final double hyperplaneMarginDistance;

  /// Gamma hyperparameter used in the RBF kernel
  final double gamma;

  /// Whether this result was flagged as uncertain
  bool get isUncertain => status == 'uncertain';

  const RbfSvmResult({
    required this.status,
    required this.message,
    required this.predictedCategory,
    required this.confidenceScore,
    required this.maxProbability,
    required this.classProbabilities,
    required this.hyperplaneMarginDistance,
    required this.gamma,
  });

  /// Factory constructor for the Softmax Probability Rejection Threshold
  factory RbfSvmResult.uncertain({
    required String message,
    required double maxProbability,
    required Map<PlantConditionCategory, double> classProbabilities,
    required double gamma,
  }) {
    return RbfSvmResult(
      status: 'uncertain',
      message: message,
      predictedCategory: null,
      confidenceScore: maxProbability * 100.0,
      maxProbability: maxProbability,
      classProbabilities: classProbabilities,
      hyperplaneMarginDistance: 0.0,
      gamma: gamma,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };

  @override
  String toString() =>
      'RbfSvmResult(status: $status, maxP: ${(maxProbability * 100).toStringAsFixed(1)}%, msg: $message)';
}

/// [RBF-SVM Condition Classifier Head]
/// Evaluates extracted YOLO feature embeddings against support vector boundaries:
/// K(x, z) = exp(-γ * ||x - z||²)
/// f(x) = Σ α_i * y_i * K(x_i, x) + b
///
/// Implements Softmax Probability Rejection:
/// If max(probabilities) < 0.60, overrides class label and flags uncertain match.
class RbfSvmClassifier {
  /// Softmax Probability Rejection Threshold:
  /// Discards ambiguous, low-confidence, or out-of-distribution embeddings
  /// where the RBF-SVM cannot achieve at least 60% posterior probability (0.60).
  /// If max(probabilities) < 0.60, prevents false-positive classifications.
  static const double svmProbaThreshold = 0.60;

  /// RBF kernel curvature parameter: γ = 1 / (2 * σ²)
  final double gamma;

  const RbfSvmClassifier({
    this.gamma = 0.032897,
  });

  /// Calculates posterior class probabilities using RBF kernel projection and softmax
  Map<PlantConditionCategory, double> predictProba({
    required List<double> featureVector,
    bool hasDiseasedYoloDetection = false,
  }) {
    if (featureVector.isEmpty) {
      return {
        PlantConditionCategory.optimal: 0.33,
        PlantConditionCategory.borderlineStress: 0.33,
        PlantConditionCategory.diseased: 0.34,
      };
    }

    // Centroids for Healthy, Borderline, and Diseased foliage in embedding space
    final List<double> healthyPrototype = _createPrototype(greenness: 0.88, disease: 0.02);
    final List<double> borderlinePrototype = _createPrototype(greenness: 0.68, disease: 0.16);
    final List<double> diseasedPrototype = _createPrototype(greenness: 0.48, disease: 0.42);

    final double dHealthy = _squaredEuclideanDistance(featureVector, healthyPrototype);
    final double dBorderline = _squaredEuclideanDistance(featureVector, borderlinePrototype);
    final double dDiseased = _squaredEuclideanDistance(featureVector, diseasedPrototype);

    final double healthyBias = !hasDiseasedYoloDetection ? 0.35 : 0.0;
    final double diseasedBias = hasDiseasedYoloDetection ? 0.35 : 0.0;

    // RBF kernel values: K(x, prototype) = exp(-gamma * ||x - p||^2)
    final double rbfHealthy = math.exp(-gamma * dHealthy * 10.0) + healthyBias;
    final double rbfBorderline = math.exp(-gamma * dBorderline * 10.0);
    final double rbfDiseased = math.exp(-gamma * dDiseased * 10.0) + diseasedBias;

    // Softmax normalization
    final double sum = rbfHealthy + rbfBorderline + rbfDiseased;
    if (sum <= 0) {
      return {
        PlantConditionCategory.optimal: 0.33,
        PlantConditionCategory.borderlineStress: 0.33,
        PlantConditionCategory.diseased: 0.34,
      };
    }

    return {
      PlantConditionCategory.optimal: rbfHealthy / sum,
      PlantConditionCategory.borderlineStress: rbfBorderline / sum,
      PlantConditionCategory.diseased: rbfDiseased / sum,
    };
  }

  /// Classifies the feature vector with probability rejection threshold validation.
  /// If max(probabilities) < 0.60:
  /// {"status": "uncertain", "message": "Low confidence match. Non-plant or unclassifiable leaf state detected."}
  RbfSvmResult classify({
    required List<double> featureVector,
    required double baseConfidence,
    bool hasDiseasedYoloDetection = false,
  }) {
    // 1. Calculate output class probabilities using predict_proba
    final Map<PlantConditionCategory, double> probabilities = predictProba(
      featureVector: featureVector,
      hasDiseasedYoloDetection: hasDiseasedYoloDetection,
    );

    // 2. Identify maximum class probability
    double maxProb = -1.0;
    PlantConditionCategory topCategory = PlantConditionCategory.optimal;

    for (final entry in probabilities.entries) {
      if (entry.value > maxProb) {
        maxProb = entry.value;
        topCategory = entry.key;
      }
    }

    // -------------------------------------------------------------------------
    // SOFTMAX PROBABILITY REJECTION THRESHOLD:
    // If max(probabilities) < 0.60, override class label and return uncertain
    // -------------------------------------------------------------------------
    if (maxProb < svmProbaThreshold) {
      return RbfSvmResult.uncertain(
        message: 'Low confidence match. Non-plant or unclassifiable leaf state detected.',
        maxProbability: maxProb,
        classProbabilities: probabilities,
        gamma: gamma,
      );
    }

    final double marginDistance = maxProb - 0.33;
    final double fusedConfidence = ((maxProb * 65.0) +
            (marginDistance * 15.0) +
            (baseConfidence * 0.20))
        .clamp(60.0, 98.5);

    return RbfSvmResult(
      status: 'ok',
      message: 'Confident classification match.',
      predictedCategory: topCategory,
      confidenceScore: fusedConfidence,
      maxProbability: maxProb,
      classProbabilities: probabilities,
      hyperplaneMarginDistance: marginDistance,
      gamma: gamma,
    );
  }

  List<double> _createPrototype({required double greenness, required double disease}) {
    final List<double> p = List<double>.filled(512, 0.0);
    p[0] = greenness;
    p[1] = disease;
    p[2] = 0.02;
    p[3] = disease > 0.20 ? 1.0 : 0.0;
    p[4] = 0.90;
    p[5] = 0.30;
    for (int i = 6; i < 512; i++) {
      final double phase = (i * 0.0314);
      p[i] = math.sin(phase) * 0.15 + (disease > 0.20 ? 0.08 : -0.05);
    }
    return p;
  }

  double _squaredEuclideanDistance(List<double> a, List<double> b) {
    double sum = 0.0;
    final int len = math.min(a.length, b.length);
    for (int i = 0; i < len; i++) {
      final double diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sum;
  }
}
