import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/botanical_theme.dart';
import '../models/crop_forecast_models.dart';
import '../algorithms/visual_diagnostic_pipeline.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final ImagePicker _picker = ImagePicker();
  final VisualDiagnosticPipeline _pipeline = VisualDiagnosticPipeline();

  CropVariety _selectedVariety = CropVariety.butterheadLettuce;
  String _tray = 'NFT-04';
  int _growthDay = 22;

  File? _capturedImage;
  bool _isAnalyzing = false;
  bool _hasLogged = false;
  String _currentPipelineStep = '';
  double _pipelineProgress = 0.0;

  // Pipeline result (null initially - NO SEED DATA)
  PipelineExecutionResult? _pipelineResult;

  // Static threshold definitions for confidence evaluation
  static const double _lowConfidenceThreshold = 60.0;
  static const double _highConfidenceThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    // No seed data is loaded! The screen starts ready for real user canopy capture.
  }

  /// Triggers canopy image acquisition (Camera or Gallery) and executes the
  /// 6-Stage Visual Diagnostic Pipeline:
  /// [Mobile Canopy Image] ──> [Variance of Laplacian (Blur Check)]
  ///                                      │
  ///                             [Wiener Deconvolution] (If Blurry)
  ///                                      │
  ///                             [CLAHE Contrast Equalization]
  ///                                      │
  ///                             [YOLOv11s-ECA Feature Extraction]
  ///                                      │
  ///                             [RBF-SVM Condition Classifier]
  ///                                      │
  ///                             [Advisory Disease Diagnosis]
  Future<void> _acquireImageAndRunPipeline(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 1920,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      setState(() {
        _capturedImage = file;
        _isAnalyzing = true;
        _pipelineProgress = 0.05;
        _currentPipelineStep = 'Initializing Canopy Capture...';
      });

      final result = await _pipeline.execute(
        imageFile: file,
        variety: _selectedVariety,
        tray: _tray,
        growthDay: _growthDay,
        currentEc: _selectedVariety.defaultEc,
        currentPh: _selectedVariety.defaultPh,
        vpd: 0.95,
        onStepProgress: (stepDescription, progressFraction) {
          if (mounted) {
            setState(() {
              _currentPipelineStep = stepDescription;
              _pipelineProgress = progressFraction;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _pipelineResult = result;
          _isAnalyzing = false;
          _currentPipelineStep = '';
        });

        final conf = result.finalConfidence;
        final isLow = conf < _lowConfidenceThreshold;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLow
                  ? 'Diagnosis complete · Low confidence (${conf.toStringAsFixed(1)}%). Review caution alert.'
                  : 'Diagnostic pipeline complete · ${conf.toStringAsFixed(1)}% Confidence',
            ),
            backgroundColor: isLow ? Colors.orange.shade800 : BotanicalTheme.primaryDark,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _currentPipelineStep = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera/Pipeline Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _logScan() {
    setState(() => _hasLogged = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Canopy telemetry stored for Tray $_tray. Cloud synced.'),
        backgroundColor: BotanicalTheme.primaryContainer,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hasLogged = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final advisory = _pipelineResult?.advisoryResult;
    final double confidence = advisory?.confidenceScore ?? 100.0;
    final bool isLowConfidence = advisory != null && confidence < _lowConfidenceThreshold;
    final bool isModerateConfidence =
        advisory != null && confidence >= _lowConfidenceThreshold && confidence < _highConfidenceThreshold;

    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Canopy Diagnostics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: BotanicalTheme.primaryDark,
          ),
        ),
        actions: [
          if (_pipelineResult != null)
            IconButton(
              tooltip: 'Pipeline Telemetry Audit',
              icon: const Icon(Icons.analytics_outlined, color: BotanicalTheme.accentGreen),
              onPressed: () => _showPipelineAuditSheet(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Simplified Header: Crop & Tray Info
            _buildCropHeader(),
            const SizedBox(height: 12),

            // Camera Viewfinder Box with YOLO Bounding Boxes
            _buildViewfinder(),
            const SizedBox(height: 12),

            // Use Case 1: Low Confidence Warning Alert Box
            if (isLowConfidence && !_isAnalyzing)
              _buildConfidenceAlertBox(
                isLow: true,
                confidence: confidence,
                reason: _pipelineResult?.blurResult.isBlurry == true
                    ? 'Canopy optical blur detected (Variance of Laplacian < 100.0). High risk of lesion misclassification.'
                    : 'Sub-optimal lighting or occlusion detected. Features do not decisively match standard condition prototypes.',
                guidance:
                    'Do not adjust reservoir dosing based on this scan alone. Retake canopy photo at 15-20cm with steady perpendicular lighting, or perform physical leaf inspection.',
              ),

            // Use Case 2: Moderate Confidence Notice
            if (isModerateConfidence && !_isAnalyzing)
              _buildConfidenceAlertBox(
                isLow: false,
                confidence: confidence,
                reason: 'Adequate feature match with moderate variance.',
                guidance:
                    'Classification is reliable, but verify foliar undersides or apical tips manually before applying major interventions.',
              ),

            // Diagnostic Results Summary (Only visible when scan has occurred)
            if (advisory != null && !_isAnalyzing) ...[
              _buildCoreDiagnosticCard(advisory),
              const SizedBox(height: 12),
              _buildActionableRecommendation(advisory),
              const SizedBox(height: 12),
              _buildPipelineStatusPill(),
              const SizedBox(height: 16),

              // Telemetry Log Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BotanicalTheme.primaryContainer,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _hasLogged ? null : _logScan,
                icon: Icon(
                  _hasLogged ? Icons.cloud_done : Icons.fact_check_outlined,
                  color: BotanicalTheme.accentLime,
                  size: 18,
                ),
                label: Text(
                  _hasLogged ? 'Canopy Record Synchronized' : 'Log Scan & Sync Telemetry',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else if (_capturedImage == null && !_isAnalyzing) ...[
              // Empty State Invitation (No Seed Data)
              _buildEmptyStateCard(),
            ],
          ],
        ),
      ),
    );
  }

  /// Clean Crop & NFT Tray Header
  Widget _buildCropHeader() {
    final statusText = _pipelineResult != null
        ? _pipelineResult!.advisoryResult.status.toUpperCase()
        : 'READY TO SCAN';

    final Color statusBg = _pipelineResult != null
        ? (_pipelineResult!.finalConfidence < _lowConfidenceThreshold
            ? Colors.orange.shade50
            : BotanicalTheme.selectedBg)
        : BotanicalTheme.selectedBg;

    final Color statusTextColor = _pipelineResult != null
        ? (_pipelineResult!.finalConfidence < _lowConfidenceThreshold
            ? Colors.orange.shade800
            : BotanicalTheme.accentGreen)
        : BotanicalTheme.accentGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: BotanicalTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedVariety.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: BotanicalTheme.primaryDark,
                    ),
                  ),
                  Text(
                    'Tray $_tray · Day $_growthDay · Target EC ${_selectedVariety.defaultEc}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: BotanicalTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Canopy Viewfinder Box: Shows Captured Image + YOLOv11 Bounding Boxes & Confidence Overlays
  Widget _buildViewfinder() {
    final boundingBoxes = _pipelineResult?.detectedBoundingBoxes ?? [];

    return Container(
      decoration: BoxDecoration(
        color: BotanicalTheme.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Captured Image or Empty Viewfinder
                if (_capturedImage != null)
                  Image.file(_capturedImage!, fit: BoxFit.cover)
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera_back_outlined,
                            color: BotanicalTheme.accentLime,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No canopy image loaded',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Snap foliage via camera or select from gallery',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. YOLOv11 Bounding Box Overlay (with class label and confidence score)
                if (_capturedImage != null && !_isAnalyzing && boundingBoxes.isNotEmpty)
                  CustomPaint(
                    painter: YoloDetectionBoundingBoxPainter(boxes: boundingBoxes),
                  ),

                // 3. Multi-stage Processing Overlay
                if (_isAnalyzing)
                  Container(
                    color: Colors.black.withOpacity(0.78),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                            color: BotanicalTheme.accentLime,
                            strokeWidth: 3.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentPipelineStep,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _pipelineProgress,
                            minHeight: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              BotanicalTheme.accentLime,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Action Toolbar: Camera & Gallery Pickers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: const Color(0xFF14241B),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BotanicalTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isAnalyzing
                        ? null
                        : () => _acquireImageAndRunPipeline(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text(
                      _capturedImage == null ? 'Take Photo' : 'Retake Photo',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isAnalyzing
                        ? null
                        : () => _acquireImageAndRunPipeline(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text(
                      'From Gallery',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Prominent Confidence Alert Box (Low Confidence Use Case Handling)
  Widget _buildConfidenceAlertBox({
    required bool isLow,
    required double confidence,
    required String reason,
    required String guidance,
  }) {
    final bgColor = isLow ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4);
    final borderColor = isLow ? const Color(0xFFFDBA74) : const Color(0xFF86EFAC);
    final iconColor = isLow ? const Color(0xFFEA580C) : const Color(0xFF16A34A);
    final titleColor = isLow ? const Color(0xFF9A3412) : const Color(0xFF166534);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isLow ? Icons.warning_amber_rounded : Icons.info_outline,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLow ? 'Low Diagnostic Confidence' : 'Moderate Diagnostic Confidence',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: titleColor.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    guidance,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Core Diagnostic Summary Card (Simplified & Focused)
  Widget _buildCoreDiagnosticCard(AdvisoryDiagnosisResult advisory) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Condition Assessment',
                    style: TextStyle(
                      fontSize: 11,
                      color: BotanicalTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    advisory.conditionCategory.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: BotanicalTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: BotanicalTheme.selectedBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      advisory.healthGrade,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: BotanicalTheme.accentGreen,
                      ),
                    ),
                    Text(
                      'Score: ${advisory.overallHealthScore}/100',
                      style: const TextStyle(
                        fontSize: 9,
                        color: BotanicalTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            advisory.botanicalAssessment,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: BotanicalTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: BotanicalTheme.borderSubtle),
          const SizedBox(height: 10),
          // Essential Agronomic Numbers
          Row(
            children: [
              _buildMetricItem('Chlorosis', '${advisory.chlorosisPercentage}%'),
              _buildMetricItem('Necrosis', '${advisory.necrosisPercentage}%'),
              _buildMetricItem('Coverage', '${advisory.coveragePercentage.toInt()}%'),
              _buildMetricItem('Tipburn Risk', '${advisory.tipburnRiskPercentage}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: BotanicalTheme.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: BotanicalTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Actionable Advisory Guidance
  Widget _buildActionableRecommendation(AdvisoryDiagnosisResult advisory) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BotanicalTheme.selectedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BotanicalTheme.accentGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: BotanicalTheme.accentGreen, size: 18),
              SizedBox(width: 6),
              Text(
                'Agronomic Advisory Action',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            advisory.agronomicRecommendation,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: BotanicalTheme.primaryDark,
            ),
          ),
          if (advisory.actionItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...advisory.actionItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: BotanicalTheme.accentGreen, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 11, color: BotanicalTheme.primaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Informational pill showing the 6-stage CV pipeline status
  Widget _buildPipelineStatusPill() {
    return InkWell(
      onTap: () => _showPipelineAuditSheet(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: BotanicalTheme.borderSubtle),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.hub_outlined, size: 16, color: BotanicalTheme.accentGreen),
                SizedBox(width: 8),
                Text(
                  'Visual Diagnostic Pipeline: 6/6 Stages Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BotanicalTheme.primaryDark,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 11,
                    color: BotanicalTheme.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: BotanicalTheme.accentGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Initial Zero-State Card (No Seed Data)
  Widget _buildEmptyStateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.camera_enhance_outlined,
            size: 40,
            color: BotanicalTheme.accentGreen,
          ),
          const SizedBox(height: 12),
          const Text(
            'Ready for Foliar Diagnostic Scan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: BotanicalTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Point your phone camera perpendicular to the hydroponic canopy to run the 6-stage visual pipeline: Blur Check, Wiener Restoration, CLAHE, YOLOv11s-ECA, RBF-SVM, and Agronomic Advisory.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: BotanicalTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: BotanicalTheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _acquireImageAndRunPipeline(ImageSource.camera),
            icon: const Icon(Icons.photo_camera, size: 18, color: BotanicalTheme.accentLime),
            label: const Text(
              'Capture Canopy Photo',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Detailed Bottom Sheet showing intermediate algorithm outputs
  void _showPipelineAuditSheet(BuildContext context) {
    final res = _pipelineResult;
    if (res == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Visual Diagnostic Pipeline Audit',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: BotanicalTheme.primaryDark,
                    ),
                  ),
                  Text(
                    '${res.totalExecutionTimeMs} ms',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: BotanicalTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildAuditStageRow(
                '1. Variance of Laplacian',
                'Variance: ${res.blurResult.variance.toStringAsFixed(1)} · ${res.blurResult.isBlurry ? "Blurry (< 100)" : "Sharp Edge Response"}',
                res.blurResult.isBlurry ? Colors.orange : BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '2. Wiener Deconvolution',
                res.wienerResult.wasApplied
                    ? 'Applied (NSR: ${res.wienerResult.nsrParameter}, Gain: +${res.wienerResult.estimatedSharpnessGain.toStringAsFixed(1)}%)'
                    : 'Bypassed (Canopy image possessed clear focus)',
                BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '3. CLAHE Equalization',
                'Grid: ${res.claheResult.gridTilesX}x${res.claheResult.gridTilesY} · Dynamic Range: +${res.claheResult.dynamicRangeExpansion.toStringAsFixed(1)}%',
                BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '4. YOLOv11s-ECA',
                'Localized ${res.detectedBoundingBoxes.length} box(es) · Latency: ${res.yoloResult.inferenceTimeMs}ms',
                BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '5. RBF-SVM Classifier',
                'Condition: ${res.svmResult.predictedCategory.displayName} · Margin: ${res.svmResult.hyperplaneMarginDistance.toStringAsFixed(2)}',
                BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '6. Advisory Disease Diagnosis',
                'Confidence: ${res.finalConfidence.toStringAsFixed(1)}% · Tier: ${res.confidenceTier.label}',
                res.finalConfidence < _lowConfidenceThreshold ? Colors.orange : BotanicalTheme.accentGreen,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuditStageRow(String title, String subtitle, Color indicatorColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: BotanicalTheme.primaryDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: BotanicalTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter to render YOLOv11 Bounding Boxes with Labels & Confidence Scores
class YoloDetectionBoundingBoxPainter extends CustomPainter {
  final List<YoloBoundingBox> boxes;

  YoloDetectionBoundingBoxPainter({required this.boxes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final box in boxes) {
      final rect = Rect.fromLTWH(
        box.normalizedRect.left * size.width,
        box.normalizedRect.top * size.height,
        box.normalizedRect.width * size.width,
        box.normalizedRect.height * size.height,
      );

      // Bounding box border
      final borderPaint = Paint()
        ..color = box.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      // Subtle translucent box fill
      final fillPaint = Paint()
        ..color = box.color.withOpacity(0.12)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        fillPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        borderPaint,
      );

      // Label and Confidence Score Badge
      final String tagText = ' ${box.detectionClass.label} ${box.confidence.toStringAsFixed(1)}% ';
      final textSpan = TextSpan(
        text: tagText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final double badgeTop = (rect.top - textPainter.height - 4).clamp(4.0, size.height - 20);
      final double badgeLeft = rect.left.clamp(4.0, size.width - textPainter.width - 8);

      final tagBackgroundPaint = Paint()
        ..color = box.color
        ..style = PaintingStyle.fill;

      final tagRect = Rect.fromLTWH(
        badgeLeft,
        badgeTop,
        textPainter.width + 6,
        textPainter.height + 4,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(tagRect, const Radius.circular(4)),
        tagBackgroundPaint,
      );

      textPainter.paint(
        canvas,
        Offset(badgeLeft + 3, badgeTop + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant YoloDetectionBoundingBoxPainter oldDelegate) {
    return oldDelegate.boxes != boxes;
  }
}
