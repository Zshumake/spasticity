import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design: "Biomechanical / Anatomical"
/// Warm charcoal surfaces, terracotta accents, clinical warmth.
class AppTheme {
  // ── Core palette (NeuroInject Design System — cool, clinical) ──
  // Re-grounded from the design-system bundle: one restrained terracotta
  // "clay" accent reading as a single signal against cool blue-steel slate.
  // Neutrals never warm. Dark is default; light is the cool-daylight alternate.
  static const Color primary = Color(0xFFE5694C);      // clay-bright (accent on dark)
  static const Color primarySoft = Color(0xFFF0BFAF);  // clay-200 (blush)
  static const Color primaryDim = Color(0xFFD5604A);   // clay-500 (accent on light)
  static const Color amber = Color(0xFFEBC04A);        // gold-300 — caution / pearls
  static const Color danger = Color(0xFFE04A3F);       // red-500 — arterial / avoid
  static const Color success = Color(0xFF18A98A);      // teal-500 — safe
  static const Color patternColor = Color(0xFF6C5CE7); // indigo — spasticity patterns

  // ── Dark mode (default — cool near-black slate) ───────────────
  static const Color bgDark = Color(0xFF090B0F);           // ink-900 canvas
  static const Color surfaceDark = Color(0xFF10151C);      // surface (card/panel)
  static const Color surfaceElevated = Color(0xFF141A22);  // ink-800 raised
  static const Color borderDark = Color(0xFF212A35);       // ink-700 hairline
  static const Color textStrong = Color(0xFFEDF1F6);       // headings
  static const Color textPrimary = Color(0xFFDBE2EA);      // body
  static const Color textSecondary = Color(0xFF97A2B0);    // secondary
  static const Color textTertiary = Color(0xFF66717F);     // tertiary / eyebrow

  // ── Light mode (cool daylight alternate) ──────────────────────
  static const Color bgLight = Color(0xFFEFF2F6);             // ink-50 canvas
  static const Color surfaceLight = Color(0xFFFFFFFF);        // paper
  static const Color borderLight = Color(0xFFCAD2DC);         // ink-200 hairline
  static const Color textStrongLight = Color(0xFF131922);     // headings
  static const Color textPrimaryLight = Color(0xFF283039);    // body
  static const Color textSecondaryLight = Color(0xFF5B6573);

  // ── Light-mode caution (darker gold for WCAG AA on light bg) ──
  static const Color amberDark = Color(0xFFC8920E);  // gold-500
  static Color amberText(bool isDark) => isDark ? amber : amberDark;

  // ── Orchid (Recent category — UI affordance, non-clinical) ────
  static const Color orchid = Color(0xFFD980FA);

  // ── Tertiary text (light, WCAG AA) ────────────────────────────
  static const Color textTertiaryLight = Color(0xFF8893A1);

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

  // ── Anatomical region colors (design-system region system) ────
  // Each region owns one color. Check 'face' before 'neck' because the
  // "Face / Neck" group string contains both.
  static Color groupColor(String group) {
    final g = group.toLowerCase();
    if (g.contains('upper')) return const Color(0xFFE5694C);   // clay
    if (g.contains('lower')) return const Color(0xFF3E9BE0);   // clinical blue
    if (g.contains('trunk')) return const Color(0xFFD79A3A);   // ochre
    if (g.contains('face'))  return const Color(0xFFB06B9E);   // plum
    if (g.contains('neck') || g.contains('cervical')) {
      return const Color(0xFF18A98A);                          // teal
    }
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
        displaySmall: displayFont.copyWith(color: textStrong, fontSize: 28),
        headlineMedium: displayFont.copyWith(color: textStrong, fontSize: 22),
        titleLarge: displayFont.copyWith(color: textStrong, fontSize: 18),
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
        displaySmall: displayFont.copyWith(color: textStrongLight, fontSize: 28),
        headlineMedium: displayFont.copyWith(color: textStrongLight, fontSize: 22),
        titleLarge: displayFont.copyWith(color: textStrongLight, fontSize: 18),
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
