import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/segmentation.dart';
import '../../theme/app_theme.dart';
import 'muscle_overlay_painter.dart';

/// The image + draw layer. A "dumb" widget: it shows the US image (or a
/// placeholder), paints the current stroke + committed mask, and forwards raw
/// pan events (in canvas-local coordinates) up to the screen, which owns the
/// drawing state and the segmenter. Unidirectional flow keeps Clear/Accept simple.
class DrawingCanvas extends StatelessWidget {
  final String? imagePath;
  final Color accent;
  final List<Offset> liveStroke;
  final SegmentationResult? mask;
  final void Function(Offset) onPanStart;
  final void Function(Offset) onPanUpdate;
  final VoidCallback onPanEnd;

  /// Reports the laid-out canvas size so captured polygons carry the frame
  /// they were drawn on (for later normalisation). Called during layout — the
  /// handler must only store the value, not call setState.
  final ValueChanged<Size>? onSize;

  const DrawingCanvas({
    super.key,
    required this.imagePath,
    required this.accent,
    required this.liveStroke,
    required this.mask,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: LayoutBuilder(builder: (context, constraints) {
          onSize?.call(constraints.biggest);
          return Stack(
            fit: StackFit.expand,
            children: [
              _background(),
              Positioned.fill(
                child: CustomPaint(
                  painter: MuscleOverlayPainter(
                      liveStroke: liveStroke, mask: mask, accent: accent),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) => onPanStart(d.localPosition),
                  onPanUpdate: (d) => onPanUpdate(d.localPosition),
                  onPanEnd: (_) => onPanEnd(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _background() {
    final path = imagePath;
    if (path == null) return _placeholder();
    return Image.asset(path, fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder());
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.bgDark,
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.monitor_heart_outlined,
            size: 34, color: AppTheme.textTertiary),
        const SizedBox(height: 10),
        Text('No ultrasound image yet',
            style: GoogleFonts.ibmPlexMono(
                fontSize: 10,
                letterSpacing: 1.2,
                color: AppTheme.textTertiary)),
        const SizedBox(height: 4),
        Text('Draw on the canvas to test the highlight',
            style: GoogleFonts.sourceSans3(
                fontSize: 11, color: AppTheme.textTertiary)),
      ]),
    );
  }
}
