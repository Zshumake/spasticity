import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/muscle.dart';
import '../../theme/app_theme.dart';
import '../../theme/favorites_manager.dart';
import '../../theme/recently_viewed_manager.dart';
import '../../widgets/info_card.dart';
import '../../widgets/step_list.dart';
import '../../widgets/landmark_list.dart';
import '../../widgets/safety_callout.dart';
import '../../widgets/anatomy_diagram.dart';
import '../../widgets/us_image_gallery.dart';
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
  bool _procedureMode = false;
  final Set<int> _checkedSupplies = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecentlyViewedManager>().recordView(muscle.id);
    });
  }

  Color get _groupColor => AppTheme.groupColor(muscle.group);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favs = context.watch<FavoritesManager>();
    final isFav = favs.isFavorite(muscle.id);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        title: Text(muscle.name, style: GoogleFonts.sora(
          fontWeight: FontWeight.w700, fontSize: 16)),
        actions: [
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _procedureMode ? _buildProcedureView(isDark) : _buildStudyView(isDark),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STUDY MODE — full educational content
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStudyView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(isDark),
        const SizedBox(height: 20),
        _buildProbePlacement(),
        const SizedBox(height: 12),
        _section('BONY LANDMARKS', Icons.location_on_outlined, null,
          LandmarkList(landmarks: muscle.landmarks)),
        const SizedBox(height: 12),
        _section('NEEDLE PLACEMENT', Icons.my_location, AppTheme.amber,
          StepList(steps: muscle.placement)),
        const SizedBox(height: 12),
        // Anatomy diagram: probe position + expected US view side-by-side
        _buildAnatomyDiagram(),
        const SizedBox(height: 12),
        // US image gallery (upgraded with thumbnails)
        if (muscle.referenceImages.isNotEmpty) ...[
          _buildUSGallery(), const SizedBox(height: 12),
        ] else ...[
          _buildImagePlaceholder(), const SizedBox(height: 12),
        ],
        if (muscle.ultrasound != null) ...[
          _buildUltrasoundCard(isDark), const SizedBox(height: 12),
        ],
        _section('SETUP & TIPS', Icons.lightbulb_outline, AppTheme.success,
          LandmarkList(landmarks: muscle.setup)),
        if (muscle.pearls.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildPearlsCard(isDark),
        ],
        if (muscle.supplies.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSuppliesChecklist(isDark),
        ],
        // Video link
        if (muscle.videoUrl != null) ...[
          const SizedBox(height: 12),
          VideoLinkCard(
            videoUrl: muscle.videoUrl!,
            muscleTitle: muscle.name,
            accentColor: _groupColor,
          ),
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
              Text('Dosage: ${muscle.dosage}', style: GoogleFonts.ibmPlexMono(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.amber)),
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

        // Safety
        if (us != null && us.safetyNotes.isNotEmpty) ...[
          _procHeader('SAFETY'),
          SafetyCallout(warnings: us.safetyNotes),
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

  Widget _buildHeader(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Group badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _groupColor.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _groupColor.withAlpha(38))),
        child: Text(muscle.group.toUpperCase(), style: GoogleFonts.ibmPlexMono(
          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: _groupColor)),
      ),
      const SizedBox(height: 8),
      Text(muscle.pattern, style: GoogleFonts.sourceSans3(fontSize: 14, color: AppTheme.textSecondary)),
      if (muscle.dosage != null) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.amber.withAlpha(25),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.amber.withAlpha(60))),
          child: Text('Dosage: ${muscle.dosage}', style: GoogleFonts.ibmPlexMono(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.amber)),
        ),
      ],
    ]);
  }

  Widget _section(String title, IconData icon, Color? color, Widget child) {
    final c = color ?? _groupColor;
    return InfoCard(title: title, icon: icon, iconColor: c, child: child);
  }

  Widget _buildProbePlacement() {
    final images = muscle.probePlacementImages;
    if (images.isNotEmpty) {
      return _section('PROBE PLACEMENT', Icons.sensors, AppTheme.primary,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Where to place the ultrasound probe — tap to enlarge',
            style: GoogleFonts.sourceSans3(fontSize: 12, color: AppTheme.textSecondary.withAlpha(150))),
          const SizedBox(height: 12),
          SizedBox(height: 240, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final path = 'assets/images/probe_placement/${images[i]}';
              return GestureDetector(
                onTap: () => _showFullImage(ctx, path, '${muscle.name} — Probe'),
                child: ClipRRect(borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(width: 320,
                    decoration: BoxDecoration(color: AppTheme.bgDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.primary.withAlpha(60))),
                    child: Image.asset(path, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(child: Icon(
                        Icons.broken_image_outlined, size: 40, color: AppTheme.textTertiary))))),
              );
            },
          )),
        ]),
      );
    }

    // Placeholder with photo hint
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hint = muscle.probePlacementHint;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            child: Icon(Icons.sensors, color: AppTheme.primary.withAlpha(180), size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Probe Placement Photo Needed', style: GoogleFonts.sourceSans3(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
            const SizedBox(height: 2),
            Text('Add a photo showing probe position for ${muscle.name}',
              style: GoogleFonts.sourceSans3(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ]),
        if (hint != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.primary.withAlpha(40))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.camera_alt_outlined, size: 14, color: AppTheme.primary.withAlpha(180)),
                const SizedBox(width: 6),
                Text('PHOTO GUIDE', style: GoogleFonts.ibmPlexMono(
                  fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary.withAlpha(180), letterSpacing: 1.2)),
              ]),
              const SizedBox(height: 8),
              Text(hint, style: GoogleFonts.sourceSans3(fontSize: 13, height: 1.5, color: AppTheme.textSecondary)),
            ]),
          ),
        ],
      ]),
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
        if (us.safetyNotes.isNotEmpty) ...[
          const SizedBox(height: 12), SafetyCallout(warnings: us.safetyNotes)],
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

  Widget _buildAnatomyDiagram() {
    // Use first probe placement image and first reference image for split view
    final probeImg = muscle.probePlacementImages.isNotEmpty
        ? 'assets/images/probe_placement/${muscle.probePlacementImages.first}'
        : null;
    final usImg = muscle.referenceImages.isNotEmpty
        ? 'assets/images/us_reference/${muscle.referenceImages.first}'
        : null;

    return AnatomyDiagram(
      probePositionImg: probeImg,
      expectedUsImg: usImg,
      accentColor: _groupColor,
      muscleTitle: muscle.name,
      onTapProbe: probeImg != null
          ? () => _showFullImage(context, probeImg, 'Probe Position')
          : null,
      onTapUs: usImg != null
          ? () => _showFullImage(context, usImg, 'Expected US View')
          : null,
    );
  }

  Widget _buildUSGallery() {
    final paths = muscle.referenceImages
        .map((name) => 'assets/images/us_reference/$name')
        .toList();
    // Use filenames (without extension) as labels
    final labels = muscle.referenceImages
        .map((name) => name.replaceAll(RegExp(r'\.[^.]+$'), '').replaceAll('-', ' ').replaceAll('_', ' '))
        .toList();

    return USImageGallery(
      imagePaths: paths,
      imageLabels: labels,
      accentColor: _groupColor,
      muscleTitle: muscle.name,
    );
  }

  Widget _buildImagePlaceholder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
      child: Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: AppTheme.amber.withAlpha(25),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          child: Icon(Icons.add_photo_alternate_outlined, color: AppTheme.amber.withAlpha(180), size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('US Reference Image Needed', style: GoogleFonts.sourceSans3(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
          const SizedBox(height: 2),
          Text('Add your own annotated ultrasound screenshot for ${muscle.name}',
            style: GoogleFonts.sourceSans3(fontSize: 12, color: AppTheme.textSecondary)),
        ])),
      ]),
    );
  }

  void _showFullImage(BuildContext context, String path, String title) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black,
        title: Text('${muscle.name} — US View', style: const TextStyle(fontSize: 16))),
      body: InteractiveViewer(minScale: 0.5, maxScale: 5.0,
        child: Center(child: Image.asset(path, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('Image not found', style: TextStyle(color: Colors.white54)))))),
    )));
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
