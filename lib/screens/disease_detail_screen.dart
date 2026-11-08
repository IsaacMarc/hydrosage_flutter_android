import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/botanical_theme.dart';
import '../models/almanac_models.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseProfile disease;

  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final bool isPathogenic = disease.category.toLowerCase().contains('pathogen');

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
          disease.name,
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
              color: isPathogenic
                  ? Colors.red.withValues(alpha: 0.12)
                  : Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              disease.category,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isPathogenic ? const Color(0xFFDC2626) : Colors.amber.shade900,
              ),
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
            // Hero Image & Identification
            _buildHeroCard(isPathogenic),
            const SizedBox(height: 16),

            // Overview & Definition Card
            _buildOverviewCard(),
            const SizedBox(height: 16),

            // Visual Symptoms Checklist
            _buildSymptomsCard(),
            const SizedBox(height: 16),

            // Environmental Triggers & Causes
            _buildTriggersCard(),
            const SizedBox(height: 16),

            // Immediate Corrective Treatment Protocol
            _buildTreatmentCard(),
            const SizedBox(height: 16),

            // Preventative Management
            _buildPreventionCard(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(bool isPathogenic) {
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPathogenic
                    ? [const Color(0xFFFDE8E8), const Color(0xFFFFF5F5)]
                    : [const Color(0xFFFEF3C7), const Color(0xFFFFFBEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  disease.assetImage,
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                  errorBuilder: (_, __, ___) => Icon(
                    isPathogenic ? Icons.coronavirus_outlined : Icons.warning_amber_rounded,
                    size: 80,
                    color: isPathogenic ? Colors.redAccent : Colors.amber.shade700,
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
                            disease.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: BotanicalTheme.primaryDark,
                            ),
                          ),
                          Text(
                            disease.scientificName,
                            style: GoogleFonts.merriweather(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: isPathogenic ? const Color(0xFFDC2626) : Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BotanicalTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        disease.severityLevel.split(' ').first,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: BotanicalTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  disease.summary,
                  style: GoogleFonts.merriweather(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: BotanicalTheme.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Affected Crops: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BotanicalTheme.primaryDark,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: disease.affectedCrops.map((c) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: BotanicalTheme.selectedBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              c,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: BotanicalTheme.accentGreen,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
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
              const Icon(Icons.description_outlined,
                  size: 18, color: BotanicalTheme.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Pathological Overview',
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
            disease.fullDescription,
            style: const TextStyle(
              fontSize: 13,
              color: BotanicalTheme.primaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
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
              const Icon(Icons.visibility_outlined,
                  size: 18, color: BotanicalTheme.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Visual Symptoms & Identification',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...disease.visualSymptoms.map((symptom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fiber_manual_record,
                      size: 8, color: BotanicalTheme.accentGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      symptom,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: BotanicalTheme.primaryDark,
                        height: 1.35,
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

  Widget _buildTriggersCard() {
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
              const Icon(Icons.flash_on_outlined, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Environmental Triggers & Causes',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...disease.environmentalTriggers.map((trigger) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trigger,
                      style: const TextStyle(
                        fontSize: 12,
                        color: BotanicalTheme.primaryDark,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
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

  Widget _buildTreatmentCard() {
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
              const Icon(Icons.medical_services_outlined,
                  size: 18, color: BotanicalTheme.accentLime),
              const SizedBox(width: 8),
              Text(
                'Immediate Corrective Protocol',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...disease.immediateTreatments.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      size: 16, color: BotanicalTheme.accentLime),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
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

  Widget _buildPreventionCard() {
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
              const Icon(Icons.shield_outlined,
                  size: 18, color: BotanicalTheme.accentGreen),
              const SizedBox(width: 8),
              Text(
                'Long-Term Prevention & Sanitation',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...disease.preventativeMeasures.map((measure) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check,
                      size: 14, color: BotanicalTheme.accentGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      measure,
                      style: const TextStyle(
                        fontSize: 12,
                        color: BotanicalTheme.primaryDark,
                        height: 1.35,
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

