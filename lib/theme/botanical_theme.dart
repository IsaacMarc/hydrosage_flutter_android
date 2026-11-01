import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotanicalTheme {
  // Botanical Tactile Color Palette
  static const Color primaryDark = Color(0xFF001810);
  static const Color primaryContainer = Color(0xFF0A2E23);
  static const Color accentGreen = Color(0xFF38B000);
  static const Color accentLime = Color(0xFF84FE58);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color bgSurface = Color(0xFFF9F9F6);
  static const Color surfaceContainerLow = Color(0xFFF4F4F1);
  static const Color surfaceContainer = Color(0xFFEEEEEB);
  static const Color cardBg = Colors.white;
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color selectedBg = Color(0xFFE8F6ED);
  static const Color textMuted = Color(0xFF606A63);
  static const Color onSurface = Color(0xFF1A1C1B);
  static const Color tertiaryBlue = Color(0xFF0099D4);

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: bgSurface,
      fontFamily: GoogleFonts.inter().fontFamily,
      primaryColor: primaryContainer,
      colorScheme: const ColorScheme.light(
        primary: primaryContainer,
        secondary: accentLime,
        surface: bgSurface,
        onPrimary: Colors.white,
        onSurface: onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryContainer),
      ),
    );
  }
}
