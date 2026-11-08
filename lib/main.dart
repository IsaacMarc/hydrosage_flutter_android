import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/botanical_theme.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/almanac_screen.dart';
import 'screens/recent_scans_screen.dart';

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
  runApp(const LeafifyApp());
}

class LeafifyApp extends StatelessWidget {
  const LeafifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leafify',
      debugShowCheckedModeBanner: false,
      theme: BotanicalTheme.themeData,
      home: const MainNavigationShell(),
    );
  }
}

// Backward compatibility alias
typedef HydroSageApp = LeafifyApp;

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 1});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DiagnosticsScreen(),
      const AlmanacScreen(),
      RecentScansScreen(
        onSwitchToDiagnostics: () => _switchTab(0),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: BotanicalTheme.bgSurface.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A2E23).withValues(alpha: 0.06),
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
                _buildNavItem(
                    0, Icons.camera_alt_outlined, Icons.camera_alt, 'Diagnose'),
                _buildNavItem(
                    1, Icons.menu_book_outlined, Icons.menu_book, 'Almanac'),
                _buildNavItem(
                    2, Icons.history_outlined, Icons.history, 'History'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData outlineIcon, IconData filledIcon, String label) {
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                size: 18,
                color: isSelected
                    ? BotanicalTheme.primaryDark
                    : BotanicalTheme.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                    ? BotanicalTheme.primaryDark
                    : BotanicalTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
