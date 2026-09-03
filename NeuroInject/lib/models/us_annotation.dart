import 'dart:ui';

import 'structure_kind.dart';

/// A lettered point on an ultrasound scan, naming a structure around the
/// target: the neighbouring muscles, the vessel, the nerve, the bone.
///
/// The teaching gap this closes: a scan carries exactly one highlighted muscle,
/// so everything else in the frame is unnamed. The prose names those structures
/// but cannot point at them, and "the median nerve sits in the fascial plane
/// between FDS and FDP" only helps a reader who can already find all three.
///
/// COORDINATES ARE SOURCE-IMAGE PIXELS, never widget or normalised
/// coordinates. That is what lets a letter survive the display size, the peel
/// seam, a presentation crop and the zoom view without moving relative to the
/// anatomy — the same convention `us-label-boxes.json` already uses for the
/// burned-label rectangles.
class StructureLabel {
  /// The letter drawn on the image: 'A', 'B', 'C'. Unique within a scan.
  final String letter;

  /// What the letter names, as it appears in the legend.
  final String name;

  final StructureKind kind;

  /// Position in SOURCE IMAGE PIXELS.
  final Offset point;

  const StructureLabel({
    required this.letter,
    required this.name,
    required this.kind,
    required this.point,
  });

  StructureLabel copyWith({
    String? letter,
    String? name,
    StructureKind? kind,
    Offset? point,
  }) =>
      StructureLabel(
        letter: letter ?? this.letter,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        point: point ?? this.point,
      );

  Map<String, dynamic> toJson() => {
        'letter': letter,
        'name': name,
        'kind': kind.key,
        'x': _round(point.dx),
        'y': _round(point.dy),
      };

  static StructureLabel? fromJson(Map<String, dynamic> j) {
    final x = j['x'], y = j['y'];
    if (x is! num || y is! num) return null;
    final letter = (j['letter'] as String?)?.trim();
    if (letter == null || letter.isEmpty) return null;
    return StructureLabel(
      letter: letter,
      name: (j['name'] as String?)?.trim() ?? '',
      kind: StructureKind.fromKey(j['kind'] as String?),
      point: Offset(x.toDouble(), y.toDouble()),
    );
  }
}

/// Everything authored over one ultrasound scan.
///
/// Keyed by the scan's file name rather than by muscle, because a scan is
/// SHARED — one transverse view carries gastrocnemius and soleus, or all three
/// adductors — and the structures in the frame are the same picture whichever
/// muscle you arrived from. Keying on the muscle would mean authoring the same
/// letters two or three times and letting them drift apart.
class ScanAnnotation {
  /// Presentation crop in SOURCE IMAGE PIXELS, or null for the full frame.
  ///
  /// Applied to the scan AND its mask through one transform, so cropping can
  /// never pull the highlight out of registration. Cropping is presentation
  /// only: no file is ever re-cut, the scans keep their chrome and burned
  /// labels on disk, and clearing the crop restores the full frame.
  final Rect? crop;

  final List<StructureLabel> labels;

  const ScanAnnotation({this.crop, this.labels = const []});

  bool get isEmpty => crop == null && labels.isEmpty;

  ScanAnnotation copyWith({Rect? crop, bool clearCrop = false, List<StructureLabel>? labels}) =>
      ScanAnnotation(
        crop: clearCrop ? null : (crop ?? this.crop),
        labels: labels ?? this.labels,
      );

  /// The next unused letter, so authoring is one tap rather than a decision.
  String get nextLetter {
    final used = labels.map((l) => l.letter.toUpperCase()).toSet();
    for (var c = 65; c <= 90; c++) {
      final s = String.fromCharCode(c);
      if (!used.contains(s)) return s;
    }
    return '?';
  }

  Map<String, dynamic> toJson() => {
        if (crop != null)
          'crop': [
            _round(crop!.left),
            _round(crop!.top),
            _round(crop!.width),
            _round(crop!.height),
          ],
        'labels': [for (final l in labels) l.toJson()],
      };

  static ScanAnnotation fromJson(Map<String, dynamic> j) {
    Rect? crop;
    final c = j['crop'];
    if (c is List && c.length == 4 && c.every((v) => v is num)) {
      final w = (c[2] as num).toDouble(), h = (c[3] as num).toDouble();
      if (w > 0 && h > 0) {
        crop = Rect.fromLTWH(
            (c[0] as num).toDouble(), (c[1] as num).toDouble(), w, h);
      }
    }
    final raw = j['labels'];
    final labels = <StructureLabel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          final l = StructureLabel.fromJson(e);
          if (l != null) labels.add(l);
        }
      }
    }
    return ScanAnnotation(crop: crop, labels: labels);
  }
}

/// Rounded to whole pixels: the coordinate space IS pixels, and a stored
/// fraction is noise that makes two authored files differ for no reason.
num _round(double v) => v.roundToDouble() == v ? v.round() : double.parse(v.toStringAsFixed(1));
