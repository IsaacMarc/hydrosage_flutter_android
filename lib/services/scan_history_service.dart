import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single visual diagnostic scan record saved in Leafify history
class ScanRecord {
  final String id;
  final DateTime timestamp;
  final String? imagePath;
  final String? assetFallback;
  final String cropName;
  final String condition;
  final bool isDiseased;
  final double confidenceScore;
  final int healthScore;
  final String healthGrade;
  final String botanicalAssessment;
  final String recommendation;
  final double chlorosisPercentage;
  final double necrosisPercentage;
  final double coveragePercentage;
  final double tipburnRiskPercentage;
  final double laplacianVariance;
  final bool isBlurry;
  final List<Map<String, dynamic>> boundingBoxes;

  const ScanRecord({
    required this.id,
    required this.timestamp,
    this.imagePath,
    this.assetFallback,
    required this.cropName,
    required this.condition,
    required this.isDiseased,
    required this.confidenceScore,
    required this.healthScore,
    required this.healthGrade,
    required this.botanicalAssessment,
    required this.recommendation,
    required this.chlorosisPercentage,
    required this.necrosisPercentage,
    required this.coveragePercentage,
    required this.tipburnRiskPercentage,
    this.laplacianVariance = 145.2,
    this.isBlurry = false,
    this.boundingBoxes = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'imagePath': imagePath,
        'assetFallback': assetFallback,
        'cropName': cropName,
        'condition': condition,
        'isDiseased': isDiseased,
        'confidenceScore': confidenceScore,
        'healthScore': healthScore,
        'healthGrade': healthGrade,
        'botanicalAssessment': botanicalAssessment,
        'recommendation': recommendation,
        'chlorosisPercentage': chlorosisPercentage,
        'necrosisPercentage': necrosisPercentage,
        'coveragePercentage': coveragePercentage,
        'tipburnRiskPercentage': tipburnRiskPercentage,
        'laplacianVariance': laplacianVariance,
        'isBlurry': isBlurry,
        'boundingBoxes': boundingBoxes,
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] as String? ?? 'scan-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      imagePath: json['imagePath'] as String?,
      assetFallback: json['assetFallback'] as String?,
      cropName: json['cropName'] as String? ?? 'Leafy Green',
      condition: json['condition'] as String? ?? 'Analyzed',
      isDiseased: json['isDiseased'] as bool? ?? false,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 90.0,
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 95,
      healthGrade: json['healthGrade'] as String? ?? 'Grade A',
      botanicalAssessment: json['botanicalAssessment'] as String? ?? 'Canopy scan complete.',
      recommendation: json['recommendation'] as String? ?? 'Continue standard nutrient regime.',
      chlorosisPercentage: (json['chlorosisPercentage'] as num?)?.toDouble() ?? 0.0,
      necrosisPercentage: (json['necrosisPercentage'] as num?)?.toDouble() ?? 0.0,
      coveragePercentage: (json['coveragePercentage'] as num?)?.toDouble() ?? 80.0,
      tipburnRiskPercentage: (json['tipburnRiskPercentage'] as num?)?.toDouble() ?? 0.0,
      laplacianVariance: (json['laplacianVariance'] as num?)?.toDouble() ?? 140.0,
      isBlurry: json['isBlurry'] as bool? ?? false,
      boundingBoxes: (json['boundingBoxes'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }
}

/// Singleton Service managing Recent Diagnostic Scans with local SharedPreferences persistence
class ScanHistoryService extends ChangeNotifier {
  static final ScanHistoryService _instance = ScanHistoryService._internal();
  factory ScanHistoryService() => _instance;

  static const String _prefKey = 'leafify_recent_scans_v1';
  final List<ScanRecord> _records = [];

  ScanHistoryService._internal() {
    _loadFromPreferences();
  }

  List<ScanRecord> get recentScans => List.unmodifiable(_records);

  int get totalScans => _records.length;
  int get healthyScans => _records.where((r) => !r.isDiseased).length;
  int get diseasedScans => _records.where((r) => r.isDiseased).length;

  double get averageConfidence {
    if (_records.isEmpty) return 0.0;
    final sum = _records.fold<double>(0.0, (acc, r) => acc + r.confidenceScore);
    return sum / _records.length;
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_prefKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        _records.clear();
        for (final item in decoded) {
          _records.add(ScanRecord.fromJson(item as Map<String, dynamic>));
        }
      } else {
        // Seed initial realistic recent scans so the page is ready and demonstrable
        _seedInitialHistory();
      }
    } catch (_) {
      if (_records.isEmpty) {
        _seedInitialHistory();
      }
    } finally {
      notifyListeners();
    }
  }

  void _seedInitialHistory() {
    final now = DateTime.now();
    _records.addAll([
      ScanRecord(
        id: 'scan-seed-1',
        timestamp: now.subtract(const Duration(minutes: 42)),
        assetFallback: 'assets/images/bok_choy_diseased.png',
        cropName: 'Bok Choy',
        condition: 'Bok-Choy-Diseased',
        isDiseased: true,
        confidenceScore: 92.4,
        healthScore: 68,
        healthGrade: 'Grade C (Alert)',
        botanicalAssessment:
            'Bacterial leaf lesions and marginal necrotic flecking detected on outer petiole blades.',
        recommendation:
            'Increase canopy airflow to 0.4 m/s. Reduce humidity to <70% and rogue necrotic leaves.',
        chlorosisPercentage: 14.8,
        necrosisPercentage: 8.4,
        coveragePercentage: 74.0,
        tipburnRiskPercentage: 12.0,
        laplacianVariance: 168.4,
        isBlurry: false,
        boundingBoxes: [
          {
            'label': 'Bok-Choy-Diseased',
            'confidence': 0.924,
            'left': 0.22,
            'top': 0.18,
            'width': 0.58,
            'height': 0.62,
          }
        ],
      ),
      ScanRecord(
        id: 'scan-seed-2',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 15)),
        assetFallback: 'assets/images/lettuce.png',
        cropName: 'Butterhead Lettuce',
        condition: 'Healthy Lettuce',
        isDiseased: false,
        confidenceScore: 98.6,
        healthScore: 99,
        healthGrade: 'Grade A+ (Optimal)',
        botanicalAssessment:
            'Prime vegetative turgidity. Uniform emerald chlorophyll distribution; zero lesions or tipburn.',
        recommendation:
            'Canopy conditions are optimal. Maintain current NFT nutrient regime (EC 1.4 mS/cm, pH 6.0).',
        chlorosisPercentage: 0.6,
        necrosisPercentage: 0.0,
        coveragePercentage: 88.5,
        tipburnRiskPercentage: 1.0,
        laplacianVariance: 210.5,
        isBlurry: false,
        boundingBoxes: [
          {
            'label': 'lettuce',
            'confidence': 0.986,
            'left': 0.15,
            'top': 0.12,
            'width': 0.70,
            'height': 0.75,
          }
        ],
      ),
      ScanRecord(
        id: 'scan-seed-3',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        assetFallback: 'assets/images/spinach.png',
        cropName: 'Savoy Spinach',
        condition: 'Spinach-Diseased',
        isDiseased: true,
        confidenceScore: 94.1,
        healthScore: 72,
        healthGrade: 'Grade C (Alert)',
        botanicalAssessment:
            'Foliar downy mildew chlorosis observed across upper leaf lamina with active sporulation.',
        recommendation:
            'Raise day temperature to 21°C to stop Bremia sporulation. Ensure zero free leaf wetness.',
        chlorosisPercentage: 18.2,
        necrosisPercentage: 4.8,
        coveragePercentage: 68.0,
        tipburnRiskPercentage: 6.5,
        laplacianVariance: 185.0,
        isBlurry: false,
        boundingBoxes: [
          {
            'label': 'Spinach-Diseased',
            'confidence': 0.941,
            'left': 0.20,
            'top': 0.15,
            'width': 0.65,
            'height': 0.70,
          }
        ],
      ),
      ScanRecord(
        id: 'scan-seed-4',
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        assetFallback: 'assets/images/bok_choy.png',
        cropName: 'Bok Choy',
        condition: 'Healthy Bok Choy',
        isDiseased: false,
        confidenceScore: 97.2,
        healthScore: 97,
        healthGrade: 'Grade A (Optimal)',
        botanicalAssessment:
            'Robust spoon-shaped petiole expansion. Firm leaf cuticles with zero pathogenic spots.',
        recommendation:
            'Growth rate on target. Prepare for harvest selection within the next 4–6 days.',
        chlorosisPercentage: 1.1,
        necrosisPercentage: 0.0,
        coveragePercentage: 84.0,
        tipburnRiskPercentage: 2.2,
        laplacianVariance: 195.8,
        isBlurry: false,
        boundingBoxes: [
          {
            'label': 'bokchoy',
            'confidence': 0.972,
            'left': 0.18,
            'top': 0.14,
            'width': 0.64,
            'height': 0.72,
          }
        ],
      ),
    ]);
  }

  Future<void> addScanRecord(ScanRecord record) async {
    _records.insert(0, record);
    notifyListeners();
    await _saveToPreferences();
  }

  Future<void> deleteScanRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveToPreferences();
  }

  Future<void> clearHistory() async {
    _records.clear();
    notifyListeners();
    await _saveToPreferences();
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _records.map((r) => r.toJson()).toList();
      await prefs.setString(_prefKey, jsonEncode(listJson));
    } catch (_) {}
  }
}

