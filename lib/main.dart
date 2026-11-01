import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/botanical_theme.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/forecasting_screen.dart';
import 'screens/add_crop_forecast_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: BotanicalTheme.bgSurface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const HydroSageApp());
}

class HydroSageApp extends StatelessWidget {
  const HydroSageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroSage AI',
      debugShowCheckedModeBanner: false,
      theme: BotanicalTheme.themeData,
      home: const MainNavigationShell(),
      routes: {
        '/add-crop': (context) => const AddCropForecastScreen(),
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 1; // Default to Forecasting or Diagnostics

  final List<Widget> _screens = const [
    DiagnosticsScreen(),
    ForecastingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: BotanicalTheme.bgSurface.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A2E23).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: BotanicalTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildNavItem(0, Icons.favorite_border, Icons.favorite, 'Diagnostics'),
                _buildNavItem(1, Icons.show_chart, Icons.ssid_chart, 'Forecasting'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? filledIcon : outlineIcon,
                size: 19,
                color: isSelected ? BotanicalTheme.primaryDark : BotanicalTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? BotanicalTheme.primaryDark : BotanicalTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
