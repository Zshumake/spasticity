import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/mask_probe.dart';
import '../../data/muscle_provider.dart';
import '../../models/muscle.dart';
import '../../theme/app_theme.dart';
import '../../widgets/highlight/baked_highlight.dart';

/// Ten scans, one question each: find the named muscle by tapping it.
///
/// The rest of the app teaches what a muscle IS. This is the only surface that
/// exercises finding it on a screen, which is the skill the ultrasound guidance
/// actually requires — and it needs no new content, because the baked masks are
/// already a per-pixel answer key (see [MaskProbe]).
class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _Round {
  final Muscle muscle;
  final UltrasoundView view;
  const _Round(this.muscle, this.view);
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  static const int roundCount = 10;

  List<_Round> _rounds = [];
  int _index = 0;
  final List<bool> _results = [];

  MaskProbe? _probe;
  bool _loading = true;

  Offset? _tap;
  bool? _correct;
  double _seconds = 0;
  final Stopwatch _clock = Stopwatch();

  /// Set once the pool has been assembled, so the corpus is read exactly once
  /// even though build() runs on every provider notification.
  bool _built = false;

  Color _tertiary(bool isDark) =>
      isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight;
  Color _border(bool isDark) =>
      isDark ? AppTheme.borderDark : AppTheme.borderLight;

  /// Burned-label rectangles per scan filename, in source-image pixels.
  /// Covering them is what stops the sonographer's own annotation from
  /// answering the question — see tools/export_label_boxes.py.
  Map<String, List<Rect>> _labelBoxes = const {};

  List<Rect> _boxesFor(String scanAsset) =>
      _labelBoxes[scanAsset.split('/').last] ?? const [];

  Future<void> _loadLabelBoxes() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/us-label-boxes.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _labelBoxes = {
        for (final e in decoded.entries)
          e.key: [
            for (final b in (e.value as List))
              Rect.fromLTWH((b[0] as num).toDouble(), (b[1] as num).toDouble(),
                  (b[2] as num).toDouble(), (b[3] as num).toDouble())
          ]
      };
    } catch (_) {
      // Without boxes the round would show the answer, so it is better to
      // have none than to guess: the pool check below drops those scans.
      _labelBoxes = const {};
    }
  }

  Future<void> _build() async {
    final data = context.read<MuscleDataProvider>();
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();
    await _loadLabelBoxes();

    // Only muscles whose scan AND mask are both bundled can be asked about —
    // a muscle with no mask (tibialis posterior today) has no answer key.
    final pool = <_Round>[];
    for (final m in data.muscles) {
      for (final v in m.resolvedUltrasoundViews) {
        // A scan whose burned label cannot be covered would print the answer
        // on the question, so it is not asked.
        if (assets.contains(v.scanAsset) &&
            assets.contains(v.maskAsset) &&
            _boxesFor(v.scanAsset).isNotEmpty) {
          pool.add(_Round(m, v));
        }
      }
    }
    pool.shuffle(Random());
    if (!mounted) return;
    setState(() => _rounds = pool.take(roundCount).toList());
    await _loadProbe();
  }

  Future<void> _loadProbe() async {
    if (_rounds.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final probe = await MaskProbe.load(_rounds[_index].view.maskAsset);
    if (!mounted) return;
    setState(() {
      _probe = probe;
      _loading = false;
      _tap = null;
      _correct = null;
    });
    _clock
      ..reset()
      ..start();
  }

  void _answer(Offset local, Size box) {
    if (_correct != null || _probe == null) return;
    _clock.stop();
    final hit = _probe!.hit(local, box);
    // The verdict in the hand before it is on the screen: a light tap for a
    // hit, a heavy one for a miss.
    if (hit) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _tap = local;
      _correct = hit;
      _seconds = _clock.elapsedMilliseconds / 1000.0;
      _results.add(hit);
    });
  }

  void _next() {
    if (_index + 1 >= _rounds.length) {
      setState(() => _index = _rounds.length); // summary
      return;
    }
    setState(() => _index++);
    _loadProbe();
  }

  void _restart() {
    setState(() {
      _index = 0;
      _results.clear();
      _rounds = [];
      _loading = true;
    });
    _build();
  }

  @override
  void dispose() {
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.bgLight;

    // Opening straight onto this screen (a cold start, a deep link) races the
    // corpus load: reading muscles too early yields an empty pool, which would
    // show "no scans" for a library that has 47 of them. Wait for the load.
    final data = context.watch<MuscleDataProvider>();
    if (!data.isLoaded) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    if (!_built) {
      _built = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _build());
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: _rounds.isEmpty && !_loading
            ? _empty(isDark)
            : _index >= _rounds.length && _rounds.isNotEmpty
                ? _summary(isDark)
                : _round(isDark),
      ),
    );
  }

  // ── round ────────────────────────────────────────────────────────

  Widget _round(bool isDark) {
    if (_rounds.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final round = _rounds[_index];
    final accent = BakedHighlight.regionTint(round.muscle.group);
    final answered = _correct != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(isDark),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'ROUND ${_index + 1} OF ${_rounds.length}'
                  '${round.muscle.resolvedUltrasoundViews.length > 1 ? " · ${round.view.label.toUpperCase()}" : ""}',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: accent)),
              const SizedBox(height: 6),
              Text('Find ${round.muscle.name.toLowerCase()}',
                  style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark
                          ? AppTheme.textStrong
                          : AppTheme.textStrongLight)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, box) {
                final size = Size(box.maxWidth, box.maxHeight);
                return Semantics(
                  label: answered
                      ? 'Ultrasound scan, answer revealed'
                      : 'Ultrasound scan. Tap where ${round.muscle.name} is.',
                  child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _answer(d.localPosition, size),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: BakedHighlight(
                            key: ValueKey('identify-${round.view.maskAsset}'),
                            scanAsset: round.view.scanAsset,
                            maskAsset: round.view.maskAsset,
                            accent: accent,
                            // Plain until answered: the tint IS the answer.
                            revealFrom: answered ? 0.0 : 1.0,
                            occlude: _boxesFor(round.view.scanAsset),
                          ),
                        ),
                        if (_tap != null)
                          Positioned(
                            left: _tap!.dx - 17,
                            top: _tap!.dy - 17,
                            child: _crosshair(_correct == true),
                          ),
                      ],
                    ),
                  ),
                  ),
                );
              },
            ),
          ),
        ),
        if (answered) _verdict(isDark, round) else _hint(isDark),
      ],
    );
  }

  Widget _crosshair(bool ok) {
    final c = ok ? AppTheme.success : AppTheme.danger;
    return IgnorePointer(
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c, width: 2),
        ),
        child: Center(
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _hint(bool isDark) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Row(children: [
          Icon(Icons.touch_app_outlined, size: 15, color: _tertiary(isDark)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Tap the muscle on the scan.',
                style: GoogleFonts.sourceSans3(
                    fontSize: 12.5,
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight)),
          ),
        ]),
      );

  Widget _verdict(bool isDark, _Round round) {
    final ok = _correct == true;
    final c = ok ? AppTheme.success : AppTheme.danger;
    final last = _index + 1 >= _rounds.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: c),
            ),
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Row(children: [
              Icon(ok ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                  size: 18, color: c),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ok ? 'CORRECT' : 'NOT QUITE',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: c)),
                    const SizedBox(height: 2),
                    Text(
                        ok
                            ? 'That is ${round.muscle.name.toLowerCase()}.'
                            : 'The highlight shows where it actually is.',
                        style: GoogleFonts.sourceSans3(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Text('${_seconds.toStringAsFixed(1)}s',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimaryLight)),
            ]),
          ),
          const SizedBox(height: 10),
          Semantics(
            button: true,
            label: last ? 'See results' : 'Next scan',
            child: GestureDetector(
            onTap: _next,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BakedHighlight.regionTint(round.muscle.group),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(last ? 'SEE RESULTS' : 'NEXT SCAN',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppTheme.bgDark)),
            ),
            ),
          ),
        ],
      ),
    );
  }

  // ── chrome ───────────────────────────────────────────────────────

  Widget _bar(bool isDark) {
    final right = _results.where((r) => r).length;
    final wrong = _results.length - right;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(children: [
        Semantics(
          button: true,
          label: 'Back',
          child: GestureDetector(
          onTap: () => context.pop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
            ),
            child: Icon(Icons.chevron_left_rounded,
                size: 20,
                color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
          ),
          ),
        ),
        const SizedBox(width: 12),
        Text('IDENTIFY',
            style: GoogleFonts.ibmPlexMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: _tertiary(isDark))),
        const Spacer(),
        Semantics(
          label: '$right correct, $wrong wrong',
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_rounded, size: 12, color: AppTheme.success),
            const SizedBox(width: 5),
            Text('$right',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success)),
            const SizedBox(width: 8),
            Container(width: 1, height: 11, color: _border(isDark)),
            const SizedBox(width: 8),
            Text('$wrong',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _tertiary(isDark))),
          ]),
          ),
        ),
      ]),
    );
  }

  Widget _empty(bool isDark) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.image_not_supported_outlined,
                size: 34, color: _tertiary(isDark)),
            const SizedBox(height: 14),
            Text('No scans with a highlight yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Text('Identify needs a baked mask to mark an answer.',
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                    fontSize: 12.5, color: _tertiary(isDark))),
          ]),
        ),
      );

  Widget _summary(bool isDark) {
    final right = _results.where((r) => r).length;
    return Column(children: [
      _bar(isDark),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$right / ${_results.length}',
                  style: GoogleFonts.sora(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: isDark
                          ? AppTheme.textStrong
                          : AppTheme.textStrongLight)),
              const SizedBox(height: 8),
              Text('scans identified',
                  style: GoogleFonts.sourceSans3(
                      fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 26),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  for (final r in _results)
                    Container(
                      width: 20,
                      height: 4,
                      decoration: BoxDecoration(
                        color: r ? AppTheme.success : AppTheme.danger,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              Semantics(
                button: true,
                label: 'Go again',
                child: GestureDetector(
                onTap: _restart,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: 190),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text('GO AGAIN',
                      style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppTheme.bgDark)),
                ),
                ),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}
