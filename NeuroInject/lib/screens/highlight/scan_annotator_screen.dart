import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/coco_download.dart';
import '../../data/cover_fit.dart';
import '../../data/us_annotation_store.dart';
import '../../models/us_annotation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/highlight/baked_highlight.dart';
import '../../widgets/highlight/structure_legend.dart';
import '../../widgets/ios_ui.dart';

/// Author mode for one ultrasound scan: letter the surrounding structures, and
/// set how the frame is cropped for presentation.
///
/// WHY IT IS PER SCAN, NOT PER MUSCLE. A scan is shared by up to three muscles,
/// and the structures in the frame do not change with the muscle you arrived
/// from. Authoring here writes once and every muscle on that view shows it.
///
/// WHY THE WHOLE FRAME IS ALWAYS VISIBLE HERE. The reading surfaces render the
/// crop; this screen renders the full frame with the crop drawn as an overlay,
/// because you cannot judge a cut you cannot see past. Nothing on disk is ever
/// re-cut: the crop is four numbers, applied at paint time, and clearing it
/// restores the frame.
class ScanAnnotatorScreen extends StatefulWidget {
  final String scanAsset;
  final String maskAsset;
  final Color accent;

  /// Shown in the app bar so the author knows which view they are on.
  final String title;

  const ScanAnnotatorScreen({
    super.key,
    required this.scanAsset,
    required this.maskAsset,
    required this.accent,
    required this.title,
  });

  @override
  State<ScanAnnotatorScreen> createState() => _ScanAnnotatorScreenState();
}

enum _Mode { letters, crop }

enum _Grab { none, label, cropMove, cropTL, cropTR, cropBL, cropBR }

class _ScanAnnotatorScreenState extends State<ScanAnnotatorScreen> {
  ui.Image? _image;
  ScanAnnotation _a = const ScanAnnotation();
  _Mode _mode = _Mode.letters;

  _Grab _grab = _Grab.none;
  int _grabbed = -1;
  Offset _grabOffset = Offset.zero;
  Rect? _cropAtDragStart;
  bool _dirty = false;

  Size get _imageSize => _image == null
      ? Size.zero
      : Size(_image!.width.toDouble(), _image!.height.toDouble());
  Rect get _fullFrame => Offset.zero & _imageSize;

  @override
  void initState() {
    super.initState();
    _a = context.read<UsAnnotationStore>().forScan(widget.scanAsset);
    _decode();
  }

  Future<void> _decode() async {
    try {
      final data = await rootBundle.load(widget.scanAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final img = (await codec.getNextFrame()).image;
      if (!mounted) return;
      setState(() => _image = img);
    } catch (_) {
      if (mounted) setState(() => _image = null);
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  CoverFit _fit(Size box) =>
      CoverFit.cropped(box, _fullFrame, contain: true);

  // ----------------------------------------------------------------- editing

  void _mutate(ScanAnnotation next) => setState(() {
        _a = next;
        _dirty = true;
      });

  int _labelAt(Offset local, CoverFit f) {
    for (var i = _a.labels.length - 1; i >= 0; i--) {
      if ((f.toWidget(_a.labels[i].point) - local).distance <= 20) return i;
    }
    return -1;
  }

  Future<void> _addLabelAt(Offset src) async {
    final draft = StructureLabel(
      letter: _a.nextLetter,
      name: '',
      kind: StructureKind.muscle,
      point: src,
    );
    final result = await _editLabel(draft, isNew: true);
    if (result == null) return;
    _mutate(_a.copyWith(labels: [..._a.labels, result]));
  }

  Future<void> _editExisting(int i) async {
    final result = await _editLabel(_a.labels[i], isNew: false);
    if (result == null) return;
    final next = [..._a.labels];
    next[i] = result;
    _mutate(_a.copyWith(labels: next));
  }

  void _deleteLabel(int i) {
    final next = [..._a.labels]..removeAt(i);
    _mutate(_a.copyWith(labels: next));
  }

  /// Returns the edited label, or null if the author backed out. Deleting pops
  /// with null after mutating, which is why the caller re-reads from state.
  Future<StructureLabel?> _editLabel(StructureLabel l, {required bool isNew}) {
    final controller = TextEditingController(text: l.name);
    var kind = l.kind;
    return showModalBottomSheet<StructureLabel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return StatefulBuilder(builder: (sheetContext, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXl)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.textTertiary,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: kind.color, shape: BoxShape.circle),
                    child: Text(l.letter,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: isNew,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Structure',
                        hintText: 'e.g. Soleus, Tibial nerve',
                        isDense: true,
                      ),
                      onSubmitted: (_) => Navigator.of(sheetContext).pop(
                          l.copyWith(name: controller.text.trim(), kind: kind)),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final k in StructureKind.values)
                      ChoiceChip(
                        label: Text(k.label),
                        selected: kind == k,
                        avatar: CircleAvatar(
                            backgroundColor: k.color, radius: 7),
                        onSelected: (_) => setSheet(() => kind = k),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(children: [
                  if (!isNew)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        final i = _a.labels.indexOf(l);
                        if (i >= 0) _deleteLabel(i);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style:
                          TextButton.styleFrom(foregroundColor: AppTheme.danger),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(
                        l.copyWith(name: controller.text.trim(), kind: kind)),
                    child: Text(isNew ? 'Add' : 'Save'),
                  ),
                ]),
              ]),
            ),
          );
        });
      },
    );
  }

  // -------------------------------------------------------------------- crop

  Rect get _crop => _a.crop ?? _fullFrame;

  void _setCrop(Rect? r) => _mutate(
      r == null ? _a.copyWith(clearCrop: true) : _a.copyWith(crop: r));

  /// Bounding box of everything that is not letterbox black.
  ///
  /// A starting point, not an answer: it removes the dead margin the machine
  /// pads the frame with, and leaves the author to decide how much chrome to
  /// keep. Deliberately conservative — it will include the SonoSite footer,
  /// because guessing which bright pixels are text and which are anatomy is
  /// exactly the judgement this screen exists to leave with a person.
  Future<void> _autoTrim() async {
    final img = _image;
    if (img == null) return;
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null || !mounted) return;
    final b = data.buffer.asUint8List();
    final w = img.width, h = img.height;
    int minX = w, minY = h, maxX = -1, maxY = -1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = (y * w + x) * 4;
        // Rec. 601 luma, cheap and good enough to find the dead margin.
        final lum = (b[i] * 299 + b[i + 1] * 587 + b[i + 2] * 114) ~/ 1000;
        if (lum > 24) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    if (maxX <= minX || maxY <= minY) return;
    _setCrop(Rect.fromLTRB(minX.toDouble(), minY.toDouble(),
        (maxX + 1).toDouble(), (maxY + 1).toDouble()));
    if (mounted) showAppSnack(context, 'Trimmed to the non-black frame — adjust from here');
  }

  Rect _clampCrop(Rect r) {
    const minSide = 40.0;
    var out = Rect.fromLTRB(
      r.left.clamp(0.0, _imageSize.width - minSide),
      r.top.clamp(0.0, _imageSize.height - minSide),
      r.right.clamp(minSide, _imageSize.width),
      r.bottom.clamp(minSide, _imageSize.height),
    );
    if (out.width < minSide) {
      out = Rect.fromLTRB(out.left, out.top, out.left + minSide, out.bottom);
    }
    if (out.height < minSide) {
      out = Rect.fromLTRB(out.left, out.top, out.right, out.top + minSide);
    }
    return out;
  }

  // ---------------------------------------------------------------- gestures

  void _onTapUp(TapUpDetails d, CoverFit f) {
    if (_mode != _Mode.letters) return;
    final hit = _labelAt(d.localPosition, f);
    if (hit >= 0) {
      _editExisting(hit);
      return;
    }
    final src = f.toImage(d.localPosition, _image!.width, _image!.height);
    if (src != null) _addLabelAt(src);
  }

  void _onPanStart(DragStartDetails d, CoverFit f) {
    final p = d.localPosition;
    if (_mode == _Mode.letters) {
      final hit = _labelAt(p, f);
      if (hit >= 0) {
        _grab = _Grab.label;
        _grabbed = hit;
        _grabOffset = f.toWidget(_a.labels[hit].point) - p;
      }
      return;
    }
    final r = f.rectToWidget(_crop);
    _cropAtDragStart = _crop;
    const t = 28.0;
    if ((p - r.topLeft).distance < t) {
      _grab = _Grab.cropTL;
    } else if ((p - r.topRight).distance < t) {
      _grab = _Grab.cropTR;
    } else if ((p - r.bottomLeft).distance < t) {
      _grab = _Grab.cropBL;
    } else if ((p - r.bottomRight).distance < t) {
      _grab = _Grab.cropBR;
    } else if (r.contains(p)) {
      _grab = _Grab.cropMove;
      _grabOffset = p;
    }
  }

  void _onPanUpdate(DragUpdateDetails d, CoverFit f) {
    if (_grab == _Grab.none) return;
    final img = _image!;
    if (_grab == _Grab.label) {
      final src =
          f.toImage(d.localPosition + _grabOffset, img.width, img.height);
      if (src == null) return;
      final next = [..._a.labels];
      next[_grabbed] = next[_grabbed].copyWith(point: src);
      _mutate(_a.copyWith(labels: next));
      return;
    }
    final start = _cropAtDragStart ?? _crop;
    if (_grab == _Grab.cropMove) {
      final delta = (d.localPosition - _grabOffset) / f.scale;
      var moved = start.shift(delta);
      // Slide along the edge rather than stopping dead at it.
      final dx = moved.left < 0
          ? -moved.left
          : (moved.right > _imageSize.width ? _imageSize.width - moved.right : 0.0);
      final dy = moved.top < 0
          ? -moved.top
          : (moved.bottom > _imageSize.height ? _imageSize.height - moved.bottom : 0.0);
      moved = moved.shift(Offset(dx, dy));
      _mutate(_a.copyWith(crop: moved));
      return;
    }
    final src = f.toImage(d.localPosition, img.width, img.height) ??
        Offset(
          d.localPosition.dx.clamp(0.0, _imageSize.width),
          d.localPosition.dy.clamp(0.0, _imageSize.height),
        );
    final r = switch (_grab) {
      _Grab.cropTL => Rect.fromLTRB(src.dx, src.dy, start.right, start.bottom),
      _Grab.cropTR => Rect.fromLTRB(start.left, src.dy, src.dx, start.bottom),
      _Grab.cropBL => Rect.fromLTRB(src.dx, start.top, start.right, src.dy),
      _Grab.cropBR => Rect.fromLTRB(start.left, start.top, src.dx, src.dy),
      _ => start,
    };
    _mutate(_a.copyWith(crop: _clampCrop(r)));
  }

  void _onPanEnd() {
    _grab = _Grab.none;
    _grabbed = -1;
    _cropAtDragStart = null;
  }

  // ------------------------------------------------------------------ saving

  Future<void> _save() async {
    await context.read<UsAnnotationStore>().put(widget.scanAsset, _a);
    if (!mounted) return;
    setState(() => _dirty = false);
    showAppSnack(context,
        'Saved on this device. Export and run tools/pull_annotations.py to commit.');
  }

  Future<void> _export() async {
    final store = context.read<UsAnnotationStore>();
    if (_dirty) await store.put(widget.scanAsset, _a);
    if (!mounted) return;
    final where = await saveJson(store.exportJson(), 'us-annotations.json');
    if (!mounted) return;
    setState(() => _dirty = false);
    showAppSnack(context, 'Exported to $where');
  }

  Future<void> _revert() async {
    final ok = await showConfirm(
      context,
      title: 'Discard local edits?',
      message:
          'Returns this scan to the committed annotations. Anything authored here and not exported is lost.',
      confirmLabel: 'Discard',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final store = context.read<UsAnnotationStore>();
    await store.revert(widget.scanAsset);
    if (!mounted) return;
    setState(() {
      _a = store.forScan(widget.scanAsset);
      _dirty = false;
    });
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.title,
                style: GoogleFonts.sora(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            Text('LABEL & CROP',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9.5,
                    letterSpacing: 1.6,
                    color: AppTheme.primary)),
          ],
        ),
        actions: [
          if (_dirty)
            IconButton(
                tooltip: 'Save on device',
                onPressed: _save,
                icon: const Icon(Icons.check)),
          IconButton(
              tooltip: 'Export JSON',
              onPressed: _export,
              icon: const Icon(Icons.ios_share)),
          IconButton(
              tooltip: 'Discard local edits',
              onPressed: _revert,
              icon: const Icon(Icons.undo)),
        ],
      ),
      body: _image == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _modeToggle(isDark),
                const SizedBox(height: 12),
                _canvas(),
                const SizedBox(height: 10),
                _hint(isDark),
                if (_mode == _Mode.crop) ...[
                  const SizedBox(height: 12),
                  _cropControls(),
                ],
                const SizedBox(height: 18),
                // The legend carries its own heading now, so the screen does
                // not add a second one.
                if (_a.labels.isNotEmpty)
                  StructureLetterLegend(labels: _a.labels),
              ],
            ),
    );
  }

  Widget _modeToggle(bool isDark) => SegmentedButton<_Mode>(
        segments: const [
          ButtonSegment(
              value: _Mode.letters,
              icon: Icon(Icons.abc, size: 18),
              label: Text('Letters')),
          ButtonSegment(
              value: _Mode.crop,
              icon: Icon(Icons.crop, size: 16),
              label: Text('Crop')),
        ],
        selected: {_mode},
        onSelectionChanged: (s) => setState(() => _mode = s.first),
      );

  Widget _canvas() {
    return AspectRatio(
      aspectRatio: _imageSize.width / _imageSize.height,
      child: LayoutBuilder(builder: (context, box) {
        final size = Size(box.maxWidth, box.maxHeight);
        final f = _fit(size);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _onTapUp(d, f),
          onPanStart: (d) => _onPanStart(d, f),
          onPanUpdate: (d) => _onPanUpdate(d, f),
          onPanEnd: (_) => _onPanEnd(),
          onPanCancel: _onPanEnd,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Stack(fit: StackFit.expand, children: [
              // The whole frame, uncropped: the crop is shown as an overlay so
              // the author can see what it is cutting away.
              BakedHighlight(
                scanAsset: widget.scanAsset,
                maskAsset: widget.maskAsset,
                accent: widget.accent,
                intensity: 0.55,
                labels: _a.labels,
                fit: BoxFit.contain,
              ),
              if (_mode == _Mode.crop)
                CustomPaint(
                    painter: _CropOverlayPainter(
                        crop: f.rectToWidget(_crop),
                        active: _a.crop != null)),
            ]),
          ),
        );
      }),
    );
  }

  Widget _hint(bool isDark) {
    final t = _mode == _Mode.letters
        ? 'Tap the image to letter a structure. Tap a letter to rename or delete it, drag to move it.'
        : 'Drag inside to move the crop, or a corner to resize. Reading screens show the crop; nothing on disk is re-cut.';
    return Text(t,
        style: GoogleFonts.sourceSans3(
            fontSize: 11.5,
            height: 1.4,
            color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight));
  }

  Widget _cropControls() => Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _autoTrim,
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: const Text('Auto-trim'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _a.crop == null ? null : () => _setCrop(null),
            icon: const Icon(Icons.fullscreen, size: 18),
            label: const Text('Full frame'),
          ),
        ),
      ]);
}

/// Dims what the crop excludes and draws the handles. Purely the authoring
/// affordance — nothing here is ever drawn on a reading surface.
class _CropOverlayPainter extends CustomPainter {
  final Rect crop;
  final bool active;

  const _CropOverlayPainter({required this.crop, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(crop),
    );
    canvas.drawPath(outside, Paint()..color = Colors.black.withAlpha(active ? 150 : 60));
    canvas.drawRect(
        crop,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withAlpha(230));
    final handle = Paint()..color = Colors.white;
    for (final c in [
      crop.topLeft,
      crop.topRight,
      crop.bottomLeft,
      crop.bottomRight
    ]) {
      canvas.drawCircle(c, 7, Paint()..color = Colors.black.withAlpha(120));
      canvas.drawCircle(c, 5, handle);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter old) =>
      old.crop != crop || old.active != active;
}
