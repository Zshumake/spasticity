import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

import '../../data/cover_fit.dart';
import '../../models/us_annotation.dart';
import '../../theme/app_theme.dart';

/// Renders an ultrasound scan with one muscle tinted, from a mask baked by
/// `tools/refine_highlights.py`.
///
/// Three decisions carry the teaching value here:
///
/// **Luminance is never touched.** The overlay composites with
/// [BlendMode.color], which keeps the destination's luminosity and takes only
/// the source's hue and saturation. Echotexture — the speckle, the pennation,
/// the fascial planes — is what the learner came to read, and a plain alpha
/// wash greys all of it out. Here the muscle simply becomes teal instead of
/// grey, at full contrast.
///
/// **There is no outline.** The baked mask is opaque through the muscle's bulk
/// and fades to nothing before reaching the border. Where fascia is weak the
/// border is genuinely uncertain, so drawing a crisp line would both claim a
/// precision the image cannot support and put every wobble of the original
/// hand-drawn trace on display.
///
/// **The scan and its mask are drawn through one transform.** Both go through a
/// single [CoverFit], which also carries any presentation [crop]. Cropping the
/// scan without cropping its mask is therefore not expressible, which is the
/// invariant that keeps the highlight registered to the anatomy.
class BakedHighlight extends StatefulWidget {
  /// The ultrasound scan, e.g. `assets/images/clinical/<id>-us.jpg`.
  final String scanAsset;

  /// The baked alpha mask, e.g. `assets/images/us_reference/<id>-us.mask.png`.
  /// White RGB with the falloff in the alpha channel.
  final String maskAsset;

  /// Tint colour, stamped with a luminosity-preserving blend so the scan's
  /// echotexture stays fully readable. Defaults to the brand terracotta.
  final Color? accent;

  /// --terracotta-fill from the brand palette (fallback tint).
  static const Color terracotta = Color(0xFFB2502F);

  /// Region-coded highlight tint (decision 2026-08-30): orange for the arm,
  /// blue for the leg, purple for the neck. Upper/lower reuse the app's
  /// groupColor identity so the highlight matches the muscle's cards.
  static Color regionTint(String group) {
    final g = group.toLowerCase();
    if (g.contains('upper')) return const Color(0xFFE5694C);   // arm - orange
    if (g.contains('lower')) return const Color(0xFF3E9BE0);   // leg - blue
    if (g.contains('cervical') || g.contains('neck')) {
      return const Color(0xFF9B6BCB);                          // neck - purple
    }
    if (g.contains('trunk')) return const Color(0xFFD79A3A);   // ochre
    return terracotta;
  }

  /// 0–1 overall strength, for a reveal animation or a learner "show me" toggle.
  final double intensity;

  /// Rectangles, in SOURCE IMAGE pixels, to paint over — the sonographer's
  /// burned-in labels. Empty everywhere except the identify round, where the
  /// label names the muscle being asked about. See tools/export_label_boxes.py.
  final List<Rect> occlude;

  /// Fraction of the width, from the left, left UNTINTED. 0 tints the whole
  /// scan (the default, and what every reference surface uses); 1 shows the
  /// plain scan. Anything between is the peel seam: the learner covers the
  /// answer, names the muscle, then drags back to check.
  final double revealFrom;

  /// Presentation crop in SOURCE IMAGE pixels, or null for the full frame.
  /// Applied to the mask as well, necessarily — see the class doc.
  final Rect? crop;

  /// Lettered structures to draw over the image. Empty on the identify round:
  /// a letter naming the neighbouring muscle would answer the question being
  /// asked, so the caller decides rather than the painter guessing.
  final List<StructureLabel> labels;

  /// [BoxFit.contain] shows the whole frame letterboxed — what the annotator
  /// needs, since you cannot crop what you cannot see. Anything else is the
  /// centre-aligned cover every reading surface uses.
  final BoxFit fit;

  const BakedHighlight({
    super.key,
    required this.scanAsset,
    required this.maskAsset,
    this.accent,
    this.intensity = 1.0,
    this.revealFrom = 0.0,
    this.occlude = const [],
    this.crop,
    this.labels = const [],
    this.fit = BoxFit.cover,
  });

  /// Conventional mask path for a muscle id, matching the bake tool's output.
  static String maskPathFor(String muscleId) =>
      'assets/images/us_reference/$muscleId-us.mask.png';

  @override
  State<BakedHighlight> createState() => _BakedHighlightState();
}

class _BakedHighlightState extends State<BakedHighlight> {
  ui.Image? _scan;
  ui.Image? _mask;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(BakedHighlight old) {
    super.didUpdateWidget(old);
    if (old.scanAsset != widget.scanAsset || old.maskAsset != widget.maskAsset) {
      _scan = _mask = null;
      _failed = false;
      _load();
    }
  }

  Future<ui.Image?> _decode(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    } catch (_) {
      return null; // asset not bundled yet — fall back to the plain scan
    }
  }

  Future<void> _load() async {
    final scan = await _decode(widget.scanAsset);
    final mask = await _decode(widget.maskAsset);
    if (!mounted) return;
    setState(() {
      _scan = scan;
      _mask = mask;
      _failed = scan == null;
    });
  }

  @override
  void dispose() {
    _scan?.dispose();
    _mask?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        color: AppTheme.bgDark,
        alignment: Alignment.center,
        child: Icon(Icons.monitor_heart_outlined,
            size: 34, color: AppTheme.textTertiary),
      );
    }
    final scan = _scan;
    if (scan == null) {
      return Container(color: AppTheme.bgDark);
    }
    return RepaintBoundary(
      child: CustomPaint(
        painter: BakedHighlightPainter(
          scan: scan,
          mask: _mask,
          accent: widget.accent ?? BakedHighlight.terracotta,
          intensity: widget.intensity.clamp(0.0, 1.0),
          revealFrom: widget.revealFrom.clamp(0.0, 1.0),
          occlude: widget.occlude,
          crop: widget.crop,
          labels: widget.labels,
          fit: widget.fit,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Exposed for testing: the compositing is the feature, so it is verified
/// directly rather than through the asset-loading widget around it.
class BakedHighlightPainter extends CustomPainter {
  final ui.Image scan;
  final ui.Image? mask;

  /// Tint stamped into the mask's alpha shape. Required: shipped masks are
  /// colourless (white RGB + alpha), so there is no colour to fall back on.
  final Color accent;
  final double intensity;

  /// See [BakedHighlight.revealFrom].
  final double revealFrom;

  /// See [BakedHighlight.occlude].
  final List<Rect> occlude;

  /// See [BakedHighlight.crop].
  final Rect? crop;

  /// See [BakedHighlight.labels].
  final List<StructureLabel> labels;

  final BoxFit fit;

  const BakedHighlightPainter({
    required this.scan,
    required this.mask,
    required this.accent,
    required this.intensity,
    this.revealFrom = 0.0,
    this.occlude = const [],
    this.crop,
    this.labels = const [],
    required this.fit,
  });

  /// The region of the scan on show: the crop if there is one, else the frame.
  /// Clamped to the image, so a crop authored against a different revision
  /// cannot ask for pixels that do not exist.
  Rect sourceRect() {
    final full =
        Rect.fromLTWH(0, 0, scan.width.toDouble(), scan.height.toDouble());
    final c = crop;
    if (c == null) return full;
    final r = c.intersect(full);
    return (r.width < 1 || r.height < 1) ? full : r;
  }

  /// The one transform. Everything drawn here — both images, the burned-label
  /// occlusion, the letters — is placed through this, which is what keeps them
  /// registered to each other under any crop or box size.
  CoverFit fitFor(Size size) =>
      CoverFit.cropped(size, sourceRect(), contain: fit == BoxFit.contain);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final src = sourceRect();
    final f = fitFor(size);
    final dst = f.destination;

    canvas.save();
    canvas.clipRect(rect);

    canvas.drawImageRect(scan, src, dst,
        Paint()..filterQuality = FilterQuality.medium);

    final m = mask;
    // No tint to draw — but the labels must still be covered, because the
    // untinted state IS the identify question and the label is its answer.
    if (m != null && intensity > 0 && revealFrom < 1.0) {
      // The scan underneath is already painted, so clipping the stamp is all
      // the peel needs: left of the seam stays exactly the plain scan.
      if (revealFrom > 0) {
        canvas.save();
        canvas.clipRect(Rect.fromLTRB(rect.left + rect.width * revealFrom,
            rect.top, rect.right, rect.bottom));
      }

      // Luminosity-preserving stamp: the accent supplies the hue, the scan
      // keeps its own brightness, so the echotexture the learner reads stays at
      // full contrast. A plain semi-transparent fill washes it out.
      canvas.saveLayer(rect, Paint()..blendMode = BlendMode.color);
      final mp = Paint()
        ..colorFilter = ColorFilter.mode(accent, BlendMode.srcIn)
        ..filterQuality = FilterQuality.medium;
      if (intensity < 1) mp.color = Color.fromRGBO(0, 0, 0, intensity);
      canvas.drawImageRect(m, _maskSource(src, m), dst, mp);
      canvas.restore();
      if (revealFrom > 0) canvas.restore();
    }

    _paintOcclusion(canvas, f);
    _paintLabels(canvas, f, size);
    canvas.restore();
  }

  /// The crop expressed in the mask's own pixels.
  ///
  /// Mask and scan are bundled at identical dimensions — the bake tool emits at
  /// source resolution and the import gates it — so this is normally the
  /// identity. Scaling rather than assuming means a mismatched pair degrades to
  /// the old behaviour of fitting each image independently, instead of sliding
  /// the highlight off the muscle.
  Rect _maskSource(Rect src, ui.Image m) {
    if (m.width == scan.width && m.height == scan.height) return src;
    final kx = m.width / scan.width, ky = m.height / scan.height;
    return Rect.fromLTWH(
        src.left * kx, src.top * ky, src.width * kx, src.height * ky);
  }

  void _paintOcclusion(Canvas canvas, CoverFit f) {
    if (occlude.isEmpty) return;
    final paint = Paint()..color = AppTheme.bgDark;
    for (final r in occlude) {
      canvas.drawRect(f.rectToWidget(r), paint);
    }
  }

  /// Letters sit at a fixed size in widget pixels rather than scaling with the
  /// image: they are chrome naming the anatomy, not part of it, and a letter
  /// that shrinks with the panel stops being readable exactly on the phone.
  void _paintLabels(Canvas canvas, CoverFit f, Size size) {
    if (labels.isEmpty) return;
    const r = 10.0;
    for (final l in labels) {
      final c = f.toWidget(l.point);
      if (c.dx < -r || c.dy < -r || c.dx > size.width + r || c.dy > size.height + r) {
        continue;
      }
      // Dark halo first: the puck has to stay legible over bright speckle and
      // over the black surround, and one ring does both.
      canvas.drawCircle(c, r + 1.5, Paint()..color = const Color(0xCC000000));
      canvas.drawCircle(c, r, Paint()..color = l.kind.color);
      final tp = TextPainter(
        text: TextSpan(
          text: l.letter,
          // The same face the key below the scan uses, so a puck and its
          // legend entry read as one label rather than two.
          style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.0),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(BakedHighlightPainter old) =>
      old.scan != scan ||
      old.mask != mask ||
      old.accent != accent ||
      old.intensity != intensity ||
      old.revealFrom != revealFrom ||
      old.occlude != occlude ||
      old.crop != crop ||
      old.labels != labels ||
      old.fit != fit;
}
