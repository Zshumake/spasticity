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

  Future<void> _confirmEnd(SessionPlanner planner) async {
    final done = planner.completed.length;
    final total = planner.count;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text('End session?',
            style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textStrong)),
        content: Text(
            done < total
                ? '$done of $total muscles are marked done. Ending clears the '
                    'progress and the clock; the plan itself is kept.'
                : 'Ending clears the progress and the clock; the plan itself '
                    'is kept.',
            style: GoogleFonts.sourceSans3(
                fontSize: 13, height: 1.45, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep going',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 12, color: AppTheme.textSecondary))),
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

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<SessionPlanner>();
    final current = planner.current;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _header(planner),
          _ceiling(planner),
          Expanded(
            child: current == null
                ? _allDone(planner)
                : _focus(planner, current),
          ),
        ]),
      ),
    );
  }

  // ─── chrome ──────────────────────────────────────────────────

  Widget _header(SessionPlanner planner) {
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
                  color: AppTheme.textTertiary)),
          const SizedBox(height: 4),
          Text('$done of ${planner.count} done',
              style: GoogleFonts.sora(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textStrong)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.borderDark),
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
                    color: AppTheme.textPrimary)),
          ]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _confirmEnd(planner),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.borderDark),
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
  Widget _ceiling(SessionPlanner planner) {
    final delivered = planner.deliveredTotals;
    final planned = planner.brandTotals;
    final brands = {...delivered.keys, ...planned.keys}.toList();
    if (brands.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          for (final b in brands) ...[
            _ceilingBar(b, delivered[b] ?? 0, planned[b] ?? 0),
            if (b != brands.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _ceilingBar(String brand, double delivered, double planned) {
    final max = toxinBrands
        .firstWhere((t) => t.name == brand, orElse: () => toxinBrands.first)
        .maxSessionUnits
        .toDouble();
    final pct = max <= 0 ? 0.0 : (delivered / max).clamp(0.0, 1.0);
    final plannedPct = max <= 0 ? 0.0 : (planned / max).clamp(0.0, 1.0);
    final over = delivered > max;
    final colour = over
        ? AppTheme.danger
        : (pct > 0.75 ? AppTheme.amber : AppTheme.success);

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: over ? AppTheme.danger : AppTheme.borderDark),
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${brand.toUpperCase()} DELIVERED',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppTheme.textSecondary)),
          const Spacer(),
          Text(_units(delivered),
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textStrong)),
          Text(' / ${_units(max)} U',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12, color: AppTheme.textTertiary)),
        ]),
        const SizedBox(height: 9),
        // Two bars: what has gone in, and where the plan would finish. The
        // second is what tells you the plan overruns BEFORE you get there.
        Stack(children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4)),
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
                  fontSize: 11.5, color: AppTheme.textTertiary)),
          const Spacer(),
          if (planned > max)
            Text('PLAN EXCEEDS LABEL MAX',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.danger)),
        ]),
      ]),
    );
  }

  // ─── the muscle in hand ──────────────────────────────────────

  Widget _focus(SessionPlanner planner, SessionItem item) {
    final accent = AppTheme.groupColor(item.group);
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
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
                            color: AppTheme.textStrong)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _fact('${_units(item.dose)} U', item.brand),
                      const SizedBox(width: 10),
                      _fact(item.side.label, 'SIDE'),
                      const SizedBox(width: 10),
                      _fact('${item.sitesLogged}', 'SITES LOGGED'),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push('/muscle/${item.muscleId}'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monitor_heart_outlined,
                            size: 15, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text('OPEN THE SCAN',
                            style: GoogleFonts.ibmPlexMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: AppTheme.textSecondary)),
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
                        color: AppTheme.textTertiary)),
                const SizedBox(height: 8),
                for (final n in planner.remaining.skip(1))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _queueRow(n),
                  ),
              ],
              if (planner.completed.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('DONE',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: AppTheme.textTertiary)),
                const SizedBox(height: 8),
                for (final d in planner.completed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _doneRow(planner, d),
                  ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      _actions(planner, item, accent),
    ]);
  }

  Widget _fact(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppTheme.textTertiary)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.ibmPlexMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      ]),
    );
  }

  Widget _queueRow(SessionItem i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderDark),
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
                    color: AppTheme.textPrimary)),
          ),
          Text('${_units(i.dose)} U',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary)),
        ]),
      );

  Widget _doneRow(SessionPlanner planner, SessionItem i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Row(children: [
          Icon(i.wasSkipped ? Icons.remove_circle_outline : Icons.check_circle,
              size: 17,
              color: i.wasSkipped ? AppTheme.textTertiary : AppTheme.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(i.muscleName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.sora(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
          ),
          Text(
              i.wasSkipped
                  ? 'SKIPPED'
                  : '${_units(i.totalUnits)} U · ${i.sitesLogged} '
                      '${i.sitesLogged == 1 ? "site" : "sites"}',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => planner.reopenMuscle(i.muscleId),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 34,
              height: 34,
              child: Icon(Icons.undo_rounded,
                  size: 15, color: AppTheme.textTertiary),
            ),
          ),
        ]),
      );

  /// Two actions, both oversized. LOG SITE is the one pressed repeatedly with
  /// a gloved thumb, so it takes the width and the height; DONE is smaller
  /// because pressing it by accident costs a muscle.
  Widget _actions(SessionPlanner planner, SessionItem item, Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(children: [
        if (item.sitesLogged > 0) ...[
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              planner.undoSite(item.muscleId);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 56,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: const Icon(Icons.undo_rounded,
                  size: 20, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 9),
        ],
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              planner.logSite(item.muscleId);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, size: 22,
                        color: AppTheme.bgDark),
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
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            planner.finishMuscle(item.muscleId);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 92,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                  color: item.sitesLogged > 0
                      ? AppTheme.success
                      : AppTheme.borderDark),
            ),
            child: Text(item.sitesLogged > 0 ? 'DONE' : 'SKIP',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: item.sitesLogged > 0
                        ? AppTheme.success
                        : AppTheme.textSecondary)),
          ),
        ),
      ]),
    );
  }

  Widget _allDone(SessionPlanner planner) {
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
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textStrong)),
        const SizedBox(height: 8),
        Text(
            '$injected injected${skipped > 0 ? " · $skipped skipped" : ""} · '
            '${_clock(planner.elapsed)} elapsed',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
                fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 26),
        GestureDetector(
          onTap: () => _confirmEnd(planner),
          behavior: HitTestBehavior.opaque,
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
