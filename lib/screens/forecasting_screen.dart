import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/botanical_theme.dart';
import '../models/crop_forecast_models.dart';
import '../algorithms/growth_yield_forecaster.dart';
import 'add_crop_forecast_screen.dart';

/// Full Production-Grade Forecasting Screen for HydroSage AI.
/// Implements the 4-step ML architecture:
/// 1. Daily Ambient Temperature -> GDD Thermal Accumulation
/// 2. Historic pH / EC Telemetry -> Feature Matrix Construction
/// 3. XGBoost Regressor (1.15 ms execution latency)
/// 4. Predicted Fresh Weight (g/plant) & Estimated Harvest Date
class ForecastingScreen extends StatefulWidget {
  const ForecastingScreen({super.key});

  @override
  State<ForecastingScreen> createState() => _ForecastingScreenState();
}

class _ForecastingScreenState extends State<ForecastingScreen> {
  final GrowthYieldForecaster _forecaster = GrowthYieldForecaster();
  late String _selectedProfileId;
  late int _simulatedDay;

  @override
  void initState() {
    super.initState();
    final defaultProfile = _forecaster.defaultProfile;
    _selectedProfileId = defaultProfile.id;
    _simulatedDay = defaultProfile.currentDay;
  }

  CropForecastProfile get _selectedProfile {
    return _forecaster.activeProfiles.firstWhere(
      (p) => p.id == _selectedProfileId,
      orElse: () => _forecaster.defaultProfile,
    );
  }

  CropForecastProfile get _currentViewProfile {
    return _selectedProfile.copyWithSimulatedDay(_simulatedDay);
  }

  void _selectProfile(CropForecastProfile profile) {
    setState(() {
      _selectedProfileId = profile.id;
      _simulatedDay = profile.currentDay;
    });
  }

  Future<void> _openAddCropScreen() async {
    final newProfile = await Navigator.push<CropForecastProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCropForecastScreen(
          onProfileCreated: (profile) {
            _selectProfile(profile);
          },
        ),
      ),
    );

    if (newProfile != null && mounted) {
      _selectProfile(newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _currentViewProfile;
    final baseProfile = _selectedProfile;
    final stageInfo = profile.growthStage;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: BotanicalTheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.analytics_outlined,
                  color: BotanicalTheme.accentLime, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HydroSage Forecasting',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: BotanicalTheme.primaryDark,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'XGBoost Yield & Biomass Engine',
                    style: TextStyle(
                      fontSize: 11,
                      color: BotanicalTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add Crop Batch',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: BotanicalTheme.selectedBg,
                shape: BoxShape.circle,
                border: Border.all(
                    color: BotanicalTheme.accentGreen.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.add,
                  color: BotanicalTheme.accentGreen, size: 18),
            ),
            onPressed: _openAddCropScreen,
          ),
          IconButton(
            tooltip: 'Reset Day to Today',
            icon: const Icon(Icons.restore,
                color: BotanicalTheme.primaryDark, size: 20),
            onPressed: () {
              setState(() {
                _simulatedDay = baseProfile.currentDay;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch / Crop Switcher Horizontal Bar
            _buildBatchSelectorBar(),
            const SizedBox(height: 14),

            // Live Batch Context Header
            _buildLiveBatchContextCard(profile, baseProfile),
            const SizedBox(height: 14),

            // Interactive Day-by-Day Growth Simulator Slider
            _buildGrowthSimulatorCard(profile, baseProfile),
            const SizedBox(height: 14),

            // AI Forecast & Yield Hero Card
            _buildHeroYieldCard(profile, dateFormat),
            const SizedBox(height: 14),

            // Biological Growth Stage Progression (5 Stages)
            _buildGrowthStageProgressCard(profile, stageInfo),
            const SizedBox(height: 14),

            // Phenological S-Curve Biomass Visualization
            _buildSCurveVisualizationCard(profile),
            const SizedBox(height: 14),

            // 4-Step ML Architecture Pipeline Breakdown
            _buildMlArchitectureBreakdown(profile),
            const SizedBox(height: 14),

            // Agronomic & Environmental Management Recipe
            _buildAgronomicRecipeCard(profile),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Horizontal Switcher Bar for all active crop profiles
  Widget _buildBatchSelectorBar() {
    final profiles = _forecaster.activeProfiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Row(
                children: [
                  Icon(Icons.layers_outlined,
                      size: 15, color: BotanicalTheme.textMuted),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'ACTIVE CROPS & BATCHES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: BotanicalTheme.textMuted,
                        letterSpacing: 0.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _openAddCropScreen,
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 14, color: BotanicalTheme.accentGreen),
                  SizedBox(width: 4),
                  Text(
                    'Add New Crop',
                    style: TextStyle(
                      color: BotanicalTheme.accentGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: profiles.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == profiles.length) {
                // Add Crop Button Chip
                return GestureDetector(
                  onTap: _openAddCropScreen,
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: BotanicalTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: BotanicalTheme.borderSubtle,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add,
                            color: BotanicalTheme.accentGreen, size: 22),
                        SizedBox(height: 4),
                        Text(
                          'Add Batch',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: BotanicalTheme.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = profiles[index];
              final isSelected = item.id == _selectedProfileId;

              IconData varietyIcon;
              switch (item.variety) {
                case CropVariety.butterheadLettuce:
                  varietyIcon = Icons.spa;
                  break;
                case CropVariety.bokChoy:
                  varietyIcon = Icons.grass;
                  break;
                case CropVariety.spinach:
                  varietyIcon = Icons.eco;
                  break;
              }

              return GestureDetector(
                onTap: () => _selectProfile(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 170,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BotanicalTheme.primaryContainer
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? BotanicalTheme.accentLime
                          : BotanicalTheme.borderSubtle,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: BotanicalTheme.primaryDark
                                  .withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  varietyIcon,
                                  size: 16,
                                  color: isSelected
                                      ? BotanicalTheme.accentLime
                                      : BotanicalTheme.accentGreen,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item.variety.displayName.split(' ').first,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : BotanicalTheme.primaryDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? BotanicalTheme.accentLime
                                      .withValues(alpha: 0.2)
                                  : BotanicalTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Day ${item.currentDay}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? BotanicalTheme.accentLime
                                    : BotanicalTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.batchName,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white70
                                    : BotanicalTheme.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.currentPredictedWeight.toStringAsFixed(0)}g',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? BotanicalTheme.accentLime
                                  : BotanicalTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Live batch context overview card
  Widget _buildLiveBatchContextCard(
      CropForecastProfile profile, CropForecastProfile baseProfile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BotanicalTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: BotanicalTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CHANNEL: ${profile.channelId.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: BotanicalTheme.primaryDark,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BotanicalTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  profile.variety.botanicalName,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 10,
                    color: BotanicalTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.variety.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: BotanicalTheme.primaryDark,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.batchName} · ${profile.plantsPerTray} plants/tray',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: BotanicalTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Day $_simulatedDay ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: BotanicalTheme.accentGreen,
                      ),
                      children: [
                        TextSpan(
                          text: '/ ${profile.cycleDurationDays} DAT',
                          style: const TextStyle(
                            color: BotanicalTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(
                      color: BotanicalTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: profile.cycleProgressFraction,
                      child: Container(
                        decoration: BoxDecoration(
                          color: BotanicalTheme.accentGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Interactive Growth Simulator Card with day scrubbing slider
  Widget _buildGrowthSimulatorCard(
      CropForecastProfile profile, CropForecastProfile baseProfile) {
    final bool isLiveToday = _simulatedDay == baseProfile.currentDay;
    final bool isSimulatedPast = _simulatedDay < baseProfile.currentDay;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLiveToday
              ? BotanicalTheme.borderSubtle
              : BotanicalTheme.accentGreen.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: BotanicalTheme.primaryDark.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: BotanicalTheme.accentGreen),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Growth Simulator',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: BotanicalTheme.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isLiveToday
                      ? BotanicalTheme.selectedBg
                      : isSimulatedPast
                          ? Colors.amber.withValues(alpha: 0.15)
                          : BotanicalTheme.tertiaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLiveToday
                      ? 'Live Sensor'
                      : isSimulatedPast
                          ? 'Past Replay'
                          : 'Forecast',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLiveToday
                        ? BotanicalTheme.accentGreen
                        : isSimulatedPast
                            ? Colors.amber.shade900
                            : BotanicalTheme.tertiaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Scrub the slider below to simulate growth progression, stage transition, and fresh weight accumulation across the complete harvest lifecycle.',
            style: TextStyle(
              fontSize: 11,
              color: BotanicalTheme.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Slider Row
          Row(
            children: [
              Text(
                'Day 1',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.textMuted.withValues(alpha: 0.8),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: BotanicalTheme.accentGreen,
                    inactiveTrackColor: BotanicalTheme.surfaceContainer,
                    thumbColor: BotanicalTheme.primaryDark,
                    overlayColor:
                        BotanicalTheme.accentGreen.withValues(alpha: 0.15),
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 9, elevation: 3),
                  ),
                  child: Slider(
                    value: _simulatedDay.toDouble(),
                    min: 1.0,
                    max: profile.cycleDurationDays.toDouble(),
                    divisions: profile.cycleDurationDays - 1,
                    label: 'Day $_simulatedDay (${profile.currentPredictedWeight.toStringAsFixed(1)}g)',
                    onChanged: (val) {
                      setState(() {
                        _simulatedDay = val.round();
                      });
                    },
                  ),
                ),
              ),
              Text(
                'Day ${profile.cycleDurationDays}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: BotanicalTheme.textMuted.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Quick Jump Buttons: 4 Equal Flexible Chips (zero overflow risk)
          Row(
            children: [
              Expanded(
                child: _buildPresetChip(
                  label: 'D1 (Start)',
                  isSelected: _simulatedDay == 1,
                  onTap: () => setState(() => _simulatedDay = 1),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildPresetChip(
                  label: 'D${baseProfile.currentDay} (Today)',
                  isSelected: _simulatedDay == baseProfile.currentDay,
                  onTap: () =>
                      setState(() => _simulatedDay = baseProfile.currentDay),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildPresetChip(
                  label: 'D${profile.cycleDurationDays ~/ 2} (Mid)',
                  isSelected: _simulatedDay == profile.cycleDurationDays ~/ 2,
                  onTap: () => setState(
                      () => _simulatedDay = profile.cycleDurationDays ~/ 2),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildPresetChip(
                  label: 'D${profile.cycleDurationDays} (Harv)',
                  isSelected: _simulatedDay == profile.cycleDurationDays,
                  onTap: () => setState(
                      () => _simulatedDay = profile.cycleDurationDays),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? BotanicalTheme.selectedBg
              : BotanicalTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? BotanicalTheme.accentGreen
                : BotanicalTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? BotanicalTheme.accentGreen
                : BotanicalTheme.textMuted,
          ),
        ),
      ),
    );
  }

  /// AI Forecast & Yield Hero Card
  Widget _buildHeroYieldCard(
      CropForecastProfile profile, DateFormat dateFormat) {
    final bool isHarvestReady = profile.isHarvestReady;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BotanicalTheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BotanicalTheme.primaryDark.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.bolt,
                        color: BotanicalTheme.accentLime, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'XGBOOST · ${profile.inferenceLatencyMs.toStringAsFixed(2)} MS',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isHarvestReady
                      ? BotanicalTheme.accentLime
                      : BotanicalTheme.accentLime.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHarvestReady ? Icons.check_circle : Icons.trending_up,
                      size: 13,
                      color: isHarvestReady
                          ? BotanicalTheme.primaryDark
                          : BotanicalTheme.accentLime,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isHarvestReady
                          ? 'Harvest Ready!'
                          : '+4.2% Ahead',
                      style: TextStyle(
                        color: isHarvestReady
                            ? BotanicalTheme.primaryDark
                            : BotanicalTheme.accentLime,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Predicted Weight Headline
          const Text(
            'Predicted Plant Fresh Weight',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                profile.currentPredictedWeight.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'g / plant',
                style: TextStyle(
                  color: BotanicalTheme.accentLime,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          BotanicalTheme.accentLime.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Daily Gain',
                      style: TextStyle(color: Colors.white60, fontSize: 9.5),
                    ),
                    Text(
                      '+${profile.predictedDailyGain.toStringAsFixed(1)} g/d',
                      style: const TextStyle(
                        color: BotanicalTheme.accentLime,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Confidence Interval Subtitle
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 13, color: Colors.white54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '95% Conf: ${profile.confidenceLower.toStringAsFixed(1)}g – ${profile.confidenceUpper.toStringAsFixed(1)}g (±5.2%)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Columns Grid of Key Harvest Projections (Responsive with overflow protection)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Weight',
                        style: TextStyle(color: Colors.white60, fontSize: 9.5),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.targetHarvestWeight.toStringAsFixed(0)} g',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${((profile.currentPredictedWeight / profile.targetHarvestWeight) * 100).clamp(0, 100).toStringAsFixed(0)}% reached',
                        style: const TextStyle(
                          color: BotanicalTheme.accentLime,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tray (36 pl)',
                        style: TextStyle(color: Colors.white60, fontSize: 9.5),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.projectedCurrentTrayYieldKg.toStringAsFixed(2)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Max: ${profile.projectedFinalTrayYieldKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Est. Harvest',
                        style: TextStyle(color: Colors.white60, fontSize: 9.5),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(profile.estimatedHarvestDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        isHarvestReady
                            ? 'Ready now'
                            : '${profile.daysToHarvest}d left',
                        style: TextStyle(
                          color: isHarvestReady
                              ? BotanicalTheme.accentLime
                              : Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Biological Growth Stage Progression Card (5 Stages)
  Widget _buildGrowthStageProgressCard(
      CropForecastProfile profile, GrowthStageInfo currentStage) {
    final stages = [
      CropGrowthStage.seedlingRecovery,
      CropGrowthStage.earlyVegetative,
      CropGrowthStage.midVegetative,
      CropGrowthStage.canopyExpansion,
      CropGrowthStage.harvestReady,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biological Growth Stage',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: BotanicalTheme.primaryDark,
                      ),
                    ),
                    Text(
                      'Phenological phase & development',
                      style: TextStyle(
                        fontSize: 11,
                        color: BotanicalTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BotanicalTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  currentStage.code,
                  style: const TextStyle(
                    color: BotanicalTheme.accentLime,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Active Stage Highlight Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BotanicalTheme.selectedBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BotanicalTheme.accentGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentStage.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: BotanicalTheme.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentStage.dayRange,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: BotanicalTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currentStage.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BotanicalTheme.textMuted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.biotech,
                        size: 14, color: BotanicalTheme.accentGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Milestone: ${currentStage.physiologicalMilestone}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: BotanicalTheme.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5-Stage Stepper Bar
          Row(
            children: List.generate(stages.length, (index) {
              final stageEnum = stages[index];
              final isCurrent = stageEnum == currentStage.stage;
              final isPast = stageEnum.index < currentStage.stage.index;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 4),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? BotanicalTheme.accentGreen
                              : isPast
                                  ? BotanicalTheme.accentLime
                                  : BotanicalTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ST-${index + 1}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              isCurrent ? FontWeight.w800 : FontWeight.w500,
                          color: isCurrent
                              ? BotanicalTheme.primaryDark
                              : BotanicalTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Phenological S-Curve Biomass Visualization Card
  Widget _buildSCurveVisualizationCard(CropForecastProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phenological Timeline',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: BotanicalTheme.primaryDark,
                      ),
                    ),
                    Text(
                      'S-Curve Biomass Accumulation Model',
                      style: TextStyle(
                        fontSize: 11,
                        color: BotanicalTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BotanicalTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ssid_chart,
                        size: 14, color: BotanicalTheme.primaryDark),
                    SizedBox(width: 4),
                    Text(
                      'Sigmoid Fit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: BotanicalTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Legend: Wrapped to fit all screen sizes safely
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                _buildLegendItem(
                  color: BotanicalTheme.accentGreen,
                  label: 'Predicted',
                  isLine: true,
                ),
                _buildLegendItem(
                  color: BotanicalTheme.accentLime.withValues(alpha: 0.4),
                  label: 'Confidence (±5.2%)',
                  isLine: false,
                ),
                _buildLegendItem(
                  color: BotanicalTheme.primaryDark,
                  label: 'Simulated Day',
                  isLine: false,
                  isCircle: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Custom High-Fidelity S-Curve Graphic
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: HighFidelitySCurvePainter(
                profile: profile,
                simulatedDay: _simulatedDay,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // X-Axis Milestones
          Row(
            children: [
              const Text(
                'D1 (3.5g)',
                style: TextStyle(fontSize: 10, color: BotanicalTheme.textMuted),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Day $_simulatedDay (${profile.currentPredictedWeight.toStringAsFixed(1)}g)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: BotanicalTheme.accentGreen,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Spacer(),
              Text(
                'D${profile.cycleDurationDays} (${profile.targetHarvestWeight.toStringAsFixed(0)}g)',
                style: const TextStyle(fontSize: 10, color: BotanicalTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isLine,
    bool isCircle = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCircle)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          )
        else if (isLine)
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: BotanicalTheme.textMuted),
        ),
      ],
    );
  }

  /// 4-Step ML Architecture Pipeline Breakdown
  /// Reflects the exact pipeline specified in the user's diagram
  Widget _buildMlArchitectureBreakdown(CropForecastProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ML Forecasting Pipeline',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: BotanicalTheme.primaryDark,
                      ),
                    ),
                    Text(
                      'Autonomous regression architecture',
                      style: TextStyle(
                        fontSize: 11,
                        color: BotanicalTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BotanicalTheme.selectedBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Edge Inference',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BotanicalTheme.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Step 1: Daily Ambient Temp -> GDD
          _buildPipelineStepCard(
            stepNumber: '1',
            title: 'Daily Ambient Temp → GDD',
            subtitle:
                'Logs daily thermal units above base temp to compute physiological growth.',
            icon: Icons.thermostat,
            accentColor: Colors.deepOrange,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'T: ${profile.currentAmbientTemp}°C (Base: ${profile.baseTemperature}°C)',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'GDD: ${profile.cumulativeGdd.toStringAsFixed(1)} / ${profile.targetGdd.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: BotanicalTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: profile.gddProgressFraction,
                    backgroundColor: BotanicalTheme.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        BotanicalTheme.accentGreen),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Step 2: Historic pH / EC Telemetry -> Feature Matrix
          _buildPipelineStepCard(
            stepNumber: '2',
            title: 'Historic pH / EC → Feature Matrix',
            subtitle:
                'Combines thermal metrics with crop age & sensor stability into a tabular vector.',
            icon: Icons.biotech_outlined,
            accentColor: BotanicalTheme.tertiaryBlue,
            content: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BotanicalTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'EC: ${profile.currentEc.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'pH: ${profile.currentPh.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Stab: ${profile.nutrientStabilityScore.toStringAsFixed(1)}%',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: BotanicalTheme.accentGreen,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: BotanicalTheme.borderSubtle),
                    ),
                    child: Text(
                      'Matrix: [DAT: $_simulatedDay, GDD: ${profile.cumulativeGdd.toStringAsFixed(1)}, EC: ${profile.currentEc}, pH: ${profile.currentPh}, T: ${profile.currentAmbientTemp}°C]',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: BotanicalTheme.primaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Step 3: XGBoost Regressor
          _buildPipelineStepCard(
            stepNumber: '3',
            title: 'Trained XGBoost Regressor',
            subtitle:
                'Lightweight gradient boosted trees evaluate feature interactions in 1.15 ms.',
            icon: Icons.memory,
            accentColor: Colors.purple,
            badge: '1.15 ms',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weights: GDD 42% · DAT 28% · EC 16% · Temp 14%',
                  style: TextStyle(
                    fontSize: 10,
                    color: BotanicalTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildFeatureBar(flex: 42, color: BotanicalTheme.accentGreen),
                    const SizedBox(width: 2),
                    _buildFeatureBar(flex: 28, color: BotanicalTheme.accentLime),
                    const SizedBox(width: 2),
                    _buildFeatureBar(flex: 16, color: BotanicalTheme.tertiaryBlue),
                    const SizedBox(width: 2),
                    _buildFeatureBar(flex: 14, color: Colors.amber),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Step 4: Outputs Predicted Fresh Weight & Harvest Date
          _buildPipelineStepCard(
            stepNumber: '4',
            title: 'Predicted Weight & Harvest Date',
            subtitle:
                'Projects plant bulk, total tray output, and optimal commercial harvest window.',
            icon: Icons.check_circle_outline,
            accentColor: BotanicalTheme.accentGreen,
            content: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Predicted Fresh Weight',
                          style: TextStyle(fontSize: 10, color: BotanicalTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      Text(
                        '${profile.currentPredictedWeight.toStringAsFixed(1)} g / plant',
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
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Estimated Harvest Date',
                          style: TextStyle(fontSize: 10, color: BotanicalTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      Text(
                        DateFormat('MMM dd, yyyy').format(profile.estimatedHarvestDate),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: BotanicalTheme.accentGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStepCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Widget content,
    String? badge,
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
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNumber,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: BotanicalTheme.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: BotanicalTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBar({required int flex, required Color color}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  /// Agronomic & Environmental Management Recipe
  Widget _buildAgronomicRecipeCard(CropForecastProfile profile) {
    String photoperiod = '16.0 hrs / day';
    String dli = '14.5 mol/m²/day';
    String vpd = '0.95 kPa (0.85–1.05)';
    String npkProfile = 'N: 160 ppm · P: 50 ppm · K: 210 ppm · Ca: 180 ppm';

    switch (profile.variety) {
      case CropVariety.butterheadLettuce:
        photoperiod = '16.0 hrs / day';
        dli = '14.0–16.0 mol/m²/day';
        vpd = '0.90–1.05 kPa';
        npkProfile = 'N: 160 ppm · P: 48 ppm · K: 210 ppm · Ca: 175 ppm';
        break;
      case CropVariety.spinach:
        photoperiod = '12.0–14.0 hrs / day';
        dli = '12.0–14.0 mol/m²/day';
        vpd = '0.80–0.95 kPa';
        npkProfile = 'N: 180 ppm · P: 55 ppm · K: 235 ppm · Ca: 190 ppm';
        break;
      case CropVariety.bokChoy:
        photoperiod = '14.0–16.0 hrs / day';
        dli = '15.0–18.0 mol/m²/day';
        vpd = '0.95–1.15 kPa';
        npkProfile = 'N: 200 ppm · P: 60 ppm · K: 250 ppm · Ca: 200 ppm';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Agronomic Recipe & Drivers',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: BotanicalTheme.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BotanicalTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Auto Tuned',
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
          _buildAgronomicRow(
            Icons.light_mode_outlined,
            'Photoperiod & DLI',
            photoperiod,
            dli,
            'Optimal',
          ),
          const SizedBox(height: 8),
          _buildAgronomicRow(
            Icons.air_outlined,
            'VPD Microclimate',
            vpd,
            'Target Transpiration Balance',
            'Nominal',
          ),
          const SizedBox(height: 8),
          _buildAgronomicRow(
            Icons.science_outlined,
            'Hydroponic Nutrient Profile',
            npkProfile,
            'NFT Recirculating Standard',
            'Balanced',
          ),
        ],
      ),
    );
  }

  Widget _buildAgronomicRow(
    IconData icon,
    String title,
    String primaryVal,
    String subVal,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BotanicalTheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BotanicalTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: BotanicalTheme.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          color: BotanicalTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: BotanicalTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  primaryVal,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: BotanicalTheme.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  subVal,
                  style: const TextStyle(
                    fontSize: 10,
                    color: BotanicalTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom High-Fidelity Painter for the S-Curve Phenological Biomass Model
class HighFidelitySCurvePainter extends CustomPainter {
  final CropForecastProfile profile;
  final int simulatedDay;

  HighFidelitySCurvePainter({
    required this.profile,
    required this.simulatedDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = profile.sCurvePoints;
    if (points.isEmpty) return;

    final double maxWeight = profile.targetHarvestWeight * 1.15;
    final int maxDays = profile.cycleDurationDays;

    const double paddingLeft = 10;
    const double paddingRight = 10;
    const double paddingTop = 15;
    const double paddingBottom = 20;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    // Horizontal Grid Lines
    final gridPaint = Paint()
      ..color = BotanicalTheme.surfaceContainer
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final double y = paddingTop + (chartHeight * (i / 4));
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(paddingLeft + chartWidth, y),
        gridPaint,
      );
    }

    // Helper function to map (day, weight) to canvas Offset
    Offset toOffset(double day, double weight) {
      final double x = paddingLeft + ((day - 1) / (maxDays - 1)) * chartWidth;
      final double y =
          paddingTop + chartHeight - ((weight / maxWeight) * chartHeight);
      return Offset(x, y.clamp(paddingTop, paddingTop + chartHeight));
    }

    // 1. Shaded Confidence Interval Envelope
    final confidencePath = Path();
    if (points.isNotEmpty) {
      final firstUpper = toOffset(points.first.day.toDouble(), points.first.confidenceUpper);
      confidencePath.moveTo(firstUpper.dx, firstUpper.dy);

      for (int i = 1; i < points.length; i++) {
        final pt = toOffset(points[i].day.toDouble(), points[i].confidenceUpper);
        confidencePath.lineTo(pt.dx, pt.dy);
      }

      for (int i = points.length - 1; i >= 0; i--) {
        final pt = toOffset(points[i].day.toDouble(), points[i].confidenceLower);
        confidencePath.lineTo(pt.dx, pt.dy);
      }
      confidencePath.close();

      final confidencePaint = Paint()
        ..color = BotanicalTheme.accentLime.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawPath(confidencePath, confidencePaint);
    }

    // 2. Area gradient under the prediction curve
    final areaPath = Path();
    final firstPt = toOffset(points.first.day.toDouble(), points.first.predictedWeight);
    areaPath.moveTo(firstPt.dx, paddingTop + chartHeight);
    areaPath.lineTo(firstPt.dx, firstPt.dy);

    for (int i = 1; i < points.length; i++) {
      final pt = toOffset(points[i].day.toDouble(), points[i].predictedWeight);
      areaPath.lineTo(pt.dx, pt.dy);
    }

    final lastPt = toOffset(points.last.day.toDouble(), points.last.predictedWeight);
    areaPath.lineTo(lastPt.dx, paddingTop + chartHeight);
    areaPath.close();

    final areaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        BotanicalTheme.accentGreen.withValues(alpha: 0.22),
        BotanicalTheme.accentGreen.withValues(alpha: 0.02),
      ],
    );
    final areaPaint = Paint()
      ..shader = areaGradient.createShader(
          Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    // 3. Predicted S-Curve Trajectory Path
    final curvePath = Path();
    curvePath.moveTo(firstPt.dx, firstPt.dy);

    for (int i = 1; i < points.length; i++) {
      final pt = toOffset(points[i].day.toDouble(), points[i].predictedWeight);
      curvePath.lineTo(pt.dx, pt.dy);
    }

    final curvePaint = Paint()
      ..color = BotanicalTheme.accentGreen
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(curvePath, curvePaint);

    // 4. Vertical Marker for Simulated Day
    final double simDayClamped = simulatedDay.clamp(1, maxDays).toDouble();
    final currentPoint = profile.sCurvePoints.firstWhere(
      (p) => p.day == simulatedDay.clamp(1, maxDays),
      orElse: () => profile.sCurvePoints.last,
    );
    final Offset markerOffset = toOffset(simDayClamped, currentPoint.predictedWeight);

    // Vertical indicator line
    final markerLinePaint = Paint()
      ..color = BotanicalTheme.primaryDark.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(markerOffset.dx, paddingTop),
      Offset(markerOffset.dx, paddingTop + chartHeight),
      markerLinePaint,
    );

    // Outer glow pulse
    final glowPaint = Paint()
      ..color = BotanicalTheme.accentLime.withValues(alpha: 0.45);
    canvas.drawCircle(markerOffset, 10, glowPaint);

    // Inner marker dot
    final dotPaint = Paint()..color = BotanicalTheme.primaryDark;
    canvas.drawCircle(markerOffset, 5, dotPaint);

    final centerDotPaint = Paint()..color = BotanicalTheme.accentLime;
    canvas.drawCircle(markerOffset, 3, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant HighFidelitySCurvePainter oldDelegate) {
    return oldDelegate.simulatedDay != simulatedDay ||
        oldDelegate.profile.id != profile.id;
  }
}
