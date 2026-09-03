import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/structure_kind.dart';
import '../../models/us_annotation.dart';
import '../../theme/app_theme.dart';

export '../../models/structure_kind.dart' show StructureKind;

/// Colour-coded "what to avoid" panel, populated from a muscle's [dangerZones].
class StructureLegend extends StatelessWidget {
  final List<String> dangerZones;

  const StructureLegend({super.key, required this.dangerZones});

  @override
  Widget build(BuildContext context) {
    if (dangerZones.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.gpp_maybe_outlined,
              size: 14, color: AppTheme.danger),
          const SizedBox(width: 8),
          Text('ADJACENT STRUCTURES — WHAT TO AVOID',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppTheme.danger)),
        ]),
        const SizedBox(height: 10),
        ...dangerZones.map((z) {
          final kind = StructureKind.classify(z);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 5, right: 10),
                decoration:
                    BoxDecoration(color: kind.color, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(z,
                    style: GoogleFonts.sourceSans3(
                        fontSize: 12.5, height: 1.4, color: textColor)),
              ),
            ]),
          );
        }),
      ],
    );
  }
}

/// The key to the letters drawn on a scan: `A  Soleus`, in the structure's own
/// colour.
///
/// The letters and this legend are one unit. A letter on the image with no key
/// beside it is a puzzle rather than a label, so this renders wherever the
/// lettered scan does.
class StructureLetterLegend extends StatelessWidget {
  final List<StructureLabel> labels;

  const StructureLetterLegend({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;
    final sorted = [...labels]..sort((a, b) => a.letter.compareTo(b.letter));

    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (final l in sorted)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 17,
              height: 17,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: l.kind.color, shape: BoxShape.circle),
              child: Text(l.letter,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const SizedBox(width: 6),
            Text(l.name,
                style: GoogleFonts.sourceSans3(
                    fontSize: 12.5, color: textColor)),
          ]),
      ],
    );
  }
}
