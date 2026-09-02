import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// The kind of adjacent structure a danger-zone note refers to, with its
/// semantic colour from the design system. v1 derives this from the existing
/// `dangerZones` text by keyword; precise in-image localisation is a later
/// (v2) ML feature, so these render as a colour-coded reference, not as
/// pixel-anchored markers.
enum StructureKind {
  artery('Artery / vessel', AppTheme.danger),
  nerve('Nerve', AppTheme.amber),
  bone('Bone', Color(0xFF95A5A6)),
  other('Structure', AppTheme.primary);

  const StructureKind(this.label, this.color);
  final String label;
  final Color color;

  /// Classify a danger-zone sentence by the structure it warns about.
  static StructureKind classify(String text) {
    final t = text.toLowerCase();
    if (t.contains('arter') ||
        t.contains('vein') ||
        t.contains('vessel') ||
        t.contains('vascular') ||
        t.contains('pleura')) {
      return StructureKind.artery;
    }
    if (t.contains('nerve') ||
        t.contains('plexus') ||
        t.contains('ganglion')) {
      return StructureKind.nerve;
    }
    if (t.contains('bone') ||
        t.contains('periosteum') ||
        t.contains('cortex') ||
        t.contains('pillar') ||
        t.contains('foramen')) {
      return StructureKind.bone;
    }
    return StructureKind.other;
  }
}

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
