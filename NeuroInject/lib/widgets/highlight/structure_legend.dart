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
/// colour, with what kind of thing it is.
///
/// The letters and this index are one unit. A letter on the image with no key
/// beside it is a puzzle rather than a label, so this renders wherever the
/// lettered scan does — under the reference panel, and under the enlarged view.
///
/// Laid out as aligned rows rather than a flowing wrap: this is an INDEX, and
/// an index whose entries start at different x positions on every line is
/// harder to scan than the picture it explains. Two columns on a wide surface,
/// one on a phone.
class StructureLetterLegend extends StatelessWidget {
  final List<StructureLabel> labels;

  /// Rendered over the black enlarged view rather than a themed surface.
  final bool onDark;

  /// The eyebrow above the entries. Off inside the annotator, which has its
  /// own section heading.
  final bool showHeader;

  const StructureLetterLegend({
    super.key,
    required this.labels,
    this.onDark = false,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final isDark = onDark || Theme.of(context).brightness == Brightness.dark;
    final nameColor = onDark
        ? AppTheme.textStrong
        : (isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight);
    final kindColor = isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight;
    final sorted = [...labels]..sort((a, b) => a.letter.compareTo(b.letter));

    Widget entry(StructureLabel l) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 19,
              height: 19,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: l.kind.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withAlpha(60)),
              ),
              child: Text(l.letter,
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.name,
                      style: GoogleFonts.sourceSans3(
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: nameColor)),
                  // The colour on the puck means something; say what, once,
                  // rather than leaving the reader to infer it.
                  Text(l.kind.label.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 8.5,
                          letterSpacing: 1.1,
                          color: kindColor)),
                ],
              ),
            ),
          ]),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(children: [
            Icon(Icons.abc, size: 16, color: AppTheme.primary),
            const SizedBox(width: 7),
            Text('STRUCTURES IN THIS VIEW',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: AppTheme.primary)),
          ]),
          const SizedBox(height: 10),
        ],
        LayoutBuilder(builder: (context, box) {
          // Two columns once there is room for them; one on a phone.
          final columns = box.maxWidth >= 420 ? 2 : 1;
          if (columns == 1) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final l in sorted) entry(l)]);
          }
          final half = (sorted.length + 1) ~/ 2;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final l in sorted.take(half)) entry(l)]),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final l in sorted.skip(half)) entry(l)]),
            ),
          ]);
        }),
      ],
    );
  }
}
