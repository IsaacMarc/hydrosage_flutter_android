import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/botanical_theme.dart';
import '../models/almanac_models.dart';
import 'crop_detail_screen.dart';
import 'disease_detail_screen.dart';

class AlmanacScreen extends StatefulWidget {
  const AlmanacScreen({super.key});

  @override
  State<AlmanacScreen> createState() => _AlmanacScreenState();
}

class _AlmanacScreenState extends State<AlmanacScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const allCrops = AlmanacRepository.crops;
    const allDiseases = AlmanacRepository.diseases;

    final filteredCrops = allCrops.where((crop) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return crop.commonName.toLowerCase().contains(q) ||
          crop.scientificName.toLowerCase().contains(q) ||
          crop.family.toLowerCase().contains(q) ||
          crop.summary.toLowerCase().contains(q);
    }).toList();

    final filteredDiseases = allDiseases.where((d) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.scientificName.toLowerCase().contains(q) ||
          d.summary.toLowerCase().contains(q) ||
          d.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF6FAA67), // Pale botanical green header background from image
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Main White Container Card with rounded top
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Almanac Title with Sprout Icon
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.eco,
                              color: Color(0xFF235A22),
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Almanac',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E281F),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pill Search Bar matching image
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEFEA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFDFE3DC)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim();
                                  });
                                },
                                style: GoogleFonts.merriweather(
                                  fontSize: 12.5,
                                  color: const Color(0xFF1E281F),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText:
                                      'Search disease name... plant profile... treatment pla..',
                                  hintStyle: GoogleFonts.merriweather(
                                    fontSize: 11.5,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF868E86),
                                  ),
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF606A63),
                                ),
                              )
                            else
                              const Icon(
                                Icons.search,
                                size: 22,
                                color: Color(0xFF4A554D),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section 1: Crop Profiles
                      if (filteredCrops.isNotEmpty) ...[
                        _buildSectionHeader('Crop Profiles'),
                        const SizedBox(height: 12),
                        ...filteredCrops.map((crop) => _buildCropItem(crop)),
                        const SizedBox(height: 18),
                      ],

                      // Section 2: Common Diseases
                      if (filteredDiseases.isNotEmpty) ...[
                        _buildSectionHeader('Common Diseases'),
                        const SizedBox(height: 12),
                        ...filteredDiseases.map((disease) => _buildDiseaseItem(disease)),
                        const SizedBox(height: 24),
                      ],

                      // Empty state if search returned no results
                      if (filteredCrops.isEmpty && filteredDiseases.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.search_off,
                                    size: 48, color: BotanicalTheme.textMuted),
                                const SizedBox(height: 10),
                                Text(
                                  'No entries match "$_searchQuery"',
                                  style: GoogleFonts.merriweather(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: BotanicalTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Header with extending horizontal line matching mockup
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 17,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E281F),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(
            color: Color(0xFF5A635B),
            thickness: 0.9,
          ),
        ),
      ],
    );
  }

  /// Crop Profile block matching mockup
  Widget _buildCropItem(CropProfile crop) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CropDetailScreen(crop: crop),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop image thumbnail
            SizedBox(
              width: 76,
              height: 76,
              child: Center(
                child: Image.asset(
                  crop.assetImage,
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    crop.bannerImage,
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: BotanicalTheme.selectedBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.eco,
                          color: BotanicalTheme.accentGreen, size: 36),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Crop Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${crop.commonName} (${crop.scientificName})',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF1E281F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    crop.summary,
                    style: GoogleFonts.merriweather(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF4A554D),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Disease block matching mockup
  Widget _buildDiseaseItem(DiseaseProfile disease) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiseaseDetailScreen(disease: disease),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease image thumbnail with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                disease.assetImage,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.coronavirus_outlined,
                      color: Colors.redAccent, size: 36),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Disease Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF1E281F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disease.summary,
                    style: GoogleFonts.merriweather(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF4A554D),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

