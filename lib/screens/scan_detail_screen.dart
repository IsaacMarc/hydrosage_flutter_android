import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/botanical_theme.dart';
import '../services/scan_history_service.dart';

class ScanDetailScreen extends StatelessWidget {
  final ScanRecord scan;

  const ScanDetailScreen({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy · hh:mm a');
    final bool isDiseased = scan.isDiseased;

    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: BotanicalTheme.primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Diagnostic Report',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: BotanicalTheme.primaryDark,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDiseased
                  ? Colors.red.withValues(alpha: 0.12)
                  : BotanicalTheme.selectedBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDiseased ? Icons.warning_amber_rounded : Icons.check_circle,
                  size: 14,
                  color: isDiseased
                      ? const Color(0xFFDC2626)
                      : BotanicalTheme.accentGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '${scan.confidenceScore.toStringAsFixed(1)}% Conf',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDiseased
                        ? const Color(0xFFDC2626)
                        : BotanicalTheme.accentGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Canopy Image Card
            _buildCanopyImageCard(),
            const SizedBox(height: 16),

            // Diagnostic Verdict Hero Card
            _buildVerdictCard(dateFormat),
            const SizedBox(height: 16),

            // Foliar Physiological Indicators
            _buildPhysiologicalIndicesCard(),
            const SizedBox(height: 16),

            // 6-Stage Pipeline Quality Telemetry
            _buildPipelineTelemetryCard(),
            const SizedBox(height: 16),

            // Agronomic Treatment Advisory
            _buildAdvisoryCard(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCanopyImageCard() {
    Widget imageWidget;

    if (scan.imagePath != null && File(scan.imagePath!).existsSync()) {
      imageWidget = Image.file(
        File(scan.imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 240,
      );
    } else if (scan.assetFallback != null) {
      imageWidget = Image.asset(
        scan.assetFallback!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 240,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          imageWidget,
          // Crop watermark badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco, size: 14, color: BotanicalTheme.accentLime),
                  const SizedBox(width: 5),
                  Text(
                    scan.cropName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: BotanicalTheme.surfaceContainer,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: BotanicalTheme.textMuted),
      ),
    );
  }

  Widget _buildVerdictCard(DateFormat dateFormat) {
    final bool isDiseased = scan.isDiseased;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDiseased
              ? Colors.red.withValues(alpha: 0.4)
              : BotanicalTheme.accentGreen.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.condition,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDiseased
                            ? const Color(0xFFDC2626)
                            : BotanicalTheme.accentGreen,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(scan.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: BotanicalTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDiseased
                      ? Colors.red.withValues(alpha: 0.1)
                      : BotanicalTheme.selectedBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  scan.healthGrade,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDiseased
                        ? const Color(0xFFDC2626)
                        : BotanicalTheme.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scan.botanicalAssessment,
            style: const TextStyle(
              fontSize: 13,
              color: BotanicalTheme.primaryDark,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysiologicalIndicesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_outlined,
                  size: 18, color: BotanicalTheme.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Canopy Health Indices',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildIndexGauge(
                  label: 'Canopy Coverage',
                  value: '${scan.coveragePercentage.toStringAsFixed(1)}%',
                  color: BotanicalTheme.accentGreen,
                  progress: (scan.coveragePercentage / 100).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildIndexGauge(
                  label: 'Chlorosis Area',
                  value: '${scan.chlorosisPercentage.toStringAsFixed(1)}%',
                  color: scan.chlorosisPercentage > 5.0 ? Colors.orange : BotanicalTheme.accentGreen,
                  progress: (scan.chlorosisPercentage / 30).clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildIndexGauge(
                  label: 'Necrotic Area',
                  value: '${scan.necrosisPercentage.toStringAsFixed(1)}%',
                  color: scan.necrosisPercentage > 2.0 ? const Color(0xFFDC2626) : BotanicalTheme.accentGreen,
                  progress: (scan.necrosisPercentage / 20).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildIndexGauge(
                  label: 'Tipburn Risk',
                  value: '${scan.tipburnRiskPercentage.toStringAsFixed(1)}%',
                  color: scan.tipburnRiskPercentage > 10.0 ? Colors.amber.shade800 : BotanicalTheme.accentGreen,
                  progress: (scan.tipburnRiskPercentage / 25).clamp(0.0, 1.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndexGauge({
    required String label,
    required String value,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BotanicalTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: BotanicalTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: BotanicalTheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.biotech,
                      size: 18, color: BotanicalTheme.accentGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Pipeline Telemetry',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: BotanicalTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BotanicalTheme.selectedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '6-Stage Pipeline',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BotanicalTheme.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPipelineRow('Variance of Laplacian', '${scan.laplacianVariance.toStringAsFixed(1)} (Sharp)'),
          _buildPipelineRow('Wiener Deconvolution', scan.isBlurry ? 'Deblurred (r=2.4)' : 'Bypassed (Clear)'),
          _buildPipelineRow('CLAHE Normalization', 'Nominal (clip=2.0, 8x8 grid)'),
          _buildPipelineRow('YOLOv11s-ECA Extractor', 'Feature tensors passed'),
          _buildPipelineRow('RBF-SVM Head', '${scan.confidenceScore.toStringAsFixed(1)}% class certainty'),
        ],
      ),
    );
  }

  Widget _buildPipelineRow(String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: BotanicalTheme.textMuted),
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: BotanicalTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BotanicalTheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  size: 18, color: BotanicalTheme.accentLime),
              const SizedBox(width: 8),
              Text(
                'Agronomic Advisory & Care Plan',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            scan.recommendation,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

