import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/botanical_theme.dart';
import '../models/crop_forecast_models.dart';
import '../algorithms/growth_yield_forecaster.dart';

class AddCropForecastScreen extends StatefulWidget {
  final void Function(CropForecastProfile profile)? onProfileCreated;

  const AddCropForecastScreen({super.key, this.onProfileCreated});

  @override
  State<AddCropForecastScreen> createState() => _AddCropForecastScreenState();
}

class _AddCropForecastScreenState extends State<AddCropForecastScreen> {
  CropVariety _selectedVariety = CropVariety.butterheadLettuce;
  late TextEditingController _batchController;
  late TextEditingController _channelController;

  DateTime _transplantDate = DateTime.now().subtract(const Duration(days: 7));
  int _currentDay = 7;
  double _targetBiomass = 185.0;
  int _cycleDurationDays = 28;
  int _plantsPerTray = 36;

  // Environmental Telemetry
  double _ambientTemp = 21.5;
  double _minTemp = 18.0;
  double _maxTemp = 24.5;
  double _ec = 1.4;
  double _ph = 6.0;

  @override
  void initState() {
    super.initState();
    _batchController = TextEditingController(text: 'Batch #501 - Spring Hydro');
    _channelController = TextEditingController(text: 'NFT Channel 04 · Bay A');
    _applyVarietyDefaults(_selectedVariety);
  }

  void _applyVarietyDefaults(CropVariety variety) {
    setState(() {
      _selectedVariety = variety;
      switch (variety) {
        case CropVariety.butterheadLettuce:
          _targetBiomass = 185.0;
          _cycleDurationDays = 28;
          _ec = 1.4;
          _ph = 6.0;
          _ambientTemp = 21.0;
          break;
        case CropVariety.spinach:
          _targetBiomass = 150.0;
          _cycleDurationDays = 24;
          _ec = 1.6;
          _ph = 6.2;
          _ambientTemp = 19.0;
          break;
        case CropVariety.bokChoy:
          _targetBiomass = 235.0;
          _cycleDurationDays = 30;
          _ec = 1.8;
          _ph = 6.4;
          _ambientTemp = 22.5;
          break;
      }
      if (_currentDay > _cycleDurationDays) {
        _currentDay = (_cycleDurationDays / 2).round();
      }
    });
  }

  @override
  void dispose() {
    _batchController.dispose();
    _channelController.dispose();
    super.dispose();
  }

  void _submitAndGenerateForecast() {
    final forecaster = GrowthYieldForecaster();
    final profile = forecaster.generateProfile(
      variety: _selectedVariety,
      batchName: _batchController.text.trim().isNotEmpty
          ? _batchController.text.trim()
          : '${_selectedVariety.displayName} Batch',
      channelId: _channelController.text.trim().isNotEmpty
          ? _channelController.text.trim()
          : 'NFT Channel 01',
      transplantDate: _transplantDate,
      currentDay: _currentDay,
      customCycleDays: _cycleDurationDays,
      customTargetWeight: _targetBiomass,
      plantsPerTray: _plantsPerTray,
      ambientTemp: _ambientTemp,
      minTemp: _minTemp,
      maxTemp: _maxTemp,
      ec: _ec,
      ph: _ph,
    );

    forecaster.addForecastProfile(profile);
    widget.onProfileCreated?.call(profile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: BotanicalTheme.accentLime, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Growth Model Initialized: ${profile.batchName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: BotanicalTheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final estimatedHarvest = _transplantDate.add(Duration(days: _cycleDurationDays));
    final double totalYieldKg = (_targetBiomass * _plantsPerTray) / 1000.0;

    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BotanicalTheme.primaryDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'New Crop Forecast',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: BotanicalTheme.primaryDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Intro
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BotanicalTheme.borderSubtle),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: BotanicalTheme.selectedBg,
                    child: Icon(Icons.auto_graph, color: BotanicalTheme.accentGreen, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Growth & Yield Forecasting Pipeline',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: BotanicalTheme.primaryDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Combines GDD thermal metrics, crop age (DAT), and EC/pH stability into the XGBoost regressor.',
                          style: TextStyle(fontSize: 11, color: BotanicalTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Step 1: Crop Variety Selection
            _buildSectionHeader('1. CROP VARIETY PROFILE', 'Supported Crops'),
            const SizedBox(height: 10),
            Row(
              children: CropVariety.values.map((v) {
                final isSelected = v == _selectedVariety;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _applyVarietyDefaults(v),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? BotanicalTheme.selectedBg : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? BotanicalTheme.accentGreen : BotanicalTheme.borderSubtle,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            v == CropVariety.butterheadLettuce
                                ? Icons.grass
                                : (v == CropVariety.bokChoy ? Icons.eco : Icons.energy_savings_leaf),
                            color: isSelected ? BotanicalTheme.accentGreen : BotanicalTheme.textMuted,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            v.displayName.replaceAll(' ', '\n'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? BotanicalTheme.primaryDark : BotanicalTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Step 2: Batch & Hardware Allocation
            _buildSectionHeader('2. BATCH & INFRASTRUCTURE', 'NFT Channel ID'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BotanicalTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _batchController,
                    decoration: InputDecoration(
                      labelText: 'Batch Name / Identifier',
                      prefixIcon: const Icon(Icons.label_outline, size: 20, color: BotanicalTheme.accentGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                      labelText: 'NFT Channel / Gantry Designation',
                      prefixIcon: const Icon(Icons.table_restaurant_outlined, size: 20, color: BotanicalTheme.accentGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 3: Planting Timeline & Current Age
            _buildSectionHeader('3. CROP AGE & TIMELINE', 'Days After Transplant (DAT)'),
            const SizedBox(height: 10),
            Container(
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
                      const Text(
                        'Transplant Date',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: BotanicalTheme.primaryDark),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: BotanicalTheme.borderSubtle),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _transplantDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 60)),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setState(() {
                              _transplantDate = picked;
                              final calculatedDays = DateTime.now().difference(picked).inDays;
                              if (calculatedDays > 0 && calculatedDays <= _cycleDurationDays) {
                                _currentDay = calculatedDays;
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined, size: 14, color: BotanicalTheme.accentGreen),
                        label: Text(
                          dateFormat.format(_transplantDate),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: BotanicalTheme.primaryDark),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Crop Age (DAT)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: BotanicalTheme.primaryDark),
                      ),
                      Text(
                        'Day $_currentDay of $_cycleDurationDays',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BotanicalTheme.accentGreen),
                      ),
                    ],
                  ),
                  Slider(
                    value: _currentDay.toDouble().clamp(1.0, _cycleDurationDays.toDouble()),
                    min: 1.0,
                    max: _cycleDurationDays.toDouble(),
                    divisions: _cycleDurationDays - 1,
                    activeColor: BotanicalTheme.accentGreen,
                    inactiveColor: BotanicalTheme.surfaceContainer,
                    onChanged: (val) {
                      setState(() {
                        _currentDay = val.round();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 4: Biomass Targets & Cycle Duration
            _buildSectionHeader('4. HARVEST TARGETS', 'Fresh Weight (g/plant)'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BotanicalTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Weight (g/plant)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${_targetBiomass.toInt()} g', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: BotanicalTheme.primaryDark)),
                    ],
                  ),
                  Slider(
                    value: _targetBiomass.clamp(60.0, 350.0),
                    min: 60.0,
                    max: 350.0,
                    divisions: 58,
                    activeColor: BotanicalTheme.accentGreen,
                    inactiveColor: BotanicalTheme.surfaceContainer,
                    onChanged: (val) => setState(() => _targetBiomass = val),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Cycle Days', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('$_cycleDurationDays Days', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: BotanicalTheme.primaryDark)),
                    ],
                  ),
                  Slider(
                    value: _cycleDurationDays.toDouble().clamp(18.0, 45.0),
                    min: 18.0,
                    max: 45.0,
                    divisions: 27,
                    activeColor: BotanicalTheme.accentGreen,
                    inactiveColor: BotanicalTheme.surfaceContainer,
                    onChanged: (val) {
                      setState(() {
                        _cycleDurationDays = val.round();
                        if (_currentDay > _cycleDurationDays) _currentDay = _cycleDurationDays;
                      });
                    },
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Plant Density per Tray', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('$_plantsPerTray heads', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: BotanicalTheme.primaryDark)),
                    ],
                  ),
                  Slider(
                    value: _plantsPerTray.toDouble().clamp(12.0, 72.0),
                    min: 12.0,
                    max: 72.0,
                    divisions: 15,
                    activeColor: BotanicalTheme.accentGreen,
                    inactiveColor: BotanicalTheme.surfaceContainer,
                    onChanged: (val) => setState(() => _plantsPerTray = val.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 5: Environmental Telemetry (GDD + EC/pH Matrix)
            _buildSectionHeader('5. AMBIENT & NUTRITIONAL TELEMETRY', 'GDD & Water Quality'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BotanicalTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.thermostat, size: 18, color: Colors.orange),
                          SizedBox(width: 6),
                          Text('Ambient Temperature', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      Text('${_ambientTemp.toStringAsFixed(1)} °C', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  Slider(
                    value: _ambientTemp.clamp(14.0, 30.0),
                    min: 14.0,
                    max: 30.0,
                    divisions: 32,
                    activeColor: Colors.orange,
                    inactiveColor: BotanicalTheme.surfaceContainer,
                    onChanged: (val) => setState(() {
                      _ambientTemp = val;
                      _minTemp = (val - 3.5).clamp(10.0, 25.0);
                      _maxTemp = (val + 3.0).clamp(18.0, 35.0);
                    }),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt, size: 18, color: BotanicalTheme.tertiaryBlue),
                          SizedBox(width: 6),
                          Text('Nutrient Solution EC', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      Text('${_ec.toStringAsFixed(1)} mS/cm', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  Slider(
                    value: _ec.clamp(0.8, 2.8),
                    min: 0.8,
                    max: 2.8,
                    divisions: 20,
                    activeColor: BotanicalTheme.tertiaryBlue,
                    inactiveColor: BotanicalTheme.surfaceContainer,
                    onChanged: (val) => setState(() => _ec = double.parse(val.toStringAsFixed(1))),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.science_outlined, size: 18, color: Colors.purple),
                          SizedBox(width: 6),
                          Text('Solution pH', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      Text(_ph.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                  Slider(
                    value: _ph.clamp(5.0, 7.5),
                    min: 5.0,
                    max: 7.5,
                    divisions: 25,
                    activeColor: Colors.purple,
                    inactiveColor: BotanicalTheme.surfaceContainer,
                    onChanged: (val) => setState(() => _ph = double.parse(val.toStringAsFixed(1))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Real-Time Projection Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BotanicalTheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.batch_prediction_outlined, color: BotanicalTheme.accentLime, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'PROJECTED HARVEST & YIELD',
                        style: TextStyle(
                          color: BotanicalTheme.accentLime,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Harvest Date',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(estimatedHarvest),
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
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
                            const Text('Total Tray Yield',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                            const SizedBox(height: 2),
                            Text(
                              '${totalYieldKg.toStringAsFixed(2)} kg',
                              style: const TextStyle(color: BotanicalTheme.accentLime, fontSize: 17, fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BotanicalTheme.primaryContainer,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submitAndGenerateForecast,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: BotanicalTheme.accentLime, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Initialize AI Growth Model',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: BotanicalTheme.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: BotanicalTheme.accentGreen),
        ),
      ],
    );
  }
}
