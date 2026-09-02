import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import '../models/highlight_capture.dart';

/// Turns accepted [HighlightCapture]s into a COCO instance-segmentation dataset
/// so the training set can leave the app for a model run. Pure Dart — no Flutter
/// or plugin dependencies — so it is trivially testable and portable.
///
/// Each capture becomes one image + one annotation (1:1), because the polygon
/// is stored in the coordinate frame of the canvas it was drawn on; that frame
/// (its [HighlightCapture.canvasSize]) is the image width/height, keeping the
/// segmentation coordinates self-consistent. Captures with fewer than three
/// points are skipped.
class CocoExporter {
  /// Build the COCO dataset map. [categoryName]/[superCategory] resolve a
  /// muscleId to display values (e.g. via the muscle catalogue); both default to
  /// the raw id. [dateEpochMillis] is injected (not read from the clock) so the
  /// output is deterministic and testable.
  static Map<String, dynamic> toCoco(
    List<HighlightCapture> captures, {
    String Function(String muscleId)? categoryName,
    String Function(String muscleId)? superCategory,
    int dateEpochMillis = 0,
  }) {
    final valid =
        captures.where((c) => c.polygon.length >= 3).toList()
          ..sort((a, b) => a.createdAtMillis.compareTo(b.createdAtMillis));

    final muscleIds = valid.map((c) => c.muscleId).toSet().toList()..sort();
    final categoryId = {
      for (var i = 0; i < muscleIds.length; i++) muscleIds[i]: i + 1
    };

    final categories = [
      for (final m in muscleIds)
        {
          'id': categoryId[m],
          'name': categoryName?.call(m) ?? m,
          'supercategory': superCategory?.call(m) ?? 'muscle',
          'muscleId': m,
        }
    ];

    final images = <Map<String, dynamic>>[];
    final annotations = <Map<String, dynamic>>[];
    var imgId = 0;
    var annId = 0;
    for (final c in valid) {
      imgId++;
      annId++;
      images.add({
        'id': imgId,
        'file_name': c.imageRef,
        'width': c.canvasSize.width.round(),
        'height': c.canvasSize.height.round(),
        'capture_id': c.id,
        'date_captured': c.createdAtMillis,
      });
      annotations.add({
        'id': annId,
        'image_id': imgId,
        'category_id': categoryId[c.muscleId],
        'segmentation': [
          [for (final o in c.polygon) ...[_r(o.dx), _r(o.dy)]]
        ],
        'bbox': _bbox(c.polygon),
        'area': _r(_polygonArea(c.polygon)),
        'iscrowd': 0,
      });
    }

    return {
      'info': {
        'description': 'NeuroInject muscle highlight captures',
        'version': '1.0',
        'date_created': dateEpochMillis,
      },
      'licenses': const <Map<String, dynamic>>[],
      'images': images,
      'categories': categories,
      'annotations': annotations,
    };
  }

  /// Pretty-printed COCO JSON string.
  static String toCocoJson(
    List<HighlightCapture> captures, {
    String Function(String muscleId)? categoryName,
    String Function(String muscleId)? superCategory,
    int dateEpochMillis = 0,
  }) =>
      const JsonEncoder.withIndent('  ').convert(toCoco(
        captures,
        categoryName: categoryName,
        superCategory: superCategory,
        dateEpochMillis: dateEpochMillis,
      ));

  static double _r(double v) => (v * 10).roundToDouble() / 10;

  static List<double> _bbox(List<Offset> p) {
    var minX = p.first.dx, minY = p.first.dy, maxX = minX, maxY = minY;
    for (final o in p) {
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
    return [_r(minX), _r(minY), _r(maxX - minX), _r(maxY - minY)];
  }

  static double _polygonArea(List<Offset> p) {
    var a = 0.0;
    for (var i = 0; i < p.length; i++) {
      final j = (i + 1) % p.length;
      a += p[i].dx * p[j].dy - p[j].dx * p[i].dy;
    }
    return a.abs() / 2;
  }
}
