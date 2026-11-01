import 'package:flutter/material.dart';
import '../theme/botanical_theme.dart';
import '../models/crop_forecast_models.dart';
import '../services/hydrosage_ai_service.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  CropVariety _selectedVariety = CropVariety.butterheadLettuce;
  String _tray = 'NFT-04';
  int _growthDay = 22;
  bool _isScanning = false;
  bool _hasLogged = false;

  DiagnosticResult _diagnosticResult = const DiagnosticResult(
    overallHealthScore: 98,
    healthGrade: 'Grade A+',
    confidenceScore: 98.4,
    botanicalAssessment:
        'Healthy turgid foliage with optimal cellular density. Zero tipburn, necrotic margins, or pathogenic lesions detected.',
    chlorosisPercentage: 0.8,
    necrosisPercentage: 0.0,
    coveragePercentage: 86.0,
    tipburnRiskPercentage: 1.2,
    agronomicRecommendation:
        'No corrective intervention needed. Current nutrient solution (EC 1.4 mS/cm, pH 6.0) is optimal for foliar expansion.',
    status: 'optimal',
  );

  void _triggerScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    final res = await HydroSageAiService.runFoliarScan(
      variety: _selectedVariety,
      tray: _tray,
      growthDay: _growthDay,
      currentEc: _selectedVariety.defaultEc,
      currentPh: _selectedVariety.defaultPh,
      vpd: 0.95,
    );
    if (mounted) {
      setState(() {
        _diagnosticResult = res;
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Foliar Scan Complete · 98% Confidence'),
          backgroundColor: BotanicalTheme.primaryContainer,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _logScan() {
    setState(() => _hasLogged = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Canopy log stored for Tray NFT-04. Telemetry synchronized.'),
        backgroundColor: BotanicalTheme.primaryContainer,
        duration: Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hasLogged = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: BotanicalTheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco_outlined,
                  color: BotanicalTheme.accentLime, size: 18),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HydroSage Prototype',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: BotanicalTheme.primaryDark),
                ),
                Text(
                  'Diagnostics',
                  style:
                      TextStyle(fontSize: 11, color: BotanicalTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sensors, color: BotanicalTheme.accentGreen),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 15,
            backgroundColor: BotanicalTheme.primaryDark,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Crop Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BotanicalTheme.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: BotanicalTheme.selectedBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.eco,
                            color: BotanicalTheme.accentGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedVariety.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: BotanicalTheme.primaryDark),
                              ),
                              const Icon(Icons.unfold_more,
                                  size: 16, color: BotanicalTheme.textMuted),
                            ],
                          ),
                          Text(
                            'Tray $_tray • Growth Day $_growthDay',
                            style: const TextStyle(
                                fontSize: 11,
                                color: BotanicalTheme.textMuted,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BotanicalTheme.selectedBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                            radius: 3,
                            backgroundColor: BotanicalTheme.accentGreen),
                        SizedBox(width: 5),
                        Text('Optimal',
                            style: TextStyle(
                                color: BotanicalTheme.accentGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Camera Viewfinder Box
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://lh3.googleusercontent.com/aida/AEtjO1WGxUogjNA9nWBobdYSGdw68FQGkPOD9ESeIb-oC2Ye75PNAZHspgW7NrxvwijU0r3TfNxp86ElVu4_8VWGbIjOzQi8HecYoRXmLej5oyNv5QEP6CvAkWEqEN6kvDTDW3X8gvIxXH9ha3YHiIabc7QCJqT0WZDTKvTFNAKeG-tFt1wZ8bYyyaosUCRklfHCFz8Wfce6dlxAxyXEDCAGEJnJEc-TAtvJUEacUM5pWsrjZw',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: BotanicalTheme.primaryContainer,
                            child: const Center(
                                child: Icon(Icons.spa,
                                    color: BotanicalTheme.accentLime,
                                    size: 48)),
                          ),
                        ),
                        if (_isScanning)
                          Container(
                            color: BotanicalTheme.primaryDark.withOpacity(0.5),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: BotanicalTheme.accentLime),
                            ),
                          ),
                        // Corner brackets
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCorner(true, true),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.center_focus_strong,
                                            color: BotanicalTheme.accentLime,
                                            size: 12),
                                        SizedBox(width: 4),
                                        Text('AI SPECTRUM ACTIVE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                  _buildCorner(true, false),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCorner(false, true),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('1.2x OPTICAL',
                                        style: TextStyle(
                                            color: BotanicalTheme.primaryDark,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  _buildCorner(false, false),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          BotanicalTheme.primaryDark.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: _triggerScan,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isScanning ? Icons.sync : Icons.photo_camera,
                            color: BotanicalTheme.accentLime, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isScanning
                              ? 'Analyzing Foliage...'
                              : 'Tap to Re-Scan Foliar Canopy',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Diagnostic Analysis Card
            Container(
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
                      const Row(
                        children: [
                          Icon(Icons.verified,
                              color: BotanicalTheme.accentGreen, size: 20),
                          SizedBox(width: 6),
                          Text('Diagnostic Analysis',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: BotanicalTheme.primaryDark)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: BotanicalTheme.accentLime,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_diagnosticResult.healthGrade} • ${_diagnosticResult.confidenceScore.toInt()}% Conf.',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: BotanicalTheme.primaryDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _diagnosticResult.botanicalAssessment,
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: BotanicalTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildStatBox(
                          'Chlorosis',
                          '${_diagnosticResult.chlorosisPercentage}%',
                          'NOMINAL'),
                      const SizedBox(width: 8),
                      _buildStatBox('Necrosis',
                          '${_diagnosticResult.necrosisPercentage}%', 'CLEAN'),
                      const SizedBox(width: 8),
                      _buildStatBox(
                          'Coverage',
                          '${_diagnosticResult.coveragePercentage.toInt()}%',
                          'DENSE'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Agronomic Recommendation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BotanicalTheme.selectedBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: BotanicalTheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology,
                        color: BotanicalTheme.accentLime, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agronomic Recommendation',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: BotanicalTheme.primaryDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _diagnosticResult.agronomicRecommendation,
                          style: const TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: BotanicalTheme.primaryContainer),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Log Scan Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BotanicalTheme.primaryContainer,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _logScan,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_hasLogged ? Icons.cloud_done : Icons.fact_check,
                      color: BotanicalTheme.accentLime, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _hasLogged ? 'Logged Successfully' : 'Log Scan & Continue',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: BotanicalTheme.accentLime, width: 2.5)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: BotanicalTheme.accentLime, width: 2.5)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: BotanicalTheme.accentLime, width: 2.5)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: BotanicalTheme.accentLime, width: 2.5)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: BotanicalTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: BotanicalTheme.textMuted)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: BotanicalTheme.primaryDark)),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: BotanicalTheme.accentGreen)),
          ],
        ),
      ),
    );
  }
}
