import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// The three hazard layers, grouped by WHEN the injector reads them.
///
/// The corpus carries three of them — [Muscle.sideEffects] (what the toxin
/// does), [Muscle.dangerZones] (adjacent structures the needle can hit) and
/// ultrasound safety notes (scanning caution). Rendered as three identical
/// amber callouts they stacked into one undifferentiated wall of warnings,
/// which is how a reader learns to skim past all of them.
///
/// They are not the same kind of thing, and the distinction that matters is
/// not which field they came from — it is the moment they are used. Side
/// effects are consent material: read beforehand, out loud, to the patient.
/// Needle hazards are read during the procedure, silently, with a probe in
/// hand. So they group BEFORE and DURING, and each colour means one thing:
/// orchid for counselling, danger red for vascular, amber for scanning.
class SafetyLayers extends StatelessWidget {
  /// Consent material — what weakening this muscle does, and what spread does.
  final List<String> sideEffects;

  /// Adjacent structures the needle can hit.
  final List<String> dangerZones;

  /// Scanning caution from the ultrasound guide.
  final List<String> scanningNotes;

  /// Procedure mode drops the section eyebrows, which the caller supplies.
  final bool compact;

  const SafetyLayers({
    super.key,
    this.sideEffects = const [],
    this.dangerZones = const [],
    this.scanningNotes = const [],
    this.compact = false,
  });

  bool get isEmpty =>
      sideEffects.isEmpty && dangerZones.isEmpty && scanningNotes.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sideEffects.isNotEmpty) ...[
          if (!compact) _phase('Before — counsel the patient', AppTheme.orchid),
          _card(
            isDark: isDark,
            accent: AppTheme.orchid,
            label: 'What weakening this muscle does',
            items: sideEffects,
            outlined: false,
          ),
        ],
        if (sideEffects.isNotEmpty &&
            (dangerZones.isNotEmpty || scanningNotes.isNotEmpty))
          const SizedBox(height: 18),
        if (dangerZones.isNotEmpty || scanningNotes.isNotEmpty) ...[
          if (!compact) _phase('During — at the needle', AppTheme.danger),
          // Vascular first: it is the one that changes what you do next.
          if (dangerZones.isNotEmpty)
            _card(
              isDark: isDark,
              accent: AppTheme.danger,
              label: 'What the needle can hit',
              items: dangerZones,
              outlined: true,
            ),
          if (dangerZones.isNotEmpty && scanningNotes.isNotEmpty)
            const SizedBox(height: 8),
          if (scanningNotes.isNotEmpty)
            _card(
              isDark: isDark,
              accent: AppTheme.amber,
              label: 'Scanning',
              items: scanningNotes,
              outlined: false,
            ),
        ],
      ],
    );
  }

  Widget _phase(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: accent.withAlpha(28),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm + 1),
            border: Border.all(color: accent.withAlpha(70)),
          ),
          child: Icon(Icons.add_rounded, size: 12, color: accent),
        ),
        const SizedBox(width: 9),
        Text(text.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: accent)),
      ]),
    );
  }

  Widget _card({
    required bool isDark,
    required Color accent,
    required String label,
    required List<String> items,
    required bool outlined,
  }) {
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final border = outlined
        ? accent.withAlpha(90)
        : (isDark ? AppTheme.borderDark : AppTheme.borderLight);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(label.toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: accent)),
            ),
          ]),
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(top: item == items.first ? 7 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item != items.first)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Container(
                          height: 1,
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight),
                    ),
                  Text(item,
                      style: GoogleFonts.sourceSans3(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark
                              ? AppTheme.textPrimary
                              : AppTheme.textPrimaryLight)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
