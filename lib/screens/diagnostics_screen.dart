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

  File? _capturedImage;
  bool _isAnalyzing = false;
  String _currentPipelineStep = '';
  double _pipelineProgress = 0.0;

  // Real execution result (null initially - zero seed data)
  PipelineExecutionResult? _pipelineResult;

  /// Minimum confidence threshold: results are suppressed if confidence <= 80.0%
  static const double _minAcceptableConfidence = 80.0;

  /// Executes the 6-Stage Visual Diagnostic Pipeline with Post-Processing Rejections:
  /// 1. Variance of Laplacian (Blur Check)
  /// 2. Wiener Deconvolution (Deblurring if Blurry)
  /// 3. CLAHE Contrast Equalization
  /// 4. YOLOv11s-ECA (with conf >= 0.30 & area >= 0.05 checks -> abort if 0 valid boxes)
  /// 5. RBF-SVM Head (with max(proba) >= 0.60 check -> reject if uncertain)
  /// 6. Advisory Disease Diagnosis
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
        _pipelineProgress = 0.08;
        _currentPipelineStep = '1/6 Variance of Laplacian (Blur Check)...';
      });

      final result = await _pipeline.execute(
        imageFile: file,
        variety: CropVariety.butterheadLettuce,
        tray: 'NFT-01',
        growthDay: 20,
        currentEc: 1.4,
        currentPh: 6.0,
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

        final Color snackColor;
        if (result.isError) {
          snackColor = Colors.red.shade800;
        } else if (result.isUncertain) {
          snackColor = Colors.orange.shade800;
        } else if (result.advisoryResult.isDiseasedDetected) {
          snackColor = const Color(0xFFDC2626);
        } else {
          snackColor = BotanicalTheme.primaryDark;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: snackColor,
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

  @override
  Widget build(BuildContext context) {
    final res = _pipelineResult;
    final advisory = res?.advisoryResult;
    final double confidence = advisory?.confidenceScore ?? 0.0;
    final bool hasScanned = res != null;

    final bool isError = res?.isError ?? false;
    final bool isUncertain = res?.isUncertain ?? false;
    // Strict >80% confidence requirement:
    // If confidence is not above 80%, suppress all model detection results.
    final bool isLowConfidence = hasScanned &&
        !isError &&
        !isUncertain &&
        (res.isLowConfidence || confidence <= _minAcceptableConfidence);
    final bool isHighConfidenceSuccess = hasScanned &&
        !isError &&
        !isUncertain &&
        !isLowConfidence &&
        confidence > _minAcceptableConfidence;

    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Visual Foliar Diagnostics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: BotanicalTheme.primaryDark,
          ),
        ),
        actions: [
          if (_pipelineResult != null)
            IconButton(
              tooltip: 'Pipeline Audit Metrics',
              icon: const Icon(Icons.analytics_outlined,
                  color: BotanicalTheme.accentGreen),
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
            // 1. Camera Viewfinder (YOLO Bounding Box ONLY drawn if confidence > 80%)
            _buildViewfinder(),
            const SizedBox(height: 12),

            // 2. Stage 1 Rejection Error (Zero boxes with conf >= 0.30 & area >= 0.05)
            if (hasScanned && isError && !_isAnalyzing)
              _buildErrorBanner(res.message),

            // 3. Stage 2 Softmax Rejection Alert (max(probabilities) < 0.60)
            if (hasScanned && isUncertain && !_isAnalyzing)
              _buildUncertainBanner(res.message),

            // 4. Strict <= 80% Confidence Notice:
            // "where the confidence level is not above 80%, no result will show, only just say low confidence detected not the model detection result just say low confidence detection retake canopy photo"
            if (hasScanned && isLowConfidence && !_isAnalyzing)
              _buildLowConfidenceRejectionCard(confidence),

            // 5. Diagnostic Results Card (ONLY displayed when confidence is strictly above 80%)
            if (isHighConfidenceSuccess && advisory != null && !_isAnalyzing) ...[
              _buildModelResultCard(advisory),
              const SizedBox(height: 12),
              _buildAgronomicActionCard(advisory),
              const SizedBox(height: 12),
              _buildPipelineStagesSummary(),
              const SizedBox(height: 24),
            ] else if (_capturedImage == null && !_isAnalyzing) ...[
              _buildZeroStateGuide(),
            ],
          ],
        ),
      ),
    );
  }

  /// Canopy Viewfinder: Shows Captured Image + Single YOLO Bounding Box + The ONLY Action Buttons
  Widget _buildViewfinder() {
    final boundingBoxes = _pipelineResult?.detectedBoundingBoxes ?? [];
    final double confidence = _pipelineResult?.finalConfidence ?? 0.0;
    final bool isSuppressed = _pipelineResult?.isError == true ||
        _pipelineResult?.isUncertain == true ||
        _pipelineResult?.isLowConfidence == true ||
        confidence <= 80.0;

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
                // 1. Captured Image or Viewfinder Placeholder
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
                            Icons.camera_alt_outlined,
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
                          'Tap Take Photo below to run visual diagnostics',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. Exactly ONE YOLO Bounding Box (ONLY drawn if confidence > 80% and not rejected)
                if (_capturedImage != null &&
                    !_isAnalyzing &&
                    !isSuppressed &&
                    boundingBoxes.isNotEmpty)
                  CustomPaint(
                    painter: YoloDetectionBoundingBoxPainter(boxes: boundingBoxes),
                  ),

                // 3. 6-Stage Progress Overlay during Analysis
                if (_isAnalyzing)
                  Container(
                    color: Colors.black.withOpacity(0.82),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
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

          // The ONLY Action Bar: Take Photo (Camera) & From Gallery
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
                      padding: const EdgeInsets.symmetric(vertical: 11),
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
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 11),
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
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
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

  /// Stage 1 Rejection Banner: No valid leaf or non-leaf / random object detected
  Widget _buildErrorBanner(String message) {
    final bool isRandomObject =
        message.toLowerCase().contains('non-leaf') || message.toLowerCase().contains('random object');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRandomObject ? 'Non-Leaf / Random Object' : 'Stage 1 Validation Failed',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F1D1D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isRandomObject
                      ? 'Rule: Bok Choy detections below 85.0% confidence are classified as background/random objects.'
                      : 'Validation Rules: Primary Detection Threshold (conf ≥ 0.30) & Minimum Leaf Area (area ≥ 5% of frame).',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFFB91C1C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Stage 2 Rejection Banner: Softmax Probability Rejection (max(probabilities) < 0.60)
  Widget _buildUncertainBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFD97706), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stage 2 Probability Rejection',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF78350F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Validation Rule: RBF-SVM Softmax Rejection Threshold (max(probabilities) ≥ 0.60). Non-plant or unclassifiable foliage rejected.',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Strictly displayed when confidence is not above 80% (confidence <= 80.0):
  /// Suppresses all model detection results and outputs only:
  /// "Low confidence detected. Retake canopy photo."
  Widget _buildLowConfidenceRejectionCard(double confidence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Low Confidence Detected',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confidence: ${confidence.toStringAsFixed(1)}% (Required: >80.0%)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.camera_alt_outlined, size: 20, color: Color(0xFFD97706)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Low confidence detection. Retake canopy photo.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF78350F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Model detection results are hidden when confidence is 80% or below to prevent false diagnoses. Please steady your device at 15–20cm distance with uniform lighting and retake.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Primary Model Output Card (Strictly shows Model Detected Class across the 6 classes)
  Widget _buildModelResultCard(AdvisoryDiagnosisResult advisory) {
    final bool isDiseased = advisory.isDiseasedDetected;

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
                    'Model Detection Result',
                    style: TextStyle(
                      fontSize: 11,
                      color: BotanicalTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    advisory.detectedCropLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: isDiseased
                          ? const Color(0xFFDC2626)
                          : BotanicalTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDiseased
                      ? const Color(0xFFFEE2E2)
                      : BotanicalTheme.selectedBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      advisory.healthGrade,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDiseased
                            ? const Color(0xFFDC2626)
                            : BotanicalTheme.accentGreen,
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
          if (isDiseased) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 15, color: Color(0xFFDC2626)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Unhealthy / diseased foliage detected on canopy. See action items below.',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: BotanicalTheme.borderSubtle),
          const SizedBox(height: 10),
          // Essential Visual Telemetry Numbers
          Row(
            children: [
              _buildMetricItem(
                  'Condition', isDiseased ? 'Diseased' : 'Healthy'),
              _buildMetricItem(
                  'Chlorosis', '${advisory.chlorosisPercentage}%'),
              _buildMetricItem('Necrosis', '${advisory.necrosisPercentage}%'),
              _buildMetricItem('Confidence',
                  '${advisory.confidenceScore.toStringAsFixed(1)}%'),
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

  Widget _buildAgronomicActionCard(AdvisoryDiagnosisResult advisory) {
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
              Icon(Icons.lightbulb_outline,
                  color: BotanicalTheme.accentGreen, size: 18),
              SizedBox(width: 6),
              Text(
                'Agronomic Care Guidance',
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
                    const Text('• ',
                        style: TextStyle(
                            color: BotanicalTheme.accentGreen,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontSize: 11,
                            color: BotanicalTheme.primaryContainer),
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

  Widget _buildPipelineStagesSummary() {
    return InkWell(
      onTap: () => _showPipelineAuditSheet(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                Icon(Icons.verified_outlined,
                    size: 16, color: BotanicalTheme.accentGreen),
                SizedBox(width: 8),
                Text(
                  'Visual Pipeline: 6/6 Computer Vision Stages Executed',
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
                  'Audit',
                  style: TextStyle(
                    fontSize: 11,
                    color: BotanicalTheme.accentGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 16, color: BotanicalTheme.accentGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZeroStateGuide() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.nature_people_outlined,
            size: 38,
            color: BotanicalTheme.accentGreen,
          ),
          SizedBox(height: 10),
          Text(
            'Visual Foliar Diagnostic Engine',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: BotanicalTheme.primaryDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Capture crop foliage to detect whether your Bok Choy, Lettuce, or Spinach is Healthy or Diseased using the 6-stage computer vision pipeline.\n\nUse "Take Photo" or "From Gallery" above to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: BotanicalTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

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
                '1. Variance of Laplacian (Blur Check)',
                'Variance: ${res.blurResult.variance.toStringAsFixed(1)} · ${res.blurResult.isBlurry ? "Blurry (< 100)" : "Sharp Edge Response"}',
                res.blurResult.isBlurry
                    ? Colors.orange
                    : BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '2. Wiener Deconvolution (Deblurring)',
                res.wienerResult.wasApplied
                    ? 'Applied (NSR: ${res.wienerResult.nsrParameter}, Sharpness Gain: +${res.wienerResult.estimatedSharpnessGain.toStringAsFixed(1)}%)'
                    : 'Bypassed (Canopy image possessed clear focus)',
                BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '3. CLAHE Contrast Equalization',
                'Grid: ${res.claheResult.gridTilesX}x${res.claheResult.gridTilesY} · Dynamic Range: +${res.claheResult.dynamicRangeExpansion.toStringAsFixed(1)}%',
                BotanicalTheme.accentGreen,
              ),
              _buildAuditStageRow(
                '4. YOLOv11s-ECA (conf≥0.30 & area≥5%)',
                res.yoloResult.hasValidLeaf
                    ? '1 valid leaf localized (area: ${(res.yoloResult.boundingBoxes.first.relativeArea * 100).toStringAsFixed(1)}%)'
                    : 'Rejected: No bounding box met conf≥0.30 and area≥5%',
                res.yoloResult.hasValidLeaf
                    ? BotanicalTheme.accentGreen
                    : Colors.redAccent,
              ),
              _buildAuditStageRow(
                '5. RBF-SVM Head (max(P)≥0.60)',
                res.svmResult.status == 'ok'
                    ? 'Accepted: max(P)=${(res.svmResult.maxProbability * 100).toStringAsFixed(1)}% ≥ 60%'
                    : 'Rejected: max(P)=${(res.svmResult.maxProbability * 100).toStringAsFixed(1)}% < 60% (Uncertain)',
                res.svmResult.status == 'ok'
                    ? BotanicalTheme.accentGreen
                    : Colors.amber.shade800,
              ),
              _buildAuditStageRow(
                '6. Advisory Disease Diagnosis',
                res.isSuccess
                    ? '${res.advisoryResult.detectedCropLabel} · ${res.finalConfidence.toStringAsFixed(1)}% Conf.'
                    : 'Status: ${res.status.toUpperCase()}',
                res.isSuccess
                    ? BotanicalTheme.accentGreen
                    : Colors.orange.shade800,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuditStageRow(
      String title, String subtitle, Color indicatorColor) {
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
                  style: const TextStyle(
                      fontSize: 11, color: BotanicalTheme.textMuted),
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
      final String tagText =
          ' ${box.detectionClass.label} ${box.confidence.toStringAsFixed(1)}% ';
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

      final double badgeTop =
          (rect.top - textPainter.height - 4).clamp(4.0, size.height - 20);
      final double badgeLeft =
          rect.left.clamp(4.0, size.width - textPainter.width - 8);

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
