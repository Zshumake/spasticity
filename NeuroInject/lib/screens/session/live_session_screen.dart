import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/session_planner.dart';
import '../../data/toxin_data.dart';
import '../../models/session_item.dart';
import '../../theme/app_theme.dart';

/// The plan, running, during the procedure.
///
/// This is the only screen used with gloves on and a probe in the other hand,
/// which drives every decision here: one muscle in focus rather than a list to
/// scan, targets far larger than the 44pt minimum, the running total against
/// the labelled ceiling pinned where it cannot scroll away, and no destructive
/// action reachable by a single tap.
///
/// Progress lives in [SessionPlanner] and is persisted on every change, so a
/// backgrounded app, a locked phone or a crash mid-list comes back with the
/// same muscles ticked off and the same clock.
class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({super.key});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

/// The screen's colours for the current brightness. Everything below reads
/// from this rather than from AppTheme's dark constants directly, because the
/// app has a light theme now and a procedure screen that ignores it opens as a
/// black hole in the middle of a white app.
class _Tone {
  final Color bg;
  final Color card;
  final Color raised;
  final Color border;
  final Color strong;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const _Tone._({
    required this.bg,
    required this.card,
    required this.raised,
    required this.border,
    required this.strong,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  factory _Tone.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppPalette.of(context);
    return _Tone._(
      bg: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      card: p.bgCard,
      raised: p.surfaceRaised,
      border: p.borderColor,
      strong: isDark ? AppTheme.textStrong : AppTheme.textStrongLight,
      primary: p.textPrimary,
      secondary: p.textSecondary,
      tertiary: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
    );
  }
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Only to repaint the elapsed clock; the time itself is derived from the
    // persisted start, never accumulated here.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _clock(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _units(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Future<void> _confirmEnd(SessionPlanner planner, _Tone t) async {
    final done = planner.completed.length;
    final total = planner.count;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.card,
        title: Text('End session?',
            style: GoogleFonts.sora(
                fontSize: 16, fontWeight: FontWeight.w700, color: t.strong)),
        content: Text(
            done < total
                ? '$done of $total muscles are marked done. Ending clears the '
                    'progress and the clock; the plan itself is kept.'
                : 'Ending clears the progress and the clock; the plan itself '
                    'is kept.',
            style: GoogleFonts.sourceSans3(
                fontSize: 13, height: 1.45, color: t.secondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep going',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 12, color: t.secondary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('END',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.danger))),
        ],
      ),
    );
    if (ok == true && mounted) {
      planner.endSession();
      if (mounted) context.pop();
    }
  }

  /// One tap target: a labelled, announced button around an oversized box.
  Widget _tap({
    required String label,
    required VoidCallback? onTap,
    required Widget child,
    bool selected = false,
  }) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<SessionPlanner>();
    final t = _Tone.of(context);
    final current = planner.current;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: planner.isEmpty
            // Nothing to run. Reachable if the plan is cleared while this
            // screen is open, or by opening the route directly.
            ? _nothingPlanned(t)
            : Column(children: [
                _header(planner, t),
                _ceiling(planner, t),
                Expanded(
                  child: current == null
                      ? _allDone(planner, t)
                      : _focus(planner, current, t),
                ),
              ]),
      ),
    );
  }

  // ─── chrome ──────────────────────────────────────────────────

  Widget _header(SessionPlanner planner, _Tone t) {
    final done = planner.completed.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SESSION IN PROGRESS',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: t.tertiary)),
          const SizedBox(height: 4),
          Text('$done of ${planner.count} done',
              style: GoogleFonts.sora(
                  fontSize: 17, fontWeight: FontWeight.w800, color: t.strong)),
        ]),
        const Spacer(),
        Semantics(
          label: 'Elapsed ${_clock(planner.elapsed)}',
          liveRegion: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: t.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppTheme.danger, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Text(_clock(planner.elapsed),
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: t.primary)),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        _tap(
          label: 'End session',
          onTap: () => _confirmEnd(planner, t),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: t.border),
            ),
            child: const Icon(Icons.stop_rounded,
                size: 20, color: AppTheme.danger),
          ),
        ),
      ]),
    );
  }

  /// The number a visit can go wrong on, so it is pinned above the fold and
  /// never scrolls away.
  Widget _ceiling(SessionPlanner planner, _Tone t) {
    final delivered = planner.deliveredTotals;
    final planned = planner.brandTotals;
    final brands = {...delivered.keys, ...planned.keys}.toList();
    if (brands.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          for (final b in brands) ...[
            _ceilingBar(b, delivered[b] ?? 0, planned[b] ?? 0, t),
            if (b != brands.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _ceilingBar(String brand, double delivered, double planned, _Tone t) {
    final max = toxinBrands
        .firstWhere((x) => x.name == brand, orElse: () => toxinBrands.first)
        .maxSessionUnits
        .toDouble();
    final pct = max <= 0 ? 0.0 : (delivered / max).clamp(0.0, 1.0);
    final plannedPct = max <= 0 ? 0.0 : (planned / max).clamp(0.0, 1.0);
    final over = delivered > max;
    final colour = over
        ? AppTheme.danger
        : (pct > 0.75 ? AppTheme.amber : AppTheme.success);

    return Semantics(
      label: '$brand delivered ${_units(delivered)} of ${_units(max)} units, '
          '${_units(planned)} planned'
          '${planned > max ? ", plan exceeds the labelled maximum" : ""}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: over ? AppTheme.danger : t.border),
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${brand.toUpperCase()} DELIVERED',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: t.secondary)),
            const Spacer(),
            Text(_units(delivered),
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: t.strong)),
            Text(' / ${_units(max)} U',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12, color: t.tertiary)),
          ]),
          const SizedBox(height: 9),
          // Two bars: what has gone in, and where the plan would finish. The
          // second is what tells you the plan overruns BEFORE you get there.
          Stack(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                  color: t.raised, borderRadius: BorderRadius.circular(4)),
            ),
            FractionallySizedBox(
              widthFactor: plannedPct,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                    color: colour.withAlpha(60),
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            FractionallySizedBox(
              widthFactor: pct,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                    color: colour, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            Text('${_units(planned)} U planned',
                style: GoogleFonts.sourceSans3(
                    fontSize: 11.5, color: t.tertiary)),
            const Spacer(),
            if (planned > max)
              Text('PLAN EXCEEDS LABEL MAX',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.danger)),
          ]),
        ]),
      ),
    );
  }

  // ─── the muscle in hand ──────────────────────────────────────

  Widget _focus(SessionPlanner planner, SessionItem item, _Tone t) {
    final accent = AppTheme.groupColor(item.group);
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Now injecting ${item.muscleName}, '
                    '${_units(item.dose)} units ${item.brand}, '
                    '${item.side.label} side, ${item.sitesLogged} sites logged',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                  decoration: BoxDecoration(
                    color: t.raised,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: accent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NOW INJECTING',
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: accent)),
                      const SizedBox(height: 6),
                      Text(item.muscleName,
                          style: GoogleFonts.sora(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -0.4,
                              color: t.strong)),
                      const SizedBox(height: 12),
                      Row(children: [
                        _fact('${_units(item.dose)} U', item.brand, t),
                        const SizedBox(width: 10),
                        _fact(item.side.label, 'SIDE', t),
                        const SizedBox(width: 10),
                        _fact('${item.sitesLogged}', 'SITES LOGGED', t),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _tap(
                label: 'Open the ultrasound scan for ${item.muscleName}',
                onTap: () => context.push('/muscle/${item.muscleId}'),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monitor_heart_outlined,
                            size: 15, color: t.secondary),
                        const SizedBox(width: 8),
                        Text('OPEN THE SCAN',
                            style: GoogleFonts.ibmPlexMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: t.secondary)),
                      ]),
                ),
              ),
              const SizedBox(height: 14),
              if (planner.remaining.length > 1) ...[
                Text('UP NEXT',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: t.tertiary)),
                const SizedBox(height: 8),
                for (final n in planner.remaining.skip(1))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _queueRow(n, t),
                  ),
              ],
              if (planner.completed.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('DONE',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: t.tertiary)),
                const SizedBox(height: 8),
                for (final d in planner.completed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _doneRow(planner, d, t),
                  ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      _actions(planner, item, accent, t),
    ]);
  }

  Widget _fact(String value, String label, _Tone t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: t.tertiary)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.ibmPlexMono(
                fontSize: 14, fontWeight: FontWeight.w700, color: t.primary)),
      ]),
    );
  }

  Widget _queueRow(SessionItem i, _Tone t) => Semantics(
        label: 'Up next: ${i.muscleName}, ${_units(i.dose)} units',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: t.border),
          ),
          child: Row(children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: AppTheme.groupColor(i.group), shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(i.muscleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: t.primary)),
            ),
            Text('${_units(i.dose)} U',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: t.tertiary)),
          ]),
        ),
      );

  Widget _doneRow(SessionPlanner planner, SessionItem i, _Tone t) {
    final summary = i.wasSkipped
        ? 'skipped'
        : '${_units(i.totalUnits)} units, ${i.sitesLogged} '
            '${i.sitesLogged == 1 ? "site" : "sites"}';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: t.border),
      ),
      child: Row(children: [
        Icon(i.wasSkipped ? Icons.remove_circle_outline : Icons.check_circle,
            size: 17, color: i.wasSkipped ? t.tertiary : AppTheme.success),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            label: '${i.muscleName}, $summary',
            child: Text(i.muscleName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.sora(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: t.secondary)),
          ),
        ),
        ExcludeSemantics(
          child: Text(
              i.wasSkipped
                  ? 'SKIPPED'
                  : '${_units(i.totalUnits)} U · ${i.sitesLogged} '
                      '${i.sitesLogged == 1 ? "site" : "sites"}',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: t.tertiary)),
        ),
        const SizedBox(width: 2),
        _tap(
          label: 'Reopen ${i.muscleName}',
          onTap: () => planner.reopenMuscle(i.muscleId),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.undo_rounded, size: 16, color: t.tertiary),
          ),
        ),
      ]),
    );
  }

  /// Two actions, both oversized. LOG SITE is the one pressed repeatedly with
  /// a gloved thumb, so it takes the width and the height; DONE is smaller
  /// because pressing it by accident costs a muscle.
  Widget _actions(
      SessionPlanner planner, SessionItem item, Color accent, _Tone t) {
    final hasSites = item.sitesLogged > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      decoration: BoxDecoration(
        color: t.card,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(children: [
        if (hasSites) ...[
          _tap(
            label: 'Undo last site',
            onTap: () {
              HapticFeedback.selectionClick();
              planner.undoSite(item.muscleId);
            },
            child: Container(
              width: 56,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: t.border),
              ),
              child: Icon(Icons.undo_rounded, size: 20, color: t.secondary),
            ),
          ),
          const SizedBox(width: 9),
        ],
        Expanded(
          child: _tap(
            label: 'Log site ${item.sitesLogged + 1} for ${item.muscleName}',
            onTap: () {
              HapticFeedback.mediumImpact();
              planner.logSite(item.muscleId);
            },
            child: Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 22, color: AppTheme.bgDark),
                    const SizedBox(width: 8),
                    Text('LOG SITE ${item.sitesLogged + 1}',
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppTheme.bgDark)),
                  ]),
            ),
          ),
        ),
        const SizedBox(width: 9),
        _tap(
          label: hasSites
              ? 'Mark ${item.muscleName} done'
              : 'Skip ${item.muscleName}',
          onTap: () {
            HapticFeedback.mediumImpact();
            planner.finishMuscle(item.muscleId);
          },
          child: Container(
            width: 92,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                  color: hasSites ? AppTheme.success : t.border),
            ),
            child: Text(hasSites ? 'DONE' : 'SKIP',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: hasSites ? AppTheme.success : t.secondary)),
          ),
        ),
      ]),
    );
  }

  // ─── end states ──────────────────────────────────────────────

  Widget _nothingPlanned(_Tone t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.playlist_add_rounded, size: 42, color: t.tertiary),
        const SizedBox(height: 16),
        Text('Nothing planned yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
                fontSize: 18, fontWeight: FontWeight.w800, color: t.strong)),
        const SizedBox(height: 8),
        Text('A session runs the muscles in your plan. Add some first.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(fontSize: 13, color: t.secondary)),
        const SizedBox(height: 26),
        _tap(
          label: 'Go to the session plan',
          onTap: () => context.canPop() ? context.pop() : context.go('/'),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text('BACK TO THE PLAN',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.bgDark)),
          ),
        ),
      ]),
    );
  }

  Widget _allDone(SessionPlanner planner, _Tone t) {
    final injected = planner.completed.where((i) => !i.wasSkipped).length;
    final skipped = planner.completed.length - injected;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_outline_rounded,
            size: 42, color: AppTheme.success),
        const SizedBox(height: 16),
        Text('Every muscle accounted for',
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
                fontSize: 18, fontWeight: FontWeight.w800, color: t.strong)),
        const SizedBox(height: 8),
        Text(
            '$injected injected${skipped > 0 ? " · $skipped skipped" : ""} · '
            '${_clock(planner.elapsed)} elapsed',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(fontSize: 13, color: t.secondary)),
        const SizedBox(height: 26),
        _tap(
          label: 'End session',
          onTap: () => _confirmEnd(planner, t),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.success,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text('END SESSION',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.bgDark)),
          ),
        ),
      ]),
    );
  }
}
