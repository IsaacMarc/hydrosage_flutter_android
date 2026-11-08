import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/botanical_theme.dart';
import '../models/almanac_models.dart';
import 'disease_detail_screen.dart';

class CropDetailScreen extends StatelessWidget {
  final CropProfile crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
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
          crop.commonName,
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
              color: BotanicalTheme.selectedBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: BotanicalTheme.accentGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, size: 14, color: BotanicalTheme.accentGreen),
                const SizedBox(width: 4),
                Text(
                  '${crop.cycleDuration.split(' ').first} Days',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BotanicalTheme.accentGreen,
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
            // Hero Image Card
            _buildHeroBanner(),
            const SizedBox(height: 16),

            // Botanical Identification & Summary Card
            _buildBotanicalSummaryCard(),
            const SizedBox(height: 16),

            // Agronomic Vital Conditions Grid
            _buildAgronomicVitalsGrid(),
            const SizedBox(height: 16),

            // Growth Lifecycle & Phenological Phases
            _buildGrowthPhasesSection(),
            const SizedBox(height: 16),

            // Susceptible Foliar Diseases
            _buildSusceptibleDiseasesSection(context),
            const SizedBox(height: 16),

            // Canopy Care & Agronomic Best Practices
            _buildCareTipsSection(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BotanicalTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F6ED), Color(0xFFF4F9F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Image.asset(
                crop.bannerImage,
                fit: BoxFit.contain,
                height: 160,
                errorBuilder: (_, __, ___) => Image.asset(
                  crop.assetImage,
                  fit: BoxFit.contain,
                  height: 140,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.grass,
                    size: 80,
                    color: BotanicalTheme.accentGreen,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                            crop.commonName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: BotanicalTheme.primaryDark,
                            ),
                          ),
                          Text(
                            crop.scientificName,
                            style: GoogleFonts.merriweather(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: BotanicalTheme.accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BotanicalTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        crop.family,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: BotanicalTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  crop.summary,
                  style: GoogleFonts.merriweather(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: BotanicalTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotanicalSummaryCard() {
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
              const Icon(Icons.menu_book_outlined,
                  size: 18, color: BotanicalTheme.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Botanical Overview',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            crop.fullDescription,
            style: const TextStyle(
              fontSize: 13,
              color: BotanicalTheme.primaryDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: BotanicalTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.public,
                    size: 16, color: BotanicalTheme.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Geographic Origin: ${crop.origin}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: BotanicalTheme.primaryDark,
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

  Widget _buildAgronomicVitalsGrid() {
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
              const Icon(Icons.tune, size: 18, color: BotanicalTheme.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Hydroponic Vitals',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVitalItem(
                  icon: Icons.thermostat_outlined,
                  label: 'Temperature',
                  val: crop.idealTemperature,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVitalItem(
                  icon: Icons.science_outlined,
                  label: 'Solution pH',
                  val: crop.idealPh,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVitalItem(
                  icon: Icons.bolt,
                  label: 'Nutrient EC',
                  val: crop.idealEc,
                  color: BotanicalTheme.tertiaryBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVitalItem(
                  icon: Icons.light_mode_outlined,
                  label: 'Photoperiod & DLI',
                  val: crop.photoperiod,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem({
    required IconData icon,
    required String label,
    required String val,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BotanicalTheme.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BotanicalTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: BotanicalTheme.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthPhasesSection() {
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
                  const Icon(Icons.timeline,
                      size: 18, color: BotanicalTheme.accentGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Growth Lifecycle',
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
                child: Text(
                  crop.cycleDuration,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BotanicalTheme.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...crop.growthPhases.map((phase) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    BotanicalTheme.surfaceContainerLow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BotanicalTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          phase.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: BotanicalTheme.primaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: BotanicalTheme.selectedBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          phase.dayRange,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: BotanicalTheme.accentGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phase.description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: BotanicalTheme.primaryDark,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 13, color: BotanicalTheme.accentGreen),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          phase.keyActivity,
                          style: const TextStyle(
                            fontSize: 11,
                            color: BotanicalTheme.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSusceptibleDiseasesSection(BuildContext context) {
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
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Common Vulnerabilities',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: crop.susceptibleDiseases.map((dName) {
              final diseaseMatch = AlmanacRepository.diseases.firstWhere(
                (d) =>
                    d.name.toLowerCase().contains(dName.toLowerCase()) ||
                    dName.toLowerCase().contains(d.name.toLowerCase()),
                orElse: () => AlmanacRepository.diseases.first,
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiseaseDetailScreen(disease: diseaseMatch),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.coronavirus_outlined,
                          size: 14, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Text(
                        dName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios,
                          size: 10, color: Color(0xFFDC2626)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareTipsSection() {
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
              const Icon(Icons.shield_outlined,
                  size: 18, color: BotanicalTheme.accentLime),
              const SizedBox(width: 8),
              Text(
                'Canopy Care & Hygiene Protocols',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...crop.careTips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: BotanicalTheme.accentLime,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

