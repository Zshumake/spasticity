import 'package:flutter/material.dart' show Color;

import '../theme/app_theme.dart';

/// The kind of anatomical structure a note or an on-image letter refers to,
/// with its semantic colour from the design system.
///
/// Two surfaces share this vocabulary deliberately. [classify] derives a kind
/// from a written danger-zone sentence, which is a keyword guess and is only
/// ever as good as the prose. An authored structure letter carries its kind
/// explicitly, because someone looked at the image and chose it. One vocabulary
/// means the legend beside a scan and the legend beside its hazards colour the
/// same structure the same way.
enum StructureKind {
  artery('Artery / vessel', AppTheme.danger),
  nerve('Nerve', AppTheme.amber),
  bone('Bone', Color(0xFF95A5A6)),

  /// Only ever set explicitly on an authored label — [classify] never returns
  /// it, because a hazard sentence naming a muscle is naming a landmark, not a
  /// thing to avoid.
  muscle('Muscle', AppTheme.success),
  other('Structure', AppTheme.primary);

  const StructureKind(this.label, this.color);
  final String label;
  final Color color;

  /// Stable key for the annotations file. Parsing is tolerant: an unknown or
  /// missing kind reads as [other] rather than failing the load, so a
  /// hand-edited file cannot blank a scan's letters.
  String get key => name;

  static StructureKind fromKey(String? key) {
    for (final k in StructureKind.values) {
      if (k.name == key) return k;
    }
    return StructureKind.other;
  }

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
