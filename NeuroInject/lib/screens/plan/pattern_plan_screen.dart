import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/dose_range.dart';
import '../../data/muscle_data.dart';
import '../../data/muscle_provider.dart';
import '../../data/session_planner.dart';
import '../../data/toxin_data.dart';
import '../../models/muscle.dart';
import '../../models/session_item.dart';
import '../../models/spasticity_pattern.dart';
import '../../theme/app_theme.dart';

/// Turns a spasticity pattern into a candidate injection plan.
///
/// Tapping a pattern used to filter a list, which leaves the arithmetic — and
/// the brand ceiling — to the reader. The decision is actually made from the
/// posture in front of you, so this opens the pattern as the thing you are
/// deciding: its muscles, each carrying its documented dose, totalling against
/// the session maximum as you choose.
///
/// TWO DELIBERATE RESTRAINTS, because this is the surface where the app comes
/// closest to making a clinical decision:
///
///   * NOTHING IS PRE-SELECTED. Which muscles drive a given patient's posture
///     is a judgement the app has no basis for. Gathering the candidates and
///     doing the sums is help; pre-ticking three of them would be advice.
///   * The seeded dose is the BOTTOM of each muscle's documented range (see
///     [DoseRange.seed]), and every row says the full range next to it.
class PatternPlanScreen extends StatefulWidget {
  final String patternId;
  const PatternPlanScreen({super.key, required this.patternId});

  @override
  State<PatternPlanScreen> createState() => _PatternPlanScreenState();
}

class _PatternPlanScreenState extends State<PatternPlanScreen> {
  SpasticityPattern? _pattern;
  bool _loading = true;

  String _brand = 'Botox';
  final Map<String, double> _picked = {}; // muscleId -> per-side dose

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

  double get _ceiling => toxinBrands
      .firstWhere((b) => b.name == _brand,
          orElse: () => toxinBrands.first)
      .maxSessionUnits
      .toDouble();

  double get _total =>
      _picked.values.fold<double>(0, (sum, d) => sum + d);

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

  void _toggle(Muscle m) {
    final r = DoseRange.forBrand(m.dosage, _brand);
    if (r == null) return;
    setState(() {
      if (_picked.containsKey(m.id)) {
        _picked.remove(m.id);
      } else {
        _picked[m.id] = r.seed;
      }
    });
  }

  void _setBrand(String brand, List<Muscle> muscles) {
    setState(() {
      _brand = brand;
      // Doses are per brand and not interchangeable, so re-seed rather than
      // carry Botox units over to a Dysport plan.
      for (final id in _picked.keys.toList()) {
        final m = muscles.where((x) => x.id == id).firstOrNull;
        final r = m == null ? null : DoseRange.forBrand(m.dosage, brand);
        if (r == null) {
          _picked.remove(id);
        } else {
          _picked[id] = r.seed;
        }
      }
    });
  }

  void _addToSession(List<Muscle> muscles) {
    final planner = context.read<SessionPlanner>();
    final items = <SessionItem>[];
    for (final entry in _picked.entries) {
      final m = muscles.where((x) => x.id == entry.key).firstOrNull;
      if (m == null) continue;
      items.add(SessionItem(
        muscleId: m.id,
        muscleName: m.name,
        group: m.group,
        brand: _brand,
        dose: entry.value,
      ));
    }
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
    final over = _total > _ceiling;

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
              const SizedBox(height: 16),
              _brandRow(isDark, muscles),
              const SizedBox(height: 16),
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
                        fontSize: 10, color: AppTheme.textTertiary)),
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
                          fontSize: 13, color: AppTheme.textTertiary)),
                ),
              if (hidden > 0) ...[
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded,
                      size: 13, color: AppTheme.textTertiary),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                        '$hidden more ${hidden == 1 ? "muscle" : "muscles"} in this pattern '
                        '${hidden == 1 ? "has" : "have"} no ultrasound in the app and '
                        '${hidden == 1 ? "is" : "are"} not listed here.',
                        style: GoogleFonts.sourceSans3(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppTheme.textTertiary)),
                  ),
                ]),
              ],
            ],
          ),
        ),
        _footer(isDark, muscles, over),
      ]),
    );
  }

  Widget _brandRow(bool isDark, List<Muscle> muscles) {
    return Row(children: [
      for (final b in ['Botox', 'Xeomin', 'Dysport']) ...[
        Expanded(
          child: GestureDetector(
            onTap: () => _setBrand(b, muscles),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _brand == b
                    ? AppTheme.patternColor
                    : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                    color: _brand == b
                        ? AppTheme.patternColor
                        : (isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight)),
              ),
              child: Text(b.toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _brand == b
                          ? AppTheme.bgDark
                          : AppTheme.textSecondary)),
            ),
          ),
        ),
        if (b != 'Dysport') const SizedBox(width: 7),
      ],
    ]);
  }

  Widget _row(Muscle m, bool isDark) {
    final r = DoseRange.forBrand(m.dosage, _brand);
    final on = _picked.containsKey(m.id);
    final accent = AppTheme.groupColor(m.group);
    return GestureDetector(
      onTap: r == null ? null : () => _toggle(m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: on
              ? AppTheme.surfaceElevated
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
                  : Border.all(color: AppTheme.textTertiary, width: 1.5),
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
                Text(
                    r == null
                        ? 'No $_brand dose documented'
                        : '${m.pattern} · range ${r.label} U',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sourceSans3(
                        fontSize: 11.5,
                        color: r == null
                            ? AppTheme.danger
                            : AppTheme.textSecondary)),
              ],
            ),
          ),
          if (r != null) ...[
            const SizedBox(width: 8),
            Text('${DoseRange(r.seed, r.seed).label} U',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: on ? AppTheme.textStrong : AppTheme.textTertiary)),
          ],
        ]),
      ),
    );
  }

  Widget _footer(bool isDark, List<Muscle> muscles, bool over) {
    final pct = _ceiling <= 0 ? 0.0 : (_total / _ceiling).clamp(0.0, 1.0);
    final meter = over
        ? AppTheme.danger
        : (pct > 0.75 ? AppTheme.amber : AppTheme.success);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
            top: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${_brand.toUpperCase()} TOTAL',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppTheme.textSecondary)),
          const Spacer(),
          Text(DoseRange(_total, _total).label,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.textStrong
                      : AppTheme.textStrongLight)),
          Text(' / ${DoseRange(_ceiling, _ceiling).label} U',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12, color: AppTheme.textTertiary)),
        ]),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppTheme.surfaceElevated,
            valueColor: AlwaysStoppedAnimation(meter),
          ),
        ),
        if (over) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.error_outline_rounded, size: 13, color: AppTheme.danger),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                  'Over the $_brand session maximum before any bilateral doubling.',
                  style: GoogleFonts.sourceSans3(
                      fontSize: 11.5, color: AppTheme.danger)),
            ),
          ]),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _picked.isEmpty ? null : () => _addToSession(muscles),
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _picked.isEmpty
                  ? AppTheme.surfaceElevated
                  : AppTheme.patternColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
                _picked.isEmpty
                    ? 'SELECT MUSCLES TO PLAN'
                    : 'ADD ${_picked.length} TO SESSION',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _picked.isEmpty
                        ? AppTheme.textTertiary
                        : AppTheme.bgDark)),
          ),
        ),
      ]),
    );
  }
}
