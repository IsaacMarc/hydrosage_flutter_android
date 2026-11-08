import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/botanical_theme.dart';
import '../services/scan_history_service.dart';
import 'scan_detail_screen.dart';

class RecentScansScreen extends StatefulWidget {
  final VoidCallback? onSwitchToDiagnostics;

  const RecentScansScreen({super.key, this.onSwitchToDiagnostics});

  @override
  State<RecentScansScreen> createState() => _RecentScansScreenState();
}

class _RecentScansScreenState extends State<RecentScansScreen> {
  final ScanHistoryService _historyService = ScanHistoryService();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _historyService.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    _historyService.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  List<ScanRecord> _getFilteredScans() {
    final all = _historyService.recentScans;
    switch (_selectedFilter) {
      case 'Healthy':
        return all.where((r) => !r.isDiseased).toList();
      case 'Alerts':
        return all.where((r) => r.isDiseased).toList();
      case 'Lettuce':
        return all.where((r) => r.cropName.toLowerCase().contains('lettuce')).toList();
      case 'Bok Choy':
        return all.where((r) => r.cropName.toLowerCase().contains('bok')).toList();
      case 'Spinach':
        return all.where((r) => r.cropName.toLowerCase().contains('spinach')).toList();
      default:
        return all;
    }
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Scan History?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: BotanicalTheme.primaryDark,
          ),
        ),
        content: const Text(
          'This will remove all stored foliar diagnostic scan records.',
          style: TextStyle(fontSize: 13, color: BotanicalTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: BotanicalTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              _historyService.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredScans = _getFilteredScans();

    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: BotanicalTheme.selectedBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history, color: BotanicalTheme.accentGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Recent Scans',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: BotanicalTheme.primaryDark,
              ),
            ),
          ],
        ),
        actions: [
          if (_historyService.recentScans.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_sweep_outlined, color: BotanicalTheme.textMuted),
              onPressed: _confirmClearHistory,
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // KPI Summary Bar
          _buildKpiBanner(),

          // Horizontal Filter Chips
          _buildFilterChips(),

          // Scan List
          Expanded(
            child: filteredScans.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredScans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final scan = filteredScans[index];
                      return _buildScanCard(scan);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKpiStat(
              'Total Scans',
              '${_historyService.totalScans}',
              BotanicalTheme.primaryDark,
            ),
          ),
          Container(width: 1, height: 30, color: BotanicalTheme.borderSubtle),
          Expanded(
            child: _buildKpiStat(
              'Healthy',
              '${_historyService.healthyScans}',
              BotanicalTheme.accentGreen,
            ),
          ),
          Container(width: 1, height: 30, color: BotanicalTheme.borderSubtle),
          Expanded(
            child: _buildKpiStat(
              'Alerts',
              '${_historyService.diseasedScans}',
              const Color(0xFFDC2626),
            ),
          ),
          Container(width: 1, height: 30, color: BotanicalTheme.borderSubtle),
          Expanded(
            child: _buildKpiStat(
              'Avg Conf',
              '${_historyService.averageConfidence.toStringAsFixed(0)}%',
              BotanicalTheme.tertiaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: BotanicalTheme.textMuted,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Alerts', 'Healthy', 'Lettuce', 'Bok Choy', 'Spinach'];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? BotanicalTheme.accentGreen : BotanicalTheme.primaryDark,
              ),
            ),
            selected: isSelected,
            selectedColor: BotanicalTheme.selectedBg,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? BotanicalTheme.accentGreen : BotanicalTheme.borderSubtle,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildScanCard(ScanRecord scan) {
    final bool isDiseased = scan.isDiseased;
    final timeStr = _formatRelativeTime(scan.timestamp);

    Widget imageThumbnail;
    if (scan.imagePath != null && File(scan.imagePath!).existsSync()) {
      imageThumbnail = Image.file(
        File(scan.imagePath!),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      );
    } else if (scan.assetFallback != null) {
      imageThumbnail = Image.asset(
        scan.assetFallback!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildCardPlaceholder(),
      );
    } else {
      imageThumbnail = _buildCardPlaceholder();
    }

    return Dismissible(
      key: Key(scan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        _historyService.deleteScanRecord(scan.id);
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanDetailScreen(scan: scan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDiseased
                  ? Colors.red.withValues(alpha: 0.3)
                  : BotanicalTheme.borderSubtle,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Canopy Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageThumbnail,
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            scan.cropName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: BotanicalTheme.primaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDiseased
                                ? Colors.red.withValues(alpha: 0.1)
                                : BotanicalTheme.selectedBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${scan.confidenceScore.toStringAsFixed(0)}% Conf',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDiseased
                                  ? const Color(0xFFDC2626)
                                  : BotanicalTheme.accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          isDiseased ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          size: 13,
                          color: isDiseased
                              ? const Color(0xFFDC2626)
                              : BotanicalTheme.accentGreen,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            scan.condition,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDiseased
                                  ? const Color(0xFFDC2626)
                                  : BotanicalTheme.primaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.botanicalAssessment,
                      style: const TextStyle(
                        fontSize: 11,
                        color: BotanicalTheme.textMuted,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 10,
                            color: BotanicalTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Row(
                          children: [
                            Text(
                              'View Report',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: BotanicalTheme.accentGreen,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward_ios,
                                size: 10, color: BotanicalTheme.accentGreen),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: BotanicalTheme.surfaceContainer,
      child: const Icon(Icons.image_outlined, size: 24, color: BotanicalTheme.textMuted),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: BotanicalTheme.selectedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  size: 40, color: BotanicalTheme.accentGreen),
            ),
            const SizedBox(height: 16),
            Text(
              'No Diagnostic Scans Yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: BotanicalTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Perform a foliar diagnostic scan in the Diagnostics tab to log canopy evaluations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: BotanicalTheme.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM dd, yyyy').format(dt);
  }
}

