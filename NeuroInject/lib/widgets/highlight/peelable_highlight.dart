import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'baked_highlight.dart';

/// The reference scan with a seam the learner can drag across it.
///
/// The highlight normally answers a question nobody asked: it names the muscle
/// before the reader has tried to find it. Dragging the seam left covers the
/// tint again, so the scan can be read cold, named, and then checked — the
/// same screen doing both jobs, with no mode to enter and nothing recorded.
class PeelableHighlight extends StatefulWidget {
  final String scanAsset;
  final String maskAsset;
  final Color accent;

  /// Where the seam starts, as a fraction of width. Defaults to fully
  /// revealed, so a reader who never touches it sees today's behaviour.
  final double initialSeam;

  const PeelableHighlight({
    super.key,
    required this.scanAsset,
    required this.maskAsset,
    required this.accent,
    this.initialSeam = 0.0,
  });

  @override
  State<PeelableHighlight> createState() => _PeelableHighlightState();
}

class _PeelableHighlightState extends State<PeelableHighlight> {
  late double _seam = widget.initialSeam.clamp(0.0, 1.0);
  bool _dragging = false;

  void _setFromDx(double dx, double width) {
    if (width <= 0) return;
    setState(() => _seam = (dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) {
            setState(() => _dragging = true);
            _setFromDx(d.localPosition.dx, w);
          },
          onHorizontalDragUpdate: (d) => _setFromDx(d.localPosition.dx, w),
          onHorizontalDragEnd: (_) => setState(() => _dragging = false),
          onHorizontalDragCancel: () => setState(() => _dragging = false),
          child: Stack(
            children: [
              Positioned.fill(
                child: BakedHighlight(
                  scanAsset: widget.scanAsset,
                  maskAsset: widget.maskAsset,
                  accent: widget.accent,
                  revealFrom: _seam,
                ),
              ),
              // The seam itself is only drawn while it is doing something —
              // a permanent line across every scan would be chrome, not a tool.
              if (_seam > 0.001 && _seam < 0.999) ...[
                Positioned(
                  left: w * _seam - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2, color: AppTheme.textStrong),
                ),
                Positioned(
                  left: w * _seam - 23,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark.withAlpha(_dragging ? 230 : 210),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppTheme.textStrong, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left_rounded,
                              size: 17, color: AppTheme.textStrong),
                          Icon(Icons.chevron_right_rounded,
                              size: 17, color: AppTheme.textStrong),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              Positioned(
                left: 10,
                bottom: 10,
                child: _tag('PLAIN', AppTheme.textSecondary),
              ),
              if (_seam < 0.999)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: _tag('HIGHLIGHTED', widget.accent),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.bgDark.withAlpha(220),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(text,
            style: GoogleFonts.ibmPlexMono(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: color)),
      );
}

/// The two shortcuts that sit under the scan. Separate from the image so the
/// detail screen can place them in its own rhythm.
class PeelControls extends StatelessWidget {
  final VoidCallback onCover;
  final VoidCallback onReveal;
  final bool isDark;

  const PeelControls({
    super.key,
    required this.onCover,
    required this.onReveal,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _button('COVER', onCover)),
      const SizedBox(width: 7),
      Expanded(child: _button('REVEAL', onReveal)),
    ]);
  }

  Widget _button(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
          child: Text(label,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppTheme.textSecondary)),
        ),
      );
}
