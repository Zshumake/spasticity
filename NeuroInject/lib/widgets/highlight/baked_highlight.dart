import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../theme/app_theme.dart';

/// Renders an ultrasound scan with one muscle tinted, from a mask baked by
/// `tools/refine_highlights.py`.
///
/// Two decisions carry the teaching value here:
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

  final BoxFit fit;

  const BakedHighlight({
    super.key,
    required this.scanAsset,
    required this.maskAsset,
    this.accent,
    this.intensity = 1.0,
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

  /// Null = use the colour ramp baked into the mask itself.
  final Color? accent;
  final double intensity;
  final BoxFit fit;

  const BakedHighlightPainter({
    required this.scan,
    required this.mask,
    this.accent,
    required this.intensity,
    required this.fit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    paintImage(canvas: canvas, rect: rect, image: scan, fit: fit);

    final m = mask;
    if (m == null || intensity <= 0) return;

    if (accent == null) {
      // Default: composite the mask's own baked colour ramp with plain alpha
      // blending. The bake keeps the edge partially opaque so its lighter
      // colour is actually VISIBLE - the highlight fades to lighter terracotta
      // toward the border, then feathers out over the last few pixels.
      paintImage(
          canvas: canvas, rect: rect, image: m, fit: fit, opacity: intensity);
      return;
    }
    // Accent override: luminosity-preserving stamp of a uniform colour
    // (used for one-off tints such as marking a vessel).
    canvas.saveLayer(rect, Paint()..blendMode = BlendMode.color);
    paintImage(
      canvas: canvas,
      rect: rect,
      image: m,
      fit: fit,
      colorFilter: ColorFilter.mode(accent!, BlendMode.srcIn),
      opacity: intensity,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(BakedHighlightPainter old) =>
      old.scan != scan ||
      old.mask != mask ||
      old.accent != accent ||
      old.intensity != intensity ||
      old.fit != fit;
}
