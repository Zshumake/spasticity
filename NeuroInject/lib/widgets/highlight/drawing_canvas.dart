import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/segmentation.dart';
import '../../theme/app_theme.dart';
import 'muscle_overlay_painter.dart';

/// The image + draw layer. It owns the IN-PROGRESS stroke locally and repaints
/// only the canvas (inside a RepaintBoundary, driven by a listenable) as the
/// finger moves — the parent screen is NOT rebuilt per pointer move. The parent
/// keeps the committed [mask] and is notified only on stroke start (to clear the
/// old mask) and stroke complete (to run the segmenter).
class DrawingCanvas extends StatefulWidget {
  final String? imagePath;
  final Color accent;
  final SegmentationResult? mask;

  /// A new stroke began — the parent should clear any committed mask.
  final VoidCallback onStrokeStart;

  /// A stroke finished — the parent refines these points into a mask.
  final void Function(List<Offset>) onStrokeComplete;

  /// Reports the laid-out canvas size (for capture normalisation). Called during
  /// layout — the handler must only store the value, not call setState.
  final ValueChanged<Size>? onSize;

  const DrawingCanvas({
    super.key,
    required this.imagePath,
    required this.accent,
    required this.mask,
    required this.onStrokeStart,
    required this.onStrokeComplete,
    this.onSize,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  // The live stroke is mutated in place; the tick drives painter repaints
  // without any widget rebuild.
  final List<Offset> _live = [];
  final ValueNotifier<int> _tick = ValueNotifier(0);

  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }

  void _start(Offset p) {
    _live
      ..clear()
      ..add(p);
    _tick.value++;
    widget.onStrokeStart();
  }

  void _move(Offset p) {
    _live.add(p);
    _tick.value++;
  }

  void _end() {
    if (_live.length >= 2) widget.onStrokeComplete(List<Offset>.of(_live));
    _live.clear();
    _tick.value++;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: LayoutBuilder(builder: (context, constraints) {
          widget.onSize?.call(constraints.biggest);
          return Stack(
            fit: StackFit.expand,
            children: [
              _background(),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: MuscleOverlayPainter(
                      liveStroke: _live,
                      mask: widget.mask,
                      accent: widget.accent,
                      repaint: _tick,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  gestures: <Type, GestureRecognizerFactory>{
                    _EagerPanRecognizer:
                        GestureRecognizerFactoryWithHandlers<_EagerPanRecognizer>(
                      () => _EagerPanRecognizer(),
                      (r) {
                        r.onStart = (d) => _start(d.localPosition);
                        r.onUpdate = (d) => _move(d.localPosition);
                        r.onEnd = (_) => _end();
                        r.onCancel = _end;
                      },
                    ),
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _background() {
    final path = widget.imagePath;
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

/// A pan that claims the pointer the moment it lands. The canvas sits inside
/// a scrolling list, and a plain pan recognizer has to win the gesture arena
/// against the list's vertical drag: a lasso that starts mostly vertical was
/// scrolling the page mid-outline on iOS. On this surface a touch is always a
/// stroke, so there is nothing to arbitrate.
class _EagerPanRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
