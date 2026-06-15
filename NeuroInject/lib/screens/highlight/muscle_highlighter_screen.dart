import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/highlight_capture_store.dart';
import '../../models/clinical_photo.dart';
import '../../models/highlight_capture.dart';
import '../../models/muscle.dart';
import '../../models/segmentation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/highlight/drawing_canvas.dart';
import '../../widgets/highlight/structure_legend.dart';

/// v1 "draw → highlight" surface. The clinician lassos a muscle on its US image;
/// a [MuscleSegmenter] refines the drawing into a mask; the overlay shows a slick
/// highlight plus the muscle's adjacent-structure reference from its danger zones.
///
/// The segmenter is a [PolygonStubSegmenter] for now (the drawing is the mask).
/// A MobileSAM / Core ML segmenter will replace it behind the same interface,
/// and "Accept" will persist the (image, mask, muscleId) example that trains it.
class MuscleHighlighterScreen extends StatefulWidget {
  final Muscle muscle;
  const MuscleHighlighterScreen({super.key, required this.muscle});

  @override
  State<MuscleHighlighterScreen> createState() =>
      _MuscleHighlighterScreenState();
}

class _MuscleHighlighterScreenState extends State<MuscleHighlighterScreen> {
  // TODO(seg): inject a real MuscleSegmenter (MobileSAM via Core ML/LiteRT).
  final MuscleSegmenter _segmenter = const PolygonStubSegmenter();

  List<Offset> _live = const [];
  SegmentationResult? _mask;
  bool _refining = false;
  Size _canvasSize = Size.zero;

  Muscle get muscle => widget.muscle;

  String get _usImagePath =>
      muscle.clinicalPhotoPath(ClinicalPhotoSlot.ultrasound);

  void _onPanStart(Offset p) => setState(() {
        _live = [p];
        _mask = null;
      });

  void _onPanUpdate(Offset p) => setState(() => _live = [..._live, p]);

  Future<void> _onPanEnd() async {
    final stroke = _live;
    setState(() => _refining = true);
    final result = await _segmenter.refine(
      SegmentationInput(strokes: [stroke], canvasSize: _canvasSize),
    );
    if (!mounted) return;
    setState(() {
      _mask = result.isEmpty ? null : result;
      _live = const [];
      _refining = false;
    });
  }

  void _clear() => setState(() {
        _live = const [];
        _mask = null;
      });

  void _accept() {
    final m = _mask;
    if (m == null) return;
    final now = DateTime.now();
    // TODO(data): the store is a JSON-in-prefs scaffold. Move to an encrypted
    // on-device store before capturing live US frames (PHI). The captured
    // (image, mask, muscleId) examples are the v1.5 LoRA training feed.
    final store = context.read<HighlightCaptureStore>();
    store.add(HighlightCapture(
      id: 'cap_${now.microsecondsSinceEpoch}',
      muscleId: muscle.id,
      imageRef: _usImagePath,
      polygon: m.polygon,
      canvasSize: _canvasSize,
      createdAtMillis: now.millisecondsSinceEpoch,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Saved highlight #${store.countFor(muscle.id)} for ${muscle.name}'),
      behavior: SnackBarBehavior.floating,
    ));
    setState(() {
      _mask = null;
      _live = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppTheme.groupColor(muscle.group);
    final hasMask = _mask != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(muscle.name,
                style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            Text('HIGHLIGHT · ULTRASOUND',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 1.6,
                    color: AppTheme.primary)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _instruction(isDark),
          const SizedBox(height: 12),
          DrawingCanvas(
            imagePath: _usImagePath,
            accent: accent,
            liveStroke: _live,
            mask: _mask,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onSize: (s) => _canvasSize = s,
          ),
          const SizedBox(height: 12),
          _toolbar(hasMask),
          const SizedBox(height: 10),
          _savedCount(),
          const SizedBox(height: 16),
          StructureLegend(dangerZones: muscle.dangerZones),
        ],
      ),
    );
  }

  Widget _instruction(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(isDark ? 20 : 14),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.primary.withAlpha(40)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.gesture, size: 15, color: AppTheme.primary.withAlpha(200)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'Draw a loose outline around the muscle. The model tightens it to '
            'the border — you don\'t have to be precise.',
            style: GoogleFonts.sourceSans3(
                fontSize: 12,
                height: 1.4,
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondaryLight),
          ),
        ),
      ]),
    );
  }

  Widget _savedCount() {
    final n = context.watch<HighlightCaptureStore>().countFor(muscle.id);
    if (n == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => context.push('/captures'),
      behavior: HitTestBehavior.opaque,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.dataset_outlined, size: 13, color: AppTheme.success),
        const SizedBox(width: 6),
        Text(
          '$n highlight${n == 1 ? '' : 's'} saved for this muscle · view all',
          style: GoogleFonts.ibmPlexMono(
              fontSize: 9.5, letterSpacing: 0.4, color: AppTheme.textTertiary),
        ),
        const SizedBox(width: 3),
        const Icon(Icons.chevron_right, size: 13, color: AppTheme.textTertiary),
      ]),
    );
  }

  Widget _toolbar(bool hasMask) {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: (hasMask || _live.isNotEmpty) ? _clear : null,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Clear'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
            side: const BorderSide(color: AppTheme.borderDark),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton.icon(
          onPressed: hasMask && !_refining ? _accept : null,
          icon: _refining
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check, size: 18),
          label: const Text('Accept'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    ]);
  }
}
