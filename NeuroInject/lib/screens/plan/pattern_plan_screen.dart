import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/muscle_data.dart';
import '../../data/muscle_provider.dart';
import '../../data/session_planner.dart';
import '../../models/muscle.dart';
import '../../models/spasticity_pattern.dart';
import '../../theme/app_theme.dart';

/// Turns a spasticity pattern into a candidate injection plan.
///
/// Tapping a pattern used to filter a list. The decision is actually made from
/// the posture in front of you, so this opens the pattern as the thing you are
/// deciding: its muscles, ticked into a session in one move.
///
/// NOTHING IS PRE-SELECTED, and NO DOSE IS SUGGESTED. Which muscles drive a
/// given patient's posture is a judgement the app has no basis for, and the
/// corpus's per-muscle dose ranges were withdrawn after the reflexpmr audit
/// found the "Botox" column tracked the Xeomin label. Gathering the candidates
/// is help; pre-ticking three of them, or putting a number next to each, would
/// be advice. Doses are entered in the session, in the injector's own units.
class PatternPlanScreen extends StatefulWidget {
  final String patternId;
  const PatternPlanScreen({super.key, required this.patternId});

  @override
  State<PatternPlanScreen> createState() => _PatternPlanScreenState();
}

class _PatternPlanScreenState extends State<PatternPlanScreen> {
  SpasticityPattern? _pattern;
  bool _loading = true;
  final Set<String> _picked = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final patterns = await MuscleData.loadPatterns();
    if (!mounted) return;
    setState(() {
      _pattern = patterns.where((p) => p.id == widget.patternId).firstOrNull;
      _loading = false;
    });
  }

  /// Muscles of this pattern that the app can show. The rest are counted and
  /// named in a note rather than dropped in silence — a plan that quietly
  /// omits a muscle of the pattern is worse than one that says what it left
  /// out.
  (List<Muscle>, int) _muscles(MuscleDataProvider data) {
    final p = _pattern;
    if (p == null) return (const [], 0);
    final shown = <Muscle>[];
    var hidden = 0;
    for (final id in p.muscles) {
      final m = data.findById(id);
      if (m == null) continue;
      if (data.isVisible(m.id)) {
        shown.add(m);
      } else {
        hidden++;
      }
    }
    return (shown, hidden);
  }

  void _toggle(Muscle m) => setState(() {
        if (!_picked.remove(m.id)) _picked.add(m.id);
      });

  void _addToSession(List<Muscle> muscles) {
    final planner = context.read<SessionPlanner>();
    final items = [
      for (final m in muscles)
        if (_picked.contains(m.id)) defaultSessionItem(m),
    ];
    if (items.isEmpty) return;
    planner.addAll(items);
    context.push('/session');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final data = context.watch<MuscleDataProvider>();

    if (_loading || !data.isLoaded) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(
          child: SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    final p = _pattern;
    if (p == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(backgroundColor: bg),
        body: const Center(child: Text('Pattern not found')),
      );
    }

    final (muscles, hidden) = _muscles(data);
    final tertiary = isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppTheme.primary : AppTheme.primaryDim),
          onPressed: () => context.pop(),
        ),
        title: Text('Plan',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              Text(p.name.toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppTheme.patternColor)),
              const SizedBox(height: 7),
              Text(p.description,
                  style: GoogleFonts.sourceSans3(
                      fontSize: 13.5,
                      height: 1.45,
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondaryLight)),
              const SizedBox(height: 18),
              Row(children: [
                Container(width: 3, height: 12, color: AppTheme.patternColor),
                const SizedBox(width: 8),
                Text('CANDIDATE MUSCLES',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: isDark
                            ? AppTheme.textStrong
                            : AppTheme.textStrongLight)),
                const Spacer(),
                Text('${_picked.length} OF ${muscles.length}',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 10, color: tertiary)),
              ]),
              const SizedBox(height: 10),
              for (final m in muscles) ...[
                _row(m, isDark),
                const SizedBox(height: 7),
              ],
              if (muscles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                      'None of this pattern’s muscles have an ultrasound in the app yet.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSans3(
                          fontSize: 13, color: tertiary)),
                ),
              if (hidden > 0) ...[
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: tertiary),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                        '$hidden more ${hidden == 1 ? "muscle" : "muscles"} in this pattern '
                        '${hidden == 1 ? "has" : "have"} no ultrasound in the app and '
                        '${hidden == 1 ? "is" : "are"} not listed here.',
                        style: GoogleFonts.sourceSans3(
                            fontSize: 11.5, height: 1.4, color: tertiary)),
                  ),
                ]),
              ],
            ],
          ),
        ),
        _footer(isDark, muscles),
      ]),
    );
  }

  Widget _row(Muscle m, bool isDark) {
    final on = _picked.contains(m.id);
    final accent = AppTheme.groupColor(m.group);
    return Semantics(
      button: true,
      checked: on,
      label: m.name,
      child: GestureDetector(
        onTap: () => _toggle(m),
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
            color: on
                ? (isDark ? AppTheme.surfaceElevated : AppTheme.surfaceLight)
                : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
                color: on
                    ? accent
                    : (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
          ),
          child: Row(children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: on ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm + 1),
                border: on
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppTheme.textTertiary
                            : AppTheme.textTertiaryLight,
                        width: 1.5),
              ),
              child: on
                  ? Icon(Icons.check_rounded, size: 14, color: AppTheme.bgDark)
                  : null,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name,
                      style: GoogleFonts.sora(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textStrong
                              : AppTheme.textStrongLight)),
                  const SizedBox(height: 2),
                  Text(m.pattern,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sourceSans3(
                          fontSize: 11.5,
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondaryLight)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _footer(bool isDark, List<Muscle> muscles) {
    final n = _picked.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
            top: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Doses are entered in the session, in your own units.',
            style: GoogleFonts.sourceSans3(
                fontSize: 11.5,
                color: isDark
                    ? AppTheme.textTertiary
                    : AppTheme.textTertiaryLight)),
        const SizedBox(height: 10),
        Semantics(
          button: true,
          enabled: n > 0,
          label: n == 0
              ? 'Select muscles to plan'
              : 'Add $n ${n == 1 ? "muscle" : "muscles"} to session',
          child: GestureDetector(
            onTap: n == 0 ? null : () => _addToSession(muscles),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: n == 0 ? AppTheme.surfaceElevated : AppTheme.patternColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                  n == 0 ? 'SELECT MUSCLES TO PLAN' : 'ADD $n TO SESSION',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: n == 0 ? AppTheme.textTertiary : AppTheme.bgDark)),
            ),
          ),
        ),
      ]),
    );
  }
}
