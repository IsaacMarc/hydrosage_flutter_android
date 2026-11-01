import 'package:flutter/material.dart';
import '../theme/botanical_theme.dart';
import '../models/crop_forecast_models.dart';
import 'add_crop_forecast_screen.dart';

class ForecastingScreen extends StatefulWidget {
  const ForecastingScreen({Key? key}) : super(key: key);

  @override
  State<ForecastingScreen> createState() => _ForecastingScreenState();
}

class _ForecastingScreenState extends State<ForecastingScreen> {
  CropVariety _currentCrop = CropVariety.butterheadLettuce;
  int _currentDay = 14;
  final int _cycleDays = 28;
  final int _targetBiomass = 185;

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
                  'Forecasting',
                  style:
                      TextStyle(fontSize: 11, color: BotanicalTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: BotanicalTheme.primaryDark),
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
            // Live Cycle Telemetry Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BotanicalTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                              radius: 3.5,
                              backgroundColor: BotanicalTheme.accentLime),
                          SizedBox(width: 6),
                          Text(
                            'LIVE CYCLE TELEMETRY',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: BotanicalTheme.primaryDark,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AddCropForecastScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: BotanicalTheme.selectedBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add,
                                      size: 14,
                                      color: BotanicalTheme.accentGreen),
                                  SizedBox(width: 3),
                                  Text('Add Crop',
                                      style: TextStyle(
                                          color: BotanicalTheme.accentGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: BotanicalTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.sensors,
                                    size: 12, color: BotanicalTheme.textMuted),
                                SizedBox(width: 4),
                                Text('Bay 04 · Zone A',
                                    style: TextStyle(
                                        color: BotanicalTheme.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentCrop.displayName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: BotanicalTheme.primaryDark),
                          ),
                          const Text(
                            'Batch Cycle #402 · Aeroponic Bench 12',
                            style: TextStyle(
                                fontSize: 12, color: BotanicalTheme.textMuted),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Day $_currentDay ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: BotanicalTheme.accentGreen),
                              children: [
                                TextSpan(
                                  text: '/ $_cycleDays',
                                  style: const TextStyle(
                                      color: BotanicalTheme.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal),
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
                              widthFactor: _currentDay / _cycleDays,
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
            ),
            const SizedBox(height: 14),

            // AI Forecast Milestone Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: BotanicalTheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.eco,
                              color: BotanicalTheme.accentLime, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'AI FORECAST MILESTONE',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BotanicalTheme.accentLime,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_up,
                                size: 14, color: BotanicalTheme.primaryDark),
                            SizedBox(width: 4),
                            Text('+4% Ahead of Schedule',
                                style: TextStyle(
                                    color: BotanicalTheme.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Predicted Harvest Window',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 2),
                  const Text(
                    'Nov 28, 2025',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5),
                  ),
                  const Text('14 Days Remaining · Target Stage Confirmed',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    BotanicalTheme.accentLime.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.scale,
                                  color: BotanicalTheme.accentLime, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expected Yield',
                                    style: TextStyle(
                                        color: Colors.white60, fontSize: 11)),
                                RichText(
                                  text: TextSpan(
                                    text: '$_targetBiomass g ',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15),
                                    children: const [
                                      TextSpan(
                                          text: '/ head',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Projected Output',
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 11)),
                            Text(
                              '${(_targetBiomass * 8).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} kg total',
                              style: const TextStyle(
                                  color: BotanicalTheme.accentLime,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Phenological Timeline (S-Curve)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: BotanicalTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phenological Timeline',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: BotanicalTheme.primaryDark)),
                          Text('S-Curve Biomass Accumulation Model',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: BotanicalTheme.textMuted)),
                        ],
                      ),
                      Icon(Icons.ssid_chart, color: BotanicalTheme.textMuted),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // S-Curve Custom Painter or Visual Curve
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BotanicalTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                    radius: 3,
                                    backgroundColor:
                                        BotanicalTheme.accentGreen),
                                SizedBox(width: 5),
                                Text('Actual Density',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: BotanicalTheme.textMuted)),
                              ],
                            ),
                            Row(
                              children: [
                                CircleAvatar(
                                    radius: 3,
                                    backgroundColor:
                                        BotanicalTheme.tertiaryBlue),
                                SizedBox(width: 5),
                                Text('Predicted S-Curve',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: BotanicalTheme.textMuted)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 70,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: SCurvePainter(
                                progressFactor: _currentDay / _cycleDays),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Day 1 (0g)',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: BotanicalTheme.textMuted)),
                            Text('Today: Day 14 (92g)',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: BotanicalTheme.accentGreen)),
                            Text('Day 28 (185g)',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: BotanicalTheme.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Milestones
                  _buildMilestone(
                      Icons.check,
                      'Germination & Emergence',
                      'Radicle breakthrough & cotyledon spread',
                      'Days 1–5',
                      true,
                      false),
                  _buildMilestone(
                      Icons.check,
                      'Seedling & Rooting',
                      'Hydroponic root zone anchor established',
                      'Days 6–12',
                      true,
                      false),
                  _buildMilestone(
                      Icons.health_and_safety_outlined,
                      'Vegetative Canopy Sprint',
                      'Rapid leaf blade surface expansion (LAI 2.8)',
                      'Days 13–21',
                      false,
                      true),
                  _buildMilestone(
                      Icons.timelapse,
                      'Maturation & Head Density',
                      'Heart tightening & crisp foliage firming',
                      'Days 22–28',
                      false,
                      false),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Forecast Drivers
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Forecast Drivers',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: BotanicalTheme.primaryDark)),
                    Text('Autonomous Tuning Active',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: BotanicalTheme.accentGreen)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDriverCard(Icons.light_mode, 'Photoperiod & DLI',
                    '16.0 hrs / day', 'Optimal GDD thermal sum', '67%'),
                const SizedBox(height: 8),
                _buildDriverCard(
                    Icons.speed,
                    'Biomass Velocity',
                    '+12.4g / day',
                    'Exceeding baseline by 1.1g/d',
                    '+9.8% Accel'),
                const SizedBox(height: 8),
                _buildDriverCard(
                    Icons.air,
                    'VPD Microclimate Stability',
                    '99.2% window',
                    '0.95 kPa avg (target 0.90–1.05)',
                    'Nominal'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(IconData icon, String title, String desc, String days,
      bool isDone, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCurrent
            ? BotanicalTheme.accentLime.withOpacity(0.18)
            : BotanicalTheme.surfaceContainerLow.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isCurrent
                ? BotanicalTheme.accentGreen
                : isDone
                    ? BotanicalTheme.accentLime
                    : BotanicalTheme.surfaceContainer,
            child: Icon(icon,
                size: 14,
                color: isCurrent ? Colors.white : BotanicalTheme.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: isCurrent
                                ? BotanicalTheme.accentGreen
                                : BotanicalTheme.primaryDark)),
                    Text(days,
                        style: const TextStyle(
                            fontSize: 11, color: BotanicalTheme.textMuted)),
                  ],
                ),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 11, color: BotanicalTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(
      IconData icon, String title, String val, String sub, String badge) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BotanicalTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: BotanicalTheme.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 11, color: BotanicalTheme.textMuted)),
                  Text(val,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: BotanicalTheme.primaryDark)),
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 11,
                          color: BotanicalTheme.accentGreen,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BotanicalTheme.selectedBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(badge,
                style: const TextStyle(
                    color: BotanicalTheme.accentGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class SCurvePainter extends CustomPainter {
  final double progressFactor;

  SCurvePainter({required this.progressFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paintActual = Paint()
      ..color = const Color(0xFF206D00)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintForecast = Paint()
      ..color = const Color(0xFF0099D4)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathActual = Path();
    pathActual.moveTo(0, size.height * 0.95);
    pathActual.cubicTo(
      size.width * 0.25,
      size.height * 0.92,
      size.width * 0.4,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.5,
    );
    canvas.drawPath(pathActual, paintActual);

    final pathForecast = Path();
    pathForecast.moveTo(size.width * 0.5, size.height * 0.5);
    pathForecast.cubicTo(
      size.width * 0.65,
      size.height * 0.25,
      size.width * 0.85,
      size.height * 0.12,
      size.width,
      size.height * 0.1,
    );
    canvas.drawPath(pathForecast, paintForecast);

    // Current point
    final pointPaint = Paint()..color = const Color(0xFF84FE58);
    final borderPaint = Paint()
      ..color = const Color(0xFF206D00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(center, 6, pointPaint);
    canvas.drawCircle(center, 9, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
