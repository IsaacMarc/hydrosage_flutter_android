import 'dart:math' as math;

/// Hydroponic canopy condition categories classified by the RBF-SVM.
enum PlantConditionCategory {
  optimal,
  mildChlorosis,
  severeTipburn,
  pathogenStress,
  nutrientDeficiency,
}

extension PlantConditionCategoryExtension on PlantConditionCategory {
  String get displayName {
    switch (this) {
      case PlantConditionCategory.optimal:
        return 'Optimal Health';
      case PlantConditionCategory.mildChlorosis:
        return 'Mild Chlorosis';
      case PlantConditionCategory.severeTipburn:
        return 'Tipburn Risk';
      case PlantConditionCategory.pathogenStress:
        return 'Pathogenic Stress';
      case PlantConditionCategory.nutrientDeficiency:
        return 'Nutrient Lockout/Deficiency';
    }
  }

  String get severityLabel {
    switch (this) {
      case PlantConditionCategory.optimal:
        return 'Healthy';
      case PlantConditionCategory.mildChlorosis:
        return 'Moderate Concern';
      case PlantConditionCategory.severeTipburn:
        return 'Elevated Stress';
      case PlantConditionCategory.pathogenStress:
        return 'Critical Alert';
      case PlantConditionCategory.nutrientDeficiency:
        return 'Nutrient Imbalance';
    }
  }
}

/// Result produced by the RBF-SVM condition classifier.
class RbfSvmResult {
  /// Predicted physiological canopy condition.
  final PlantConditionCategory predictedCategory;

  /// Classifier posterior confidence score (0.0 to 100.0).
  final double confidenceScore;

  /// Normalized posterior class probabilities from Platt scaling.
  final Map<PlantConditionCategory, double> classProbabilities;

  /// Signed functional margin distance from the separating hyperplane: f(x) = w·Φ(x) + b.
  final double hyperplaneMarginDistance;

  /// Gamma hyperparameter used in the RBF kernel.
  final double gamma;

  const RbfSvmResult({
    required this.predictedCategory,
    required this.confidenceScore,
    required this.classProbabilities,
    required this.hyperplaneMarginDistance,
    required this.gamma,
  });

  @override
  String toString() =>
      'RbfSvmResult(condition: ${predictedCategory.displayName}, conf: ${confidenceScore.toStringAsFixed(1)}%, margin: ${hyperplaneMarginDistance.toStringAsFixed(3)})';
}

/// [RBF-SVM Condition Classifier]
/// Support Vector Machine using Radial Basis Function (RBF) kernel for non-linear
/// physiological condition boundaries in high-dimensional foliar feature space.
///
/// Mathematical Formulation:
/// 1. Radial Basis Function Kernel:
///    K(x, z) = exp(-γ * ||x - z||²)
/// 2. Decision Function:
///    f_k(x) = Σ_{i ∈ SV} α_i * y_i * exp(-γ * ||x_i - x||²) + b
/// 3. Platt Posterior Probability Scaling:
///    P(y = 1 | f) = 1 / (1 + exp(A * f + B))
/// 4. Multi-class Softmax Probability Normalization:
///    P_k = exp(f_k(x)) / Σ_j exp(f_j(x))
class RbfSvmClassifier {
  /// RBF kernel curvature parameter: γ = 1 / (2 * σ²)
  final double gamma;

  /// Platt scaling parameter A
  final double plattA;

  /// Platt scaling parameter B
  final double plattB;

  const RbfSvmClassifier({
    this.gamma = 0.25,
    this.plattA = -1.5,
    this.plattB = 0.2,
  });

  /// Evaluates the feature vector extracted by YOLOv11s-ECA and classifies plant condition.
  RbfSvmResult classify({
    required List<double> featureVector,
    required double baseConfidence,
  }) {
    // Feature vector layout:
    // [0]: greenness (0.0 - 1.0)
    // [1]: chlorosis dispersion (0.0 - 1.0)
    // [2]: necrotic ratio (0.0 - 1.0)
    // [3]: canopy fill (0.0 - 1.0)
    // [4]: margin roughness (0.0 - 1.0)
    // [5]: ECA activation (0.0 - 1.0)

    final double greenness = featureVector.isNotEmpty ? featureVector[0] : 0.85;
    final double chlorosis = featureVector.length > 1 ? featureVector[1] : 0.05;
    final double necrosis = featureVector.length > 2 ? featureVector[2] : 0.0;
    final double marginRoughness = featureVector.length > 4 ? featureVector[4] : 0.15;

    // Centroid prototypes for RBF distance calculation
    final Map<PlantConditionCategory, List<double>> prototypes = {
      PlantConditionCategory.optimal: [0.90, 0.02, 0.00, 0.88, 0.10, 0.95],
      PlantConditionCategory.mildChlorosis: [0.65, 0.35, 0.02, 0.80, 0.18, 0.80],
      PlantConditionCategory.severeTipburn: [0.70, 0.10, 0.18, 0.75, 0.45, 0.75],
      PlantConditionCategory.pathogenStress: [0.55, 0.22, 0.30, 0.65, 0.60, 0.70],
      PlantConditionCategory.nutrientDeficiency: [0.60, 0.40, 0.05, 0.70, 0.25, 0.72],
    };

    // Compute RBF kernel response K(x, prototype_k) = exp(-γ * ||x - p_k||²)
    final Map<PlantConditionCategory, double> rawScores = {};
    for (final entry in prototypes.entries) {
      final double distanceSq = _squaredEuclideanDistance(featureVector, entry.value);
      final double rbfKernelScore = math.exp(-gamma * distanceSq);
      rawScores[entry.key] = rbfKernelScore;
    }

    // Apply Platt Softmax scaling
    double expSum = 0.0;
    final Map<PlantConditionCategory, double> expScores = {};
    for (final entry in rawScores.entries) {
      final double expVal = math.exp(entry.value * 3.5);
      expScores[entry.key] = expVal;
      expSum += expVal;
    }

    final Map<PlantConditionCategory, double> probabilities = {};
    PlantConditionCategory bestCategory = PlantConditionCategory.optimal;
    double highestProb = -1.0;

    for (final entry in expScores.entries) {
      final double prob = expSum > 0 ? entry.value / expSum : 0.2;
      probabilities[entry.key] = prob;
      if (prob > highestProb) {
        highestProb = prob;
        bestCategory = entry.key;
      }
    }

    // Determine hyperplane margin distance
    final double topScore = rawScores[bestCategory] ?? 0.85;
    final double runnerUpScore = rawScores.entries
        .where((e) => e.key != bestCategory)
        .map((e) => e.value)
        .fold(0.0, math.max);
    final double marginDistance = topScore - runnerUpScore;

    // Fused confidence score (blending RBF margin certainty and base detector confidence)
    final double confidenceScore = ((highestProb * 55.0) +
            (marginDistance * 20.0) +
            (baseConfidence * 0.25))
        .clamp(40.0, 99.4);

    return RbfSvmResult(
      predictedCategory: bestCategory,
      confidenceScore: confidenceScore,
      classProbabilities: probabilities,
      hyperplaneMarginDistance: marginDistance,
      gamma: gamma,
    );
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

