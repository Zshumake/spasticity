import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/muscle_provider.dart';
import '../../data/session_planner.dart';
import '../../data/toxin_data.dart';
import '../../models/muscle.dart';
import '../../models/session_item.dart';
import '../../theme/app_theme.dart';

/// The injection "tray": muscles the clinician has added to the current
/// session, with editable brand / dose / side, and a per-brand running total
/// checked against each brand's labeled session ceiling.
class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planner = context.watch<SessionPlanner>();
    final muscles = context.watch<MuscleDataProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppTheme.primary : AppTheme.primaryDim),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('Session Plan',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          if (planner.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              tooltip: 'Clear session',
              onPressed: () => _confirmClear(context, planner),
            ),
        ],
      ),
      body: planner.isEmpty
          ? _emptyState(context, isDark)
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionLabel('TOTALS VS LABELED SESSION MAX', isDark),
                    const SizedBox(height: 8),
                    ...planner.brandTotals.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _brandMeter(e.key, e.value, isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('MUSCLES (${planner.count})', isDark),
                    const SizedBox(height: 8),
                    ...planner.items.map(
                      (it) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _itemRow(context, it, muscles, isDark),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _disclaimer(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────
  Widget _emptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.vaccines_outlined,
              size: 48, color: AppTheme.primary.withAlpha(120)),
          const SizedBox(height: 16),
          Text('No muscles in this session yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.textPrimaryLight)),
          const SizedBox(height: 8),
          Text(
            'Open a muscle and tap the tray icon to add it. '
            'Build a plan and watch the per-brand dose total against the '
            'session ceiling.',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondaryLight),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/'),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            label: const Text('Browse muscles'),
          ),
        ]),
      ),
    );
  }

  // ─── Brand ceiling meter ─────────────────────────────────────
  Widget _brandMeter(String brand, double total, bool isDark) {
    final b = brandByName(brand);
    final ceiling = b?.maxSessionUnits ?? 0;
    final ratio = ceiling > 0 ? total / ceiling : 0.0;
    final over = ratio > 1.0;
    final near = ratio >= 0.8;
    final meterColor =
        over ? AppTheme.danger : (near ? AppTheme.amberText(isDark) : AppTheme.success);
    final brandColor = b?.color ?? AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
            color: over ? AppTheme.danger.withAlpha(150) : brandColor.withAlpha(60)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.medication_outlined, size: 14, color: brandColor),
          const SizedBox(width: 6),
          Text(brand.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: brandColor)),
          const Spacer(),
          Text('${_fmt(total)} / $ceiling U',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12, fontWeight: FontWeight.w700, color: meterColor)),
        ]),
        const SizedBox(height: 10),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor:
                (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            valueColor: AlwaysStoppedAnimation<Color>(meterColor),
          ),
        ),
        if (over) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.danger),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Over the labeled session maximum by ${_fmt(total - ceiling)} U.',
                style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.danger),
              ),
            ),
          ]),
        ],
        if (b != null) ...[
          const SizedBox(height: 8),
          Text(b.maxDoseNote,
              style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  height: 1.4,
                  color: isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondaryLight)),
        ],
      ]),
    );
  }

  // ─── Session item row ────────────────────────────────────────
  Widget _itemRow(BuildContext context, SessionItem it,
      MuscleDataProvider muscles, bool isDark) {
    final planner = context.read<SessionPlanner>();
    final muscle = muscles.findById(it.muscleId);
    final groupColor = AppTheme.groupColor(it.group);
    final brands =
        muscle != null ? availableBrandsFor(muscle) : <String>[it.brand];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: name + total + delete
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: groupColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(it.muscleName,
                style: GoogleFonts.sora(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight)),
          ),
          Text('${_fmt(it.totalUnits)} U',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 13, fontWeight: FontWeight.w700, color: groupColor)),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            color: AppTheme.textTertiary,
            tooltip: 'Remove',
            onPressed: () => planner.remove(it.muscleId),
          ),
        ]),
        const SizedBox(height: 6),
        // Controls: brand / dose stepper / side
        Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          _brandPicker(context, it, muscle, brands, isDark),
          _doseStepper(context, it, isDark),
          _sideToggle(context, it, isDark),
        ]),
      ]),
    );
  }

  Widget _brandPicker(BuildContext context, SessionItem it, Muscle? muscle,
      List<String> brands, bool isDark) {
    final planner = context.read<SessionPlanner>();
    final brandColor = brandByName(it.brand)?.color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: brandColor.withAlpha(80)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: brands.contains(it.brand) ? it.brand : null,
          hint: Text(it.brand,
              style: GoogleFonts.ibmPlexMono(fontSize: 12, color: brandColor)),
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, size: 18, color: brandColor),
          dropdownColor:
              isDark ? AppTheme.surfaceElevated : AppTheme.surfaceLight,
          items: brands
              .map((b) => DropdownMenuItem(
                    value: b,
                    child: Text(b,
                        style: GoogleFonts.ibmPlexMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: brandByName(b)?.color ?? AppTheme.primary)),
                  ))
              .toList(),
          onChanged: muscle == null
              ? null
              : (b) {
                  if (b == null) return;
                  // Re-seed the dose to the new brand's midpoint, since units
                  // are not interchangeable across brands.
                  final seeded = doseForBrand(muscle, b) ?? it.dose;
                  planner.setBrand(it.muscleId, b, seeded);
                },
        ),
      ),
    );
  }

  Widget _doseStepper(BuildContext context, SessionItem it, bool isDark) {
    final planner = context.read<SessionPlanner>();
    final step = _doseStep(it.brand);
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    Widget btn(IconData icon, VoidCallback onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(Icons.remove_rounded,
            () => planner.setDose(it.muscleId, it.dose - step)),
        Container(
          constraints: const BoxConstraints(minWidth: 46),
          alignment: Alignment.center,
          child: Text('${_fmt(it.dose)} U',
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.textPrimaryLight)),
        ),
        btn(Icons.add_rounded,
            () => planner.setDose(it.muscleId, it.dose + step)),
      ]),
    );
  }

  Widget _sideToggle(BuildContext context, SessionItem it, bool isDark) {
    final planner = context.read<SessionPlanner>();
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    Widget seg(InjectionSide side) {
      final selected = it.side == side;
      return InkWell(
        onTap: () => planner.setSide(it.muscleId, side),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withAlpha(30) : Colors.transparent,
          ),
          child: Text(side.short,
              style: GoogleFonts.ibmPlexMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppTheme.primary : AppTheme.textTertiary)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          seg(InjectionSide.right),
          Container(width: 1, height: 26, color: border),
          seg(InjectionSide.left),
          Container(width: 1, height: 26, color: border),
          seg(InjectionSide.bilateral),
        ]),
      ),
    );
  }

  Widget _disclaimer(bool isDark) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded,
          size: 14, color: AppTheme.amberText(isDark)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Totals and ceilings are advisory. Brands are not interchangeable '
          '1:1 — always verify doses and per-session maxima against current '
          'product labeling before injecting.',
          style: GoogleFonts.sourceSans3(
              fontSize: 11,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: AppTheme.amberText(isDark)),
        ),
      ),
    ]);
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(text,
        style: GoogleFonts.ibmPlexMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight));
  }

  void _confirmClear(BuildContext context, SessionPlanner planner) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear session?'),
        content: const Text(
            'Remove all muscles from the current session plan? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              planner.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Dose increment per brand's unit scale.
  double _doseStep(String brand) {
    switch (brand) {
      case 'Myobloc':
        return 500;
      case 'Dysport':
        return 25;
      default:
        return 5;
    }
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
