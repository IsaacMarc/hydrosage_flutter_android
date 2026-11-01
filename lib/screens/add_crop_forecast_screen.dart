import 'package:flutter/material.dart';
import '../theme/botanical_theme.dart';
import '../models/crop_forecast_models.dart';

class AddCropForecastScreen extends StatefulWidget {
  final VoidCallback? onInitialize;

  const AddCropForecastScreen({Key? key, this.onInitialize}) : super(key: key);

  @override
  State<AddCropForecastScreen> createState() => _AddCropForecastScreenState();
}

class _AddCropForecastScreenState extends State<AddCropForecastScreen> {
  CropVariety _selectedVariety = CropVariety.butterheadLettuce;
  String _selectedChannel = 'NFT Channel 04';
  int _targetBiomass = 185;
  int _cycleDurationDays = 28;
  final TextEditingController _batchController = TextEditingController(text: 'Batch #403 - Spring Foliar');

  final List<NftChannelConfig> _nftChannels = const [
    NftChannelConfig(id: 'NFT Channel 04', description: 'Active / High Flow', isHighFlow: true),
    NftChannelConfig(id: 'NFT Channel 08', description: 'Standard Slope Recirc'),
    NftChannelConfig(id: 'NFT Channel 12', description: 'Low Gradient Bench'),
    NftChannelConfig(id: 'NFT Channel 16', description: 'Nursery Gantry'),
  ];

  @override
  void dispose() {
    _batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BotanicalTheme.bgSurface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Crop Forecast',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: BotanicalTheme.primaryDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Configure agronomic baseline profile and AI telemetry link to generate precision yield curves.',
              style: TextStyle(
                fontSize: 14,
                color: BotanicalTheme.textMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Variety Selection (NFT only)
            _buildSectionHeader('1. CROP VARIETY PROFILE', 'Preset Calibrated'),
            const SizedBox(height: 10),
            ...CropVariety.values.map((v) => _buildVarietyCard(v)).toList(),

            const SizedBox(height: 24),

            // Section 2: NFT Channel Allocation
            _buildSectionHeader('2. BATCH & INFRASTRUCTURE', 'Bay 04 · Zone A'),
            const SizedBox(height: 10),
            _buildInfrastructureCard(),

            const SizedBox(height: 24),

            // Section 3: Biomass & Cycle
            _buildSectionHeader('3. BIOMASS & TARGETS', 'Cycle: $_cycleDurationDays Days'),
            const SizedBox(height: 10),
            _buildBiomassCard(),

            const SizedBox(height: 24),

            // Section 4: AI Calibration Matrix
            _buildAiMatrixCard(),

            const SizedBox(height: 28),

            // Action Buttons
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BotanicalTheme.primaryContainer,
                elevation: 0,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (widget.onInitialize != null) {
                  widget.onInitialize!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('AI Growth Forecast Initialized for ${_selectedVariety.displayName}!'),
                      backgroundColor: BotanicalTheme.primaryContainer,
                    ),
                  );
                  Navigator.of(context).maybePop();
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: BotanicalTheme.accentLime, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Initialize AI Growth Forecast',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: BotanicalTheme.borderSubtle),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                'Save as Draft Preset',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: BotanicalTheme.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: BotanicalTheme.primaryDark),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: BotanicalTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BotanicalTheme.borderSubtle),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 3.5,
              backgroundColor: BotanicalTheme.accentEmerald,
            ),
            SizedBox(width: 6),
            Text(
              'Cycle Setup · Draft 01',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BotanicalTheme.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: BotanicalTheme.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        Text(
          badge,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: BotanicalTheme.accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildVarietyCard(CropVariety variety) {
    final isSelected = _selectedVariety == variety;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedVariety = variety;
        if (variety == CropVariety.spinach) {
          _targetBiomass = 150;
          _cycleDurationDays = 24;
        } else if (variety == CropVariety.bokChoy) {
          _targetBiomass = 230;
          _cycleDurationDays = 30;
        } else {
          _targetBiomass = 185;
          _cycleDurationDays = 28;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? BotanicalTheme.selectedBg : BotanicalTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BotanicalTheme.primaryContainer : BotanicalTheme.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              color: isSelected ? BotanicalTheme.accentGreen : BotanicalTheme.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variety.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: BotanicalTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${variety.botanicalName} · ${variety.baselineMetric}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: BotanicalTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? BotanicalTheme.primaryContainer : Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfrastructureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BotanicalTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _batchController,
            decoration: InputDecoration(
              labelText: 'Batch Identifier',
              labelStyle: const TextStyle(color: BotanicalTheme.textMuted, fontSize: 13),
              suffixIcon: const Icon(Icons.verified, color: BotanicalTheme.accentGreen, size: 20),
              filled: true,
              fillColor: BotanicalTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Cultivation Subsystem (NFT Dedicated)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BotanicalTheme.textMuted),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: _nftChannels.map((ch) => _buildChannelTile(ch)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelTile(NftChannelConfig channel) {
    final isSelected = _selectedChannel == channel.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedChannel = channel.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BotanicalTheme.primaryContainer : BotanicalTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              channel.id,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isSelected ? BotanicalTheme.accentLime : BotanicalTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              channel.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : BotanicalTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiomassCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BotanicalTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BotanicalTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Biomass Weight',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: BotanicalTheme.primaryDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Recommended 180–195g for crispness',
                    style: TextStyle(fontSize: 12, color: BotanicalTheme.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _targetBiomass = (_targetBiomass - 5).clamp(100, 350)),
                    icon: const Icon(Icons.remove_circle_outline, color: BotanicalTheme.primaryDark),
                  ),
                  Text(
                    '$_targetBiomass g',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: BotanicalTheme.primaryDark,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _targetBiomass = (_targetBiomass + 5).clamp(100, 350)),
                    icon: const Icon(Icons.add_circle_outline, color: BotanicalTheme.primaryDark),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Vegetative Bench Duration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('$_cycleDurationDays Days', style: const TextStyle(fontWeight: FontWeight.w800, color: BotanicalTheme.accentGreen)),
            ],
          ),
          Slider(
            value: _cycleDurationDays.toDouble(),
            min: 18,
            max: 38,
            divisions: 20,
            activeColor: BotanicalTheme.accentGreen,
            inactiveColor: BotanicalTheme.surfaceContainer,
            onChanged: (val) => setState(() => _cycleDurationDays = val.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMatrixCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BotanicalTheme.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy, color: BotanicalTheme.accentLime, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'AI Calibration Matrix',
                    style: TextStyle(color: BotanicalTheme.accentLime, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
              Text(
                'Ensemble v4.2',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol('Nutrient EC', '${_selectedVariety.defaultEc} mS/cm'),
                _buildMetricCol('Target pH', '${_selectedVariety.defaultPh} ±0.2'),
                _buildMetricCol('VPD Target', '0.95 kPa'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
