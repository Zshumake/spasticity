import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/muscle_provider.dart';
import '../../data/session_planner.dart';
import '../../models/clinical_photo.dart';
import '../../models/muscle.dart';
import '../../theme/app_theme.dart';
import '../../theme/favorites_manager.dart';
import '../../theme/recently_viewed_manager.dart';
import '../../widgets/highlight/baked_highlight.dart';
import '../../widgets/info_card.dart';
import '../../widgets/step_list.dart';
import '../../widgets/landmark_list.dart';
import '../../widgets/safety_callout.dart';
import '../../widgets/video_link_card.dart';
import '../../widgets/print_cheat_sheet.dart';

class MuscleDetailScreen extends StatefulWidget {
  final Muscle muscle;
  const MuscleDetailScreen({super.key, required this.muscle});

  @override
  State<MuscleDetailScreen> createState() => _MuscleDetailScreenState();
}

class _MuscleDetailScreenState extends State<MuscleDetailScreen> {
  Muscle get muscle => widget.muscle;

  /// US safety notes not already surfaced as muscle-level [Muscle.dangerZones]
  /// (which are promoted from these notes for many muscles), so the same
  /// hazard never renders twice on one page.
  List<String> get _uniqueSafetyNotes {
    final us = muscle.ultrasound;
    if (us == null) return const [];
    return us.safetyNotes
        .where((n) => !muscle.dangerZones.contains(n))
        .toList();
  }

  bool _procedureMode = false;
  final Set<int> _checkedSupplies = {};
  /// Clinical-photo asset paths actually bundled in the app, so each slot can
  /// show the real photo once it exists and a placeholder until then.
  Set<String> _clinicalAssets = {};
  /// Baked highlight masks bundled under assets/images/us_reference/.
  Set<String> _maskAssets = {};
  /// Currently-selected anatomy view ('anterior', 'posterior', 'lateral').
  /// Initialized from the muscle's defaultAnatomyView — posterior-aspect
  /// muscles (hamstrings, triceps, gastroc, etc.) open to posterior view.
  late String _anatomyView;
  /// Selected ultrasound approach for multi-view muscles (index into
  /// [Muscle.resolvedUltrasoundViews]); always 0 for single-view muscles.
  int _usView = 0;

  @override
  void initState() {
    super.initState();
    // Pick initial view: explicit default from data, or 'anterior' fallback.
    // If the chosen view isn't actually present on this muscle, fall back
    // to whichever view is available.
    final preferred = muscle.defaultAnatomyView ?? 'anterior';
    if (muscle.anatomyImages.containsKey(preferred)) {
      _anatomyView = preferred;
    } else if (muscle.anatomyImages.isNotEmpty) {
      _anatomyView = muscle.anatomyImages.keys.first;
    } else {
      _anatomyView = 'anterior';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecentlyViewedManager>().recordView(muscle.id);
    });
    _loadClinicalAssets();
  }

  /// Loads the set of bundled clinical-photo paths so slots can distinguish a
  /// captured photo from a not-yet-shot placeholder.
  Future<void> _loadClinicalAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final all = manifest.listAssets();
      final clinical =
          all.where((p) => p.startsWith('${ClinicalPhotoSlot.dir}/')).toSet();
      final masks =
          all.where((p) => p.startsWith('assets/images/us_reference/')).toSet();
      if (mounted) {
        setState(() {
          _clinicalAssets = clinical;
          _maskAssets = masks;
        });
      }
    } catch (_) {
      // No manifest or no clinical assets yet — placeholders stay shown.
    }
  }

  /// The ultrasound approach currently on screen. Single-view muscles have
  /// exactly one; multi-view muscles (tibialis posterior) follow the toggle.
  UltrasoundView get _currentUsView {
    final views = muscle.resolvedUltrasoundViews;
    return views[_usView.clamp(0, views.length - 1)];
  }

  /// Whether the selected approach's ultrasound scan is actually bundled —
  /// the gate for every US-dependent surface (the highlighter, and the baked
  /// overlay).
  bool get _hasUltrasoundScan =>
      _clinicalAssets.contains(_currentUsView.scanAsset);

  Color get _groupColor => AppTheme.groupColor(muscle.group);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favs = context.watch<FavoritesManager>();
    final isFav = favs.isFavorite(muscle.id);
    final inSession = context.watch<SessionPlanner>().contains(muscle.id);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppTheme.primary : AppTheme.primaryDim),
          onPressed: () => context.pop(),
        ),
        title: Text(muscle.name, style: GoogleFonts.sora(
          fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(
              inSession ? Icons.playlist_add_check_rounded : Icons.playlist_add_rounded,
              color: inSession ? AppTheme.success : (isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
            tooltip: inSession ? 'In session — view plan' : 'Add to session',
            onPressed: () => _toggleSession(inSession),
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(isFav),
                color: isFav ? AppTheme.amber : (isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
            ),
            onPressed: () => favs.toggleFavorite(muscle.id),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 20),
            tooltip: 'Print cheat sheet',
            onPressed: () => printCheatSheet(context, muscle),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 20),
            tooltip: 'Copy procedure note',
            onPressed: () => _copyProcedureNote(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => setState(() => _procedureMode = !_procedureMode),
        backgroundColor: _procedureMode ? AppTheme.success : (isDark ? AppTheme.surfaceElevated : AppTheme.surfaceLight),
        foregroundColor: _procedureMode ? AppTheme.bgDark : _groupColor,
        tooltip: _procedureMode ? 'Switch to Study Mode' : 'Switch to Procedure Mode',
        child: Icon(_procedureMode ? Icons.menu_book_rounded : Icons.bolt_rounded, size: 20),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1100;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 1280 : 820),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 16),
                child: _procedureMode
                    ? _buildProcedureView(isDark)
                    : _buildStudyView(isDark, wide),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STUDY MODE — full educational content
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStudyView(bool isDark, bool wide) {
    // Two-column layout balanced by content weight.
    // Left:  Landmarks → Ultrasound Guide → Probe Placement
    // Right: Needle Placement → Setup & Tips → Pearls → Supplies
    // Clinical flow still intact (scan before inject) because
    // users read left-then-right as a natural top-down sequence.
    final left = <Widget>[
      _section('BONY LANDMARKS', Icons.location_on_outlined, null,
        LandmarkList(landmarks: muscle.landmarks)),
      const SizedBox(height: 16),
      _buildAnatomyReference(isDark),
      if (muscle.ultrasound != null) ...[
        const SizedBox(height: 16),
        _buildUltrasoundCard(isDark),
      ],
      const SizedBox(height: 16),
      _buildClinicalPhotos(isDark),
      if (muscle.videoUrl != null) ...[
        const SizedBox(height: 16),
        VideoLinkCard(
          videoUrl: muscle.videoUrl!,
          muscleTitle: muscle.name,
          accentColor: _groupColor,
        ),
      ],
    ];

    final right = <Widget>[
      _section('NEEDLE PLACEMENT', Icons.my_location, AppTheme.amber,
        StepList(steps: muscle.placement)),
      const SizedBox(height: 16),
      _section('SETUP & TIPS', Icons.lightbulb_outline, AppTheme.success,
        LandmarkList(landmarks: muscle.setup)),
      if (muscle.dangerZones.isNotEmpty) ...[
        const SizedBox(height: 16),
        SafetyCallout(
          warnings: muscle.dangerZones,
          title: 'Adjacent structures — what to avoid',
          icon: Icons.gpp_maybe_outlined,
        ),
      ],
      // What the TOXIN does, kept visually distinct from the needle hazards
      // above: for several muscles this is the injection's primary clinical
      // risk and it lives in neither needle-hazard layer.
      if (muscle.sideEffects.isNotEmpty) ...[
        const SizedBox(height: 16),
        SafetyCallout(
          warnings: muscle.sideEffects,
          title: 'Expected effects of weakening this muscle',
          icon: Icons.vaccines_outlined,
        ),
      ],
      if (muscle.pearls.isNotEmpty) ...[
        const SizedBox(height: 16),
        _buildPearlsCard(isDark),
      ],
      if (muscle.supplies.isNotEmpty) ...[
        const SizedBox(height: 16),
        _buildSuppliesChecklist(isDark),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroHeader(isDark),
        const SizedBox(height: 24),
        if (wide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: left,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: right,
                  ),
                ),
              ],
            ),
          )
        else ...[
          ...left,
          const SizedBox(height: 16),
          ...right,
        ],
        // Related muscles full-width
        if (muscle.relatedMuscles.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildRelatedMuscles(isDark),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PROCEDURE MODE — bedside-optimized compact view
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProcedureView(bool isDark) {
    final us = muscle.ultrasound;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_groupColor.withAlpha(30), Colors.transparent]),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: _groupColor.withAlpha(60)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.bolt_rounded, color: AppTheme.success, size: 16),
              const SizedBox(width: 6),
              Text('PROCEDURE MODE', style: GoogleFonts.ibmPlexMono(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.0,
                color: AppTheme.success)),
            ]),
            const SizedBox(height: 8),
            Text(muscle.name, style: GoogleFonts.sora(
              fontWeight: FontWeight.w800, fontSize: 20, color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
            if (muscle.dosage != null) ...[
              const SizedBox(height: 6),
              Text('Dosage: ${muscle.dosage!.displayFull}', style: GoogleFonts.ibmPlexMono(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.amber)),
              if (muscle.dosage!.hasAny) ...[
                const SizedBox(height: 8),
                _calcLink(),
              ],
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Probe info
        if (us != null) ...[
          _procSection('PROBE', us.probe),
          _procSection('ORIENTATION', us.orientation),
          if (us.depth != null) _procSection('DEPTH', us.depth!),
        ],

        // Supplies checklist in procedure mode
        if (muscle.supplies.isNotEmpty) ...[
          _buildSuppliesChecklist(isDark),
          const SizedBox(height: 12),
        ],

        // Landmarks - compact
        _procHeader('LANDMARKS'),
        ...muscle.landmarks.map((l) => _procBullet(l)),
        const SizedBox(height: 12),

        // Placement - compact
        _procHeader('NEEDLE PLACEMENT'),
        ...muscle.placement.asMap().entries.map((e) => _procStep(e.key + 1, e.value)),
        const SizedBox(height: 12),

        // Adjacent-structure hazards (muscle-level dangerZones)
        if (muscle.dangerZones.isNotEmpty) ...[
          _procHeader('ADJACENT STRUCTURES'),
          SafetyCallout(
            warnings: muscle.dangerZones,
            title: 'What to avoid',
            icon: Icons.gpp_maybe_outlined,
          ),
          const SizedBox(height: 12),
        ],

        if (muscle.sideEffects.isNotEmpty) ...[
          _procHeader('EXPECTED EFFECTS'),
          SafetyCallout(
            warnings: muscle.sideEffects,
            title: 'Effects of weakening this muscle',
            icon: Icons.vaccines_outlined,
          ),
          const SizedBox(height: 12),
        ],

        // Ultrasound-specific safety (excluding notes already shown as
        // adjacent-structure danger zones just above).
        if (_uniqueSafetyNotes.isNotEmpty) ...[
          _procHeader('US SAFETY'),
          SafetyCallout(warnings: _uniqueSafetyNotes),
          const SizedBox(height: 12),
        ],

        // What you see
        if (us != null) ...[
          _procHeader('CORRECT US IMAGE'),
          ...us.viewSteps.map((s) => _procBullet(s)),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _procHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(children: [
        Container(width: 12, height: 1.5, color: _groupColor.withAlpha(128)),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.ibmPlexMono(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: _groupColor)),
      ]),
    );
  }

  Widget _procSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.ibmPlexMono(
          fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AppTheme.textSecondary))),
        Expanded(child: Text(value, style: GoogleFonts.sourceSans3(fontSize: 13, height: 1.4,
          color: AppTheme.textPrimary))),
      ]),
    );
  }

  Widget _procBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 7),
          child: Container(width: 4, height: 4, decoration: BoxDecoration(
            color: _groupColor.withAlpha(150), shape: BoxShape.circle))),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: GoogleFonts.sourceSans3(fontSize: 13, height: 1.5))),
      ]),
    );
  }

  Widget _procStep(int n, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 22, height: 22,
          decoration: BoxDecoration(
            color: _groupColor.withAlpha(30), borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _groupColor.withAlpha(50))),
          alignment: Alignment.center,
          child: Text('$n', style: GoogleFonts.ibmPlexMono(
            color: _groupColor, fontSize: 10, fontWeight: FontWeight.w700))),
        const SizedBox(width: 12),
        Expanded(child: Padding(padding: const EdgeInsets.only(top: 2),
          child: Text(text, style: GoogleFonts.sourceSans3(fontSize: 13, height: 1.5)))),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPearlsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.amber.withAlpha(isDark ? 12 : 8),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.amber.withAlpha(40)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.amber.withAlpha(25),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: const Icon(Icons.star_rounded, color: AppTheme.amber, size: 16)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RESIDENT PEARLS', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: AppTheme.amber)),
            Text('Expert Tips & Institutional Wisdom', style: GoogleFonts.sourceSans3(
              fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ]),
        const SizedBox(height: 12),
        ...muscle.pearls.map((pearl) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 4),
              child: Icon(Icons.star_rounded, size: 12, color: AppTheme.amber.withAlpha(150))),
            const SizedBox(width: 10),
            Expanded(child: Text(pearl, style: GoogleFonts.sourceSans3(
              fontSize: 13, height: 1.5, color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight))),
          ]),
        )),
      ]),
    );
  }

  Widget _buildSuppliesChecklist(bool isDark) {
    final allChecked = _checkedSupplies.length == muscle.supplies.length;
    final borderColor = allChecked ? AppTheme.success.withAlpha(80) : (isDark ? AppTheme.borderDark : AppTheme.borderLight);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: borderColor, width: allChecked ? 1.5 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (allChecked ? AppTheme.success : _groupColor).withAlpha(20),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: Icon(
              allChecked ? Icons.check_circle_rounded : Icons.inventory_2_outlined,
              color: allChecked ? AppTheme.success : _groupColor, size: 16)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SUPPLIES', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.0,
              color: allChecked ? AppTheme.success : _groupColor)),
            Text(allChecked ? 'All supplies ready!' : '${_checkedSupplies.length}/${muscle.supplies.length} collected',
              style: GoogleFonts.sourceSans3(fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ]),
        const SizedBox(height: 12),
        ...muscle.supplies.asMap().entries.map((entry) {
          final i = entry.key;
          final supply = entry.value;
          final checked = _checkedSupplies.contains(i);
          return InkWell(
            onTap: () => setState(() {
              if (checked) { _checkedSupplies.remove(i); } else { _checkedSupplies.add(i); }
            }),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: checked ? AppTheme.success.withAlpha(30) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: checked ? AppTheme.success : AppTheme.textTertiary, width: 1.5)),
                  child: checked
                      ? const Icon(Icons.check_rounded, size: 14, color: AppTheme.success)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(supply, style: GoogleFonts.sourceSans3(
                  fontSize: 13, height: 1.4,
                  color: checked
                      ? (isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight)
                      : (isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
                  decoration: checked ? TextDecoration.lineThrough : null))),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildHeroHeader(bool isDark) {
    final us = muscle.ultrasound;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _groupColor.withAlpha(isDark ? 38 : 25),
            _groupColor.withAlpha(isDark ? 12 : 8),
            (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: _groupColor.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: _groupColor.withAlpha(isDark ? 38 : 20),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: group badge + accent line
          Row(children: [
            Container(width: 24, height: 2, color: _groupColor),
            const SizedBox(width: 10),
            Text(muscle.group.toUpperCase(), style: GoogleFonts.ibmPlexMono(
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: _groupColor)),
          ]),
          const SizedBox(height: 14),
          // Big title
          Text(muscle.name, style: GoogleFonts.sora(
            fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5,
            height: 1.1,
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
          const SizedBox(height: 10),
          // Pattern
          Text(muscle.pattern, style: GoogleFonts.sourceSans3(
            fontSize: 15, height: 1.5,
            color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight)),
          const SizedBox(height: 18),
          // Stat chips row — per-muscle dose shown per brand (Botox,
          // Xeomin, Dysport are NOT interchangeable 1:1; Dysport ≈ 3× Botox).
          Wrap(spacing: 10, runSpacing: 10, children: [
            if (muscle.dosage?.botox != null)
              _heroChip(Icons.medication_outlined, 'BOTOX',
                  '${muscle.dosage!.botox!} U',
                  const Color(0xFF3E8FE0), isDark, // brand-botox
                  onTap: () => _openCalculator('Botox', muscle.dosage!.botox!)),
            if (muscle.dosage?.xeomin != null)
              _heroChip(Icons.medication_outlined, 'XEOMIN',
                  '${muscle.dosage!.xeomin!} U',
                  const Color(0xFFA05BC4), isDark, // brand-xeomin
                  onTap: () => _openCalculator('Xeomin', muscle.dosage!.xeomin!)),
            if (muscle.dosage?.dysport != null)
              _heroChip(Icons.medication_outlined, 'DYSPORT',
                  '${muscle.dosage!.dysport!} U',
                  const Color(0xFFE59A2E), isDark, // brand-dysport
                  onTap: () => _openCalculator('Dysport', muscle.dosage!.dysport!)),
            if (us != null)
              _heroChip(Icons.sensors, 'PROBE', _shortProbe(us.probe), _groupColor, isDark),
            if (us != null)
              _heroChip(Icons.swap_horiz, 'ORIENTATION', _shortOrient(us.orientation), _groupColor, isDark),
            if (us?.depth != null)
              _heroChip(Icons.straighten, 'DEPTH', us!.depth!, _groupColor, isDark),
          ]),
          // Dosage note (italic small text under the chips)
          if (muscle.dosageNote != null) ...[
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, size: 12, color: AppTheme.amberText(isDark)),
              const SizedBox(width: 6),
              Expanded(child: Text(muscle.dosageNote!,
                style: GoogleFonts.sourceSans3(
                  fontSize: 11, fontStyle: FontStyle.italic,
                  height: 1.4, color: AppTheme.amberText(isDark)))),
            ]),
          ],
        ],
      ),
    );
  }

  String _shortProbe(String s) {
    if (s.toLowerCase().contains('linear')) return 'Linear';
    if (s.toLowerCase().contains('curvilinear')) return 'Curvilinear';
    if (s.toLowerCase().contains('hockey')) return 'Hockey-stick';
    return s.length > 24 ? '${s.substring(0, 24)}…' : s;
  }

  String _shortOrient(String s) {
    if (s.toLowerCase().startsWith('transverse')) return 'Transverse';
    if (s.toLowerCase().startsWith('longitudinal')) return 'Longitudinal';
    if (s.toLowerCase().startsWith('parasagittal')) return 'Parasagittal';
    return s.length > 28 ? '${s.substring(0, 28)}…' : s;
  }

  Widget _heroChip(IconData icon, String label, String value, Color accent, bool isDark, {VoidCallback? onTap}) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.bgDark : AppTheme.bgLight).withAlpha(178),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: accent.withAlpha(60)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: accent),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: GoogleFonts.ibmPlexMono(
            fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5,
            color: accent.withAlpha(200))),
          Text(value, style: GoogleFonts.sourceSans3(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
        ]),
        // Tappable dose chips show a calculator hint and open the dilution
        // calculator pre-seeded with this brand + dose.
        if (onTap != null) ...[
          const SizedBox(width: 8),
          Icon(Icons.calculate_outlined, size: 14, color: accent.withAlpha(160)),
        ],
      ]),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: content,
      ),
    );
  }

  /// Opens the dose calculator pre-seeded with [brand] and the midpoint of
  /// the muscle's dose [range] (e.g. "100-200" -> 150), which the user can
  /// then adjust. Closes the muscle -> dose -> calculator gap.
  void _openCalculator(String brand, String range) {
    final dose = _midpointDose(range);
    final query = dose != null
        ? '?brand=$brand&dose=${dose.toStringAsFixed(0)}'
        : '?brand=$brand';
    context.push('/calculator$query');
  }

  /// Adds this muscle to the session plan (seeded brand + midpoint dose), or
  /// navigates to the plan if it is already there.
  void _toggleSession(bool inSession) {
    if (inSession) {
      context.push('/session');
      return;
    }
    final item = defaultSessionItem(muscle);
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No dose data to add for this muscle.')),
      );
      return;
    }
    context.read<SessionPlanner>().addOrUpdate(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${muscle.name} to session'),
        action: SnackBarAction(
            label: 'View', onPressed: () => context.push('/session')),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Midpoint of a dose-range string: "100-200" -> 150, "100" -> 100.
  double? _midpointDose(String range) {
    final nums = RegExp(r'\d+(?:\.\d+)?')
        .allMatches(range)
        .map((m) => double.parse(m.group(0)!))
        .toList();
    if (nums.isEmpty) return null;
    if (nums.length == 1) return nums.first;
    return ((nums.first + nums[1]) / 2).roundToDouble();
  }

  /// Tappable link under the procedure-mode dose line that opens the
  /// calculator pre-seeded with the muscle's preferred brand (Botox, then
  /// Xeomin, then Dysport) and dose.
  Widget _calcLink() {
    final d = muscle.dosage!;
    final String brand;
    final String range;
    if (d.botox != null) {
      brand = 'Botox';
      range = d.botox!;
    } else if (d.xeomin != null) {
      brand = 'Xeomin';
      range = d.xeomin!;
    } else if (d.dysport != null) {
      brand = 'Dysport';
      range = d.dysport!;
    } else {
      // hasAny was true but none of the known brands matched — nothing to seed.
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () => _openCalculator(brand, range),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calculate_outlined, size: 14, color: AppTheme.success),
          const SizedBox(width: 6),
          Text('Calculate draw-up volume', style: GoogleFonts.ibmPlexMono(
            fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, size: 12, color: AppTheme.success),
        ]),
      ),
    );
  }

  Widget _section(String title, IconData icon, Color? color, Widget child) {
    final c = color ?? _groupColor;
    return InfoCard(title: title, icon: icon, iconColor: c, child: child);
  }

  /// Full-width anatomy reference: rendered image showing the bones with
  /// the target muscle highlighted. Sourced from Z-Anatomy (CC-BY-SA 4.0)
  /// and Wikimedia Commons Anatomography (CC-BY-SA 2.1 JP).
  ///
  /// Placement in the study view: between Bony Landmarks and Ultrasound
  /// Guide — this is the "understand the target" block before the
  /// "execute the injection" block (probe placement + US needle shot).
  Widget _buildAnatomyReference(bool isDark) {
    final views = muscle.anatomyImages; // Map<String, String>
    final hasImages = views.isNotEmpty;

    // Resolve the currently-selected view (fall back to any available view
    // if anterior isn't set)
    String? activeView = _anatomyView;
    if (hasImages && !views.containsKey(activeView)) {
      activeView = views.keys.first;
    }
    final imagePath = hasImages
        ? 'assets/images/anatomy/${views[activeView]}'
        : null;

    // Auto-generate a per-view caption if none is provided in JSON
    final caption = muscle.anatomyCaption
        ?? '${_viewLabel(activeView)} view · ${muscle.name} highlighted';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header (group-colored for regional continuity)
        Row(children: [
          Container(width: 24, height: 2, color: _groupColor),
          const SizedBox(width: 10),
          Text('ANATOMY REFERENCE', style: GoogleFonts.ibmPlexMono(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 2.0, color: _groupColor)),
        ]),
        const SizedBox(height: 10),

        // View-switcher chips (only shown if multiple views available)
        if (views.length > 1) ...[
          Row(children: [
            for (final view in ['anterior', 'lateral', 'posterior'])
              if (views.containsKey(view))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _viewChip(view, isDark),
                ),
          ]),
          const SizedBox(height: 10),
        ],

        // The card itself — full-width, 220px tall, 16:10 intrinsic
        // Supports tap-to-enlarge AND horizontal swipe to cycle views.
        GestureDetector(
          onTap: hasImages
              ? () => _showFullImage(context, imagePath!,
                  '${muscle.name} — ${_viewLabel(activeView!)}')
              : null,
          onHorizontalDragEnd: hasImages && views.length > 1
              ? (details) {
                  // Positive primaryVelocity = swipe right → previous view
                  // Negative primaryVelocity = swipe left  → next view
                  // Only respond to decisive swipes (>300 px/s).
                  final v = details.primaryVelocity ?? 0;
                  if (v.abs() < 300) return;
                  _cycleAnatomyView(forward: v < 0);
                }
              : null,
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: _groupColor.withAlpha(60)),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImages
                ? Stack(fit: StackFit.expand, children: [
                    // Letterbox tint to avoid harsh borders with BoxFit.contain
                    Container(color: _groupColor.withAlpha(8)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        // Slide + fade, gives the "rotating through images" feel
                        final offset = Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: offset, child: child),
                        );
                      },
                      child: Image.asset(
                        imagePath!,
                        key: ValueKey(activeView),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => _anatomyPlaceholder(isDark),
                      ),
                    ),
                    // Caption overlay
                    Positioned(left: 0, right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withAlpha(170)],
                          ),
                        ),
                        child: Text(caption.toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(220),
                            letterSpacing: 0.8)),
                      ),
                    ),
                    // Tap-to-enlarge hint
                    Positioned(top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.zoom_in,
                            size: 14, color: Colors.white70),
                      ),
                    ),
                  ])
                : _anatomyPlaceholder(isDark),
          ),
        ),
      ],
    );
  }

  String _viewLabel(String view) {
    switch (view) {
      case 'anterior': return 'Anterior';
      case 'posterior': return 'Posterior';
      case 'lateral': return 'Lateral';
      case 'medial': return 'Medial';
      default: return view[0].toUpperCase() + view.substring(1);
    }
  }

  /// Advance (or reverse) through the available anatomy views.
  /// Canonical order: anterior → lateral → posterior → (wraps to anterior).
  /// Respects the view set actually present on this muscle — if one view
  /// is missing, it's skipped.
  void _cycleAnatomyView({required bool forward}) {
    const canonical = ['anterior', 'lateral', 'posterior'];
    final available = canonical.where(muscle.anatomyImages.containsKey).toList();
    if (available.length < 2) return;
    final current = available.indexOf(_anatomyView);
    final i = current < 0 ? 0 : current;
    final next = forward
        ? (i + 1) % available.length
        : (i - 1 + available.length) % available.length;
    setState(() => _anatomyView = available[next]);
  }

  /// Chip for the ultrasound-approach toggle, styled to match the anatomy
  /// view chips but keyed by index into [Muscle.resolvedUltrasoundViews].
  Widget _usViewChip(int index, String label, bool isDark) {
    final active = _usView == index;
    return GestureDetector(
      onTap: () => setState(() => _usView = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? AppTheme.primary.withAlpha(140)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
        ),
        child: Text(label.toUpperCase(),
          style: GoogleFonts.ibmPlexMono(
            fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4,
            color: active ? AppTheme.primary : AppTheme.textTertiary)),
      ),
    );
  }

  Widget _viewChip(String view, bool isDark) {
    final active = _anatomyView == view ||
        (!muscle.anatomyImages.containsKey(_anatomyView) &&
         view == muscle.anatomyImages.keys.first);
    return GestureDetector(
      onTap: () => setState(() => _anatomyView = view),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _groupColor.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? _groupColor.withAlpha(140)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
        ),
        child: Text(_viewLabel(view).toUpperCase(),
          style: GoogleFonts.ibmPlexMono(
            fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4,
            color: active ? _groupColor : AppTheme.textTertiary)),
      ),
    );
  }

  Widget _anatomyPlaceholder(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _groupColor.withAlpha(20),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            child: Icon(Icons.view_in_ar_outlined,
                color: _groupColor.withAlpha(140), size: 28),
          ),
          const SizedBox(height: 12),
          Text('ANATOMY COMING SOON', style: GoogleFonts.ibmPlexMono(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 2.0, color: _groupColor.withAlpha(200))),
          const SizedBox(height: 6),
          Text('3D anatomy reference from Z-Anatomy',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
              fontSize: 11, height: 1.4,
              color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
        ],
      ),
    );
  }

  /// The two clinical photo slots:
  ///   1. Probe + needle site — atlas illustration of the surface anatomy
  ///      (blue bar = probe footprint, red dot = needle entry)
  ///   2. Ultrasound image of the target muscle
  /// (The patient-position slot was retired 2026-08: the probe illustration
  /// already shows the posture, so a third card added noise, not signal.)
  /// Shows real images when available, otherwise a styled placeholder
  /// prompting the user to add their own.
  Widget _buildClinicalPhotos(bool isDark) {
    // Accent per slot (avoid alarming red).
    const accents = {
      ClinicalPhotoSlot.position: AppTheme.success, // retired from display
      ClinicalPhotoSlot.probe: AppTheme.primary,
      ClinicalPhotoSlot.ultrasound: AppTheme.amber,
    };

    // Both big pictures resolve through the selected ultrasound approach so
    // they always agree: the probe illustration encodes where the transducer
    // sits, and the scan is what that placement shows. For single-view
    // muscles the resolved view is just the muscle's own probe/scan pair.
    final views = muscle.resolvedUltrasoundViews;
    final view = _currentUsView;

    // Only the slots whose asset is actually bundled are rendered - a muscle
    // with no imagery gets no section at all rather than placeholder cards.
    String? pathFor(ClinicalPhotoSlot s) =>
        s == ClinicalPhotoSlot.probe ? view.probeAsset : view.scanAsset;
    final shown = [ClinicalPhotoSlot.probe, ClinicalPhotoSlot.ultrasound]
        .where((s) {
          final p = pathFor(s);
          return p != null && _clinicalAssets.contains(p);
        })
        .toList();
    if (shown.isEmpty && views.length == 1) return const SizedBox.shrink();

    Widget slot(ClinicalPhotoSlot s, {double height = 180}) {
      final path = pathFor(s)!;
      final has = _clinicalAssets.contains(path);
      // The scan renders with this muscle's baked highlight tint whenever the
      // mask produced by tools/refine_highlights.py is bundled; otherwise the
      // plain scan shows. Per-muscle even on shared scans - the mask is what
      // distinguishes gastrocnemius from soleus on the same image.
      if (s == ClinicalPhotoSlot.ultrasound &&
          has &&
          _maskAssets.contains(view.maskAsset)) {
        return SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: BakedHighlight(
              scanAsset: path,
              maskAsset: view.maskAsset,
              accent: BakedHighlight.regionTint(muscle.group),
            ),
          ),
        );
      }
      return _imageSlot(
        isDark: isDark,
        title: s.label,
        subtitle: s.description,
        icon: s.icon,
        accentColor: accents[s]!,
        imagePath: has ? path : null,
        imageLabel: views.length > 1
            ? '${muscle.name} — ${view.label} — ${s.label}'
            : '${muscle.name} — ${s.label}',
        fileName: path.split('/').last,
        height: height,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(children: [
          Container(width: 24, height: 2, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text('CLINICAL PHOTOS', style: GoogleFonts.ibmPlexMono(
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 2.0, color: AppTheme.primary)),
        ]),
        const SizedBox(height: 14),

        // Approach toggle for multi-view muscles: swaps the probe
        // illustration AND the scan together, since they describe the same
        // transducer placement.
        if (views.length > 1) ...[
          Row(children: [
            for (var i = 0; i < views.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _usViewChip(i, views[i].label, isDark),
              ),
          ]),
          const SizedBox(height: 12),
        ],

        // BIG stacked images - only the ones that exist - each full column
        // width. Tap either for the full-resolution viewer.
        for (final s in shown) ...[
          slot(s, height: 420),
          if (s != shown.last) const SizedBox(height: 12),
        ],
        // The highlighter has nothing to draw on until this muscle's US scan
        // is bundled, so the entry point only appears once it is; gating on
        // the asset means it turns itself on as scans are added.
        if (_hasUltrasoundScan) ...[
          const SizedBox(height: 12),
          _highlightCta(isDark),
        ],

        // Photo hint (if available)
        if (muscle.probePlacementHint != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.primary.withAlpha(30))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.camera_alt_outlined, size: 12,
                  color: AppTheme.primary.withAlpha(160)),
              const SizedBox(width: 8),
              Expanded(child: Text(muscle.probePlacementHint!,
                style: GoogleFonts.sourceSans3(fontSize: 11, height: 1.4,
                  color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight))),
            ]),
          ),
        ],
      ],
    );
  }

  /// Entry point to the draw-to-highlight surface for this muscle's US image.
  Widget _highlightCta(bool isDark) {
    return GestureDetector(
      // Carry the selected approach so the lasso lands on the scan that is
      // actually on screen (tibialis posterior: anterior vs medial window).
      onTap: () => context.push('/highlight/${muscle.id}?view=$_usView'),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withAlpha(isDark ? 22 : 14),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.primary.withAlpha(70)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.gesture, color: AppTheme.primary, size: 26),
            const SizedBox(height: 10),
            Text('HIGHLIGHT',
                style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppTheme.primary)),
            const SizedBox(height: 6),
            Text('Draw to outline the muscle on US and surface adjacent structures.',
                style: GoogleFonts.sourceSans3(
                    fontSize: 11.5,
                    height: 1.35,
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight)),
            const SizedBox(height: 8),
            Row(children: [
              Text('Open',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 13, color: AppTheme.primary),
            ]),
          ],
        ),
      ),
    );
  }

  /// Single image slot: shows the image if [imagePath] is set, otherwise
  /// a placeholder card with an icon + description.
  Widget _imageSlot({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String? imagePath,
    required String imageLabel,
    String? fileName,
    double height = 180,
  }) {
    final hasImage = imagePath != null;
    return GestureDetector(
      onTap: hasImage ? () => _showFullImage(context, imagePath, imageLabel) : null,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: hasImage
                ? accentColor.withAlpha(60)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(children: [
                Positioned.fill(
                  child: Image.asset(imagePath, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholderContent(
                        isDark, title, subtitle, icon, accentColor,
                        fileName: fileName)),
                ),
                // Gradient overlay at bottom with label
                Positioned(left: 0, right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withAlpha(180)],
                      ),
                    ),
                    child: Text(title.replaceAll('\n', ' '),
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 9, fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(220), letterSpacing: 0.8)),
                  ),
                ),
                // Tap-to-enlarge hint
                Positioned(top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(120),
                      borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.zoom_in, size: 14, color: Colors.white70),
                  ),
                ),
              ])
            : _placeholderContent(isDark, title, subtitle, icon, accentColor,
                fileName: fileName),
      ),
    );
  }

  Widget _placeholderContent(bool isDark, String title, String subtitle,
      IconData icon, Color accentColor, {String? fileName}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            child: Icon(icon, color: accentColor.withAlpha(140), size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.sourceSans3(
              fontSize: 12, fontWeight: FontWeight.w700, height: 1.2,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
          const SizedBox(height: 4),
          // Show the exact target filename when this is a capture placeholder,
          // otherwise the generic description (image-load fallback).
          Text(fileName ?? subtitle, textAlign: TextAlign.center,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: fileName != null
                ? GoogleFonts.ibmPlexMono(
                    fontSize: 8, height: 1.3,
                    color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)
                : GoogleFonts.sourceSans3(
                    fontSize: 10, height: 1.3,
                    color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accentColor.withAlpha(40))),
            child: Text(fileName != null ? 'PHOTO NEEDED' : 'ADD PHOTO',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 8, fontWeight: FontWeight.w700,
                letterSpacing: 1.5, color: accentColor.withAlpha(180))),
          ),
        ],
      ),
    );
  }

  Widget _buildUltrasoundCard(bool isDark) {
    final us = muscle.ultrasound!;
    return _section('ULTRASOUND GUIDE', Icons.monitor_heart_outlined, AppTheme.primary,
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          _badge(us.probe), _badge(us.orientation),
          if (us.depth != null) _badge('Depth: ${us.depth}'),
        ]),
        const SizedBox(height: 16),
        Text('WHAT YOU SEE', style: GoogleFonts.ibmPlexMono(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        StepList(steps: us.viewSteps),
        if (_uniqueSafetyNotes.isNotEmpty) ...[
          const SizedBox(height: 12), SafetyCallout(warnings: _uniqueSafetyNotes)],
        if (us.videoSource != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.videocam_outlined, size: 14, color: AppTheme.textTertiary),
            const SizedBox(width: 6),
            Expanded(child: Text(us.videoSource!, style: GoogleFonts.sourceSans3(
              fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textTertiary))),
          ]),
        ],
      ]),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.primary.withAlpha(40))),
      child: Text(text, style: GoogleFonts.ibmPlexMono(
        fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
    );
  }

  void _showFullImage(BuildContext context, String path, String title) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(fontSize: 16))),
      body: InteractiveViewer(minScale: 0.5, maxScale: 5.0,
        child: Center(child: Image.asset(path, fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Center(
            child: Text('Image not found', style: TextStyle(color: Colors.white54)))))),
    )));
  }

  Widget _buildRelatedMuscles(bool isDark) {
    final data = context.read<MuscleDataProvider>();
    final relatedMuscles = muscle.relatedMuscles
        .map((id) => data.findById(id))
        .where((m) => m != null)
        .cast<Muscle>()
        .toList();

    if (relatedMuscles.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.patternColor.withAlpha(20),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: const Icon(Icons.hub_rounded, color: AppTheme.patternColor, size: 16)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RELATED MUSCLES', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2.0,
              color: AppTheme.patternColor)),
            Text('Often co-injected in the same pattern', style: GoogleFonts.sourceSans3(
              fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: relatedMuscles.map((rm) => InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () => context.push('/muscle/${rm.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.patternColor.withAlpha(isDark ? 15 : 10),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.patternColor.withAlpha(40)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_forward_rounded,
                  size: 12, color: AppTheme.patternColor.withAlpha(150)),
                const SizedBox(width: 6),
                Text(rm.name, style: GoogleFonts.sourceSans3(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
              ]),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  void _copyProcedureNote(BuildContext context) {
    final note = 'Under ultrasound guidance, the needle was advanced into the '
        '${muscle.name} muscle. Position was confirmed with muscular '
        'architecture visualization. After negative aspiration, '
        'Botulinum Toxin was injected.';
    Clipboard.setData(ClipboardData(text: note));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Procedure note copied'), duration: Duration(seconds: 2)));
  }
}
