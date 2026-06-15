import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/highlight_capture_store.dart';
import '../../data/muscle_provider.dart';
import '../../models/highlight_capture.dart';
import '../../theme/app_theme.dart';
import '../../widgets/highlight/capture_thumbnail.dart';

/// Reviews the self-generated training set: every accepted highlight, grouped
/// by muscle, with per-capture delete and clear-all. Makes the "tool builds its
/// own dataset" loop tangible and pruneable.
class CapturesReviewScreen extends StatelessWidget {
  const CapturesReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HighlightCaptureStore>();
    final muscles = context.read<MuscleDataProvider>();
    final all = store.all;

    final byMuscle = <String, List<HighlightCapture>>{};
    for (final c in all) {
      (byMuscle[c.muscleId] ??= []).add(c);
    }
    for (final list in byMuscle.values) {
      list.sort((a, b) => b.createdAtMillis - a.createdAtMillis);
    }
    final groups = byMuscle.entries.toList()
      ..sort((a, b) => b.value.length - a.value.length);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Captured Highlights',
                style:
                    GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('TRAINING SET',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 1.6,
                    color: AppTheme.primary)),
          ],
        ),
        actions: [
          if (all.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: all.isEmpty
          ? _empty(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                _summary(all.length, groups.length),
                const SizedBox(height: 18),
                for (final e in groups) ...[
                  _muscleSection(
                    context,
                    name: muscles.findById(e.key)?.name ?? e.key,
                    accent: AppTheme.groupColor(
                        muscles.findById(e.key)?.group ?? ''),
                    captures: e.value,
                  ),
                  const SizedBox(height: 22),
                ],
              ],
            ),
    );
  }

  Widget _summary(int total, int muscleCount) {
    return Row(children: [
      const Icon(Icons.dataset_outlined, size: 16, color: AppTheme.success),
      const SizedBox(width: 8),
      Text(
        '$total highlight${total == 1 ? '' : 's'} · '
        '$muscleCount muscle${muscleCount == 1 ? '' : 's'}',
        style: GoogleFonts.ibmPlexMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary),
      ),
    ]);
  }

  Widget _muscleSection(
    BuildContext context, {
    required String name,
    required Color accent,
    required List<HighlightCapture> captures,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
              width: 3,
              height: 15,
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 9),
          Text(name,
              style: GoogleFonts.sora(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text('${captures.length}',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 11, color: AppTheme.textTertiary)),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: captures.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final c = captures[i];
              return SizedBox(
                width: 138,
                child: Stack(children: [
                  CaptureThumbnail(capture: c, accent: accent),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _confirmDelete(context, c),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.close,
                            size: 13, color: Colors.white70),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.gesture, size: 40, color: AppTheme.textTertiary),
          const SizedBox(height: 14),
          Text('No highlights captured yet',
              style: GoogleFonts.sora(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Open a muscle, tap Highlight, draw around it on ultrasound, and '
            'Accept. Each one is saved here and builds the training set.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
                fontSize: 13, height: 1.45, color: AppTheme.textSecondary),
          ),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, HighlightCapture c) {
    final store = context.read<HighlightCaptureStore>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete highlight?'),
        content: const Text('This removes one captured training example.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              store.remove(c.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final store = context.read<HighlightCaptureStore>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all highlights?'),
        content: Text(
            'This permanently removes all ${store.count} captured examples.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              store.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}
