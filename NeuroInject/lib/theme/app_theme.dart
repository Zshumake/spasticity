import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design: "Biomechanical / Anatomical"
/// Warm charcoal surfaces, terracotta accents, clinical warmth.
class AppTheme {
  // ── Core palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFFE17055);      // terracotta
  static const Color primarySoft = Color(0xFFFAB1A0);  // blush
  static const Color primaryDim = Color(0xFFC05A44);   // dark terracotta (light mode)
  static const Color amber = Color(0xFFF9CA24);        // warm gold
  static const Color danger = Color(0xFFEB4D4B);       // arterial red
  static const Color success = Color(0xFF00B894);      // surgical teal
  static const Color patternColor = Color(0xFF6C5CE7); // clinical purple (spasticity patterns)

  // ── Dark mode (default) ───────────────────────────────────────
  static const Color bgDark = Color(0xFF12100E);           // warm charcoal
  static const Color surfaceDark = Color(0xFF1E1B18);      // leather dark
  static const Color surfaceElevated = Color(0xFF2A2521);  // warm raised
  static const Color borderDark = Color(0xFF332E29);       // warm border
  static const Color textPrimary = Color(0xFFF5F0EB);      // warm white
  static const Color textSecondary = Color(0xFF9B8E82);    // warm gray
  static const Color textTertiary = Color(0xFF5C524A);     // muted warm

  // ── Light mode ────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF5F0EB);             // warm cream
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE0D5CC);          // warm beige
  static const Color textPrimaryLight = Color(0xFF1A1512);
  static const Color textSecondaryLight = Color(0xFF7A6E64);

  // ── Light-mode amber (darker for WCAG AA contrast on light bg) ─
  static const Color amberDark = Color(0xFFD4A017);
  static Color amberText(bool isDark) => isDark ? amber : amberDark;

  // ── Orchid (Recent category) ──────────────────────────────────
  static const Color orchid = Color(0xFFD980FA);

  // ── Tertiary text (fixed for light-mode WCAG AA 4.5:1) ────────
  static const Color textTertiaryLight = Color(0xFF6B5F55);

  // ── Radii ─────────────────────────────────────────────────────
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;

  // ── Shared text styles ────────────────────────────────────────
  static TextStyle get monoLabel => GoogleFonts.ibmPlexMono(
        fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.8);

  static TextStyle get displayFont =>
      GoogleFonts.sora(fontWeight: FontWeight.w800, letterSpacing: -0.5);

  static TextStyle get bodyFont => GoogleFonts.sourceSans3();

  // ── Muscle group colors ───────────────────────────────────────
  static Color groupColor(String group) {
    final g = group.toLowerCase();
    if (g.contains('upper')) return const Color(0xFFE17055);   // terracotta
    if (g.contains('lower')) return const Color(0xFF00B894);   // teal
    if (g.contains('trunk')) return const Color(0xFFF9CA24);   // warm gold
    if (g.contains('neck'))  return const Color(0xFFD980FA);   // orchid
    return primary;
  }

  // ═══════════════════════════════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.dark(
        primary: primary, secondary: amber, surface: surfaceDark,
        onSurface: textPrimary, error: danger, outline: borderDark,
        onPrimary: bgDark,
      ),
      textTheme: TextTheme(
        displaySmall: displayFont.copyWith(color: textPrimary, fontSize: 28),
        headlineMedium: displayFont.copyWith(color: textPrimary, fontSize: 22),
        titleLarge: displayFont.copyWith(color: textPrimary, fontSize: 18),
        titleMedium: bodyFont.copyWith(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge: bodyFont.copyWith(color: textPrimary, fontSize: 14, height: 1.6),
        bodyMedium: bodyFont.copyWith(color: textPrimary, fontSize: 13, height: 1.5),
        bodySmall: bodyFont.copyWith(color: textSecondary, fontSize: 12),
        labelLarge: monoLabel.copyWith(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark, elevation: 0,
        scrolledUnderElevation: 0, centerTitle: false,
        iconTheme: IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      dividerColor: borderDark,
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryDim,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.light(
        primary: primaryDim, secondary: amber, surface: surfaceLight,
        onSurface: textPrimaryLight, error: danger, outline: borderLight,
      ),
      textTheme: TextTheme(
        displaySmall: displayFont.copyWith(color: textPrimaryLight, fontSize: 28),
        headlineMedium: displayFont.copyWith(color: textPrimaryLight, fontSize: 22),
        titleLarge: displayFont.copyWith(color: textPrimaryLight, fontSize: 18),
        titleMedium: bodyFont.copyWith(color: textPrimaryLight, fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge: bodyFont.copyWith(color: textPrimaryLight, fontSize: 14, height: 1.6),
        bodyMedium: bodyFont.copyWith(color: textPrimaryLight, fontSize: 13, height: 1.5),
        bodySmall: bodyFont.copyWith(color: textSecondaryLight, fontSize: 12),
        labelLarge: monoLabel.copyWith(color: textSecondaryLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight, elevation: 0,
        scrolledUnderElevation: 0, centerTitle: false,
        iconTheme: IconThemeData(color: primaryDim),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      dividerColor: borderLight,
    );
  }
}

/// Legacy alias so existing widgets using AppColors still compile.
/// New code should use AppTheme directly.
class AppColors {
  static const bgDark = AppTheme.bgDark;
  static const bgCard = AppTheme.surfaceDark;
  static const accentBlue = AppTheme.primary;
  static const textPrimary = AppTheme.textPrimary;
  static const textSecondary = AppTheme.textSecondary;
  static const borderColor = AppTheme.borderDark;
  static const markerRed = AppTheme.danger;
  static const probeTeal = AppTheme.primary;
  static const warningOrange = AppTheme.amber;
  static const successGreen = AppTheme.success;
}
