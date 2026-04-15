import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/muscle_data.dart';
import '../data/muscle_provider.dart';
import '../models/muscle.dart';
import '../models/spasticity_pattern.dart';
import '../theme/app_theme.dart';
import '../theme/favorites_manager.dart';
import '../theme/recently_viewed_manager.dart';
import '../widgets/muscle_card.dart';

class DashboardPage extends StatefulWidget {
  final String? initialCategory;
  const DashboardPage({super.key, this.initialCategory});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchQuery = '';
  /// null = show the pattern landing page; non-null = show filtered muscle grid
  String? _selectedCategory;
  List<SpasticityPattern> _patterns = [];

  final _pageFocusNode = FocusNode();
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadPatterns();
    _searchFocusNode.addListener(() { if (mounted) setState(() {}); });
  }

  Future<void> _loadPatterns() async {
    final patterns = await MuscleData.loadPatterns();
    if (mounted) setState(() => _patterns = patterns);
  }

  bool get _isPatternCategory =>
      _selectedCategory != null && _patterns.any((p) => p.id == _selectedCategory);

  SpasticityPattern? get _selectedPattern =>
      _selectedCategory != null
          ? _patterns.where((p) => p.id == _selectedCategory).firstOrNull
          : null;

  /// True when we should show the pattern landing page
  bool get _showPatternLanding => _selectedCategory == null && _searchQuery.isEmpty;

  @override
  void dispose() {
    _pageFocusNode.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Muscle> _getFiltered(BuildContext context) {
    final data = context.read<MuscleDataProvider>();
    final favs = context.read<FavoritesManager>();
    final recent = context.read<RecentlyViewedManager>();
    if (!data.isLoaded) return [];

    if (_selectedCategory == 'Recent') {
      return recent.recentIds
          .map((id) => data.findById(id))
          .where((m) => m != null)
          .cast<Muscle>()
          .where(_matchesSearch)
          .toList();
    }

    return data.muscles.where((m) {
      if (!_matchesSearch(m)) return false;
      if (_selectedCategory == null || _selectedCategory == 'All') return true;
      if (_selectedCategory == 'Favorites') return favs.isFavorite(m.id);
      if (_isPatternCategory) return m.spasticityPatterns.contains(_selectedCategory);
      return m.group.contains(_selectedCategory!);
    }).toList();
  }

  bool _matchesSearch(Muscle m) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return m.name.toLowerCase().contains(q) ||
        m.group.toLowerCase().contains(q) ||
        m.pattern.toLowerCase().contains(q) ||
        m.id.toLowerCase().contains(q);
  }

  /// When user types in search, switch to "All" filter to show matches globally
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _selectedIndex = -1;
      // If searching, show results across all muscles
      if (value.isNotEmpty && _selectedCategory == null) {
        _selectedCategory = 'All';
      }
      // If search cleared, return to pattern landing
      if (value.isEmpty && _selectedCategory == 'All') {
        _selectedCategory = null;
      }
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.slash && !_searchFocusNode.hasFocus) {
      _searchFocusNode.requestFocus();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
      if (_searchQuery.isNotEmpty) {
        setState(() { _searchQuery = ''; _searchController.clear(); _selectedCategory = null; });
      } else if (_selectedCategory != null) {
        setState(() => _selectedCategory = null);
      }
      _selectedIndex = -1;
      return;
    }
    if (_showPatternLanding || _searchFocusNode.hasFocus) return;
    final list = _getFiltered(context);
    if (list.isEmpty) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      setState(() => _selectedIndex = (_selectedIndex + 1).clamp(0, list.length - 1));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      setState(() => _selectedIndex = (_selectedIndex - 1).clamp(0, list.length - 1));
    } else if (event.logicalKey == LogicalKeyboardKey.enter && _selectedIndex >= 0) {
      context.push('/muscle/${list[_selectedIndex].id}');
    }
  }

  Color get _catColor {
    if (_selectedCategory == null) return AppTheme.primary;
    switch (_selectedCategory!.toLowerCase()) {
      case 'all': return AppTheme.primary;
      case 'favorites': return AppTheme.amber;
      case 'recent': return AppTheme.orchid;
      default:
        if (_isPatternCategory) return AppTheme.patternColor;
        return AppTheme.groupColor(_selectedCategory!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    context.watch<MuscleDataProvider>();
    if (_selectedCategory == 'Favorites') context.watch<FavoritesManager>();
    if (_selectedCategory == 'Recent') context.watch<RecentlyViewedManager>();
    final data = context.watch<MuscleDataProvider>();

    if (!data.isLoaded) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 32, height: 32,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary.withAlpha(150))),
            const SizedBox(height: 16),
            Text('LOADING NEUROINJECT', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, letterSpacing: 2.0, color: AppTheme.textTertiary)),
          ]),
        ),
      );
    }

    return Focus(
      focusNode: _pageFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        _handleKey(event);
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        body: CustomScrollView(
          slivers: [
            // Search + nav bar
            SliverToBoxAdapter(child: _buildTopBar(isDark)),
            // Content: pattern landing OR muscle grid
            if (_showPatternLanding)
              ..._buildPatternLanding(isDark)
            else
              ..._buildMuscleGrid(isDark),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar (search + quick filters) ──────────────────────

  Widget _buildTopBar(bool isDark) {
    final sidePad = MediaQuery.of(context).size.width < 900 ? 16.0 : 24.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(sidePad, 24, sidePad, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // App title
        Row(children: [
          Text('NEUROINJECT', style: GoogleFonts.ibmPlexMono(
            fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2.0,
            color: isDark ? AppTheme.primary : AppTheme.primaryDim)),
          const Spacer(),
          // Dose Calculator link
          _navChip(Icons.calculate_outlined, 'Dose Calc',
            AppTheme.amber, isDark, () => context.push('/calculator')),
        ]),
        const SizedBox(height: 16),
        // Search bar
        _buildSearchBar(isDark),
        const SizedBox(height: 12),
        // Quick filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _filterChip('Patterns', null, Icons.account_tree_rounded,
                AppTheme.patternColor, isDark),
            const SizedBox(width: 8),
            _filterChip('All Muscles', 'All', Icons.list_rounded,
                AppTheme.primary, isDark),
            const SizedBox(width: 8),
            _filterChip('Favorites', 'Favorites', Icons.star_rounded,
                AppTheme.amber, isDark),
            const SizedBox(width: 8),
            _filterChip('Recent', 'Recent', Icons.history_rounded,
                AppTheme.orchid, isDark),
            const SizedBox(width: 8),
            _filterChip('Upper', 'Upper Extremity', Icons.back_hand_outlined,
                AppTheme.groupColor('Upper Extremity'), isDark),
            const SizedBox(width: 8),
            _filterChip('Lower', 'Lower Extremity', Icons.directions_walk_rounded,
                AppTheme.groupColor('Lower Extremity'), isDark),
            const SizedBox(width: 8),
            _filterChip('Face', 'Face', Icons.face_outlined,
                AppTheme.groupColor('Face'), isDark),
            const SizedBox(width: 8),
            _filterChip('Neck', 'Cervical', Icons.accessibility_new_rounded,
                AppTheme.groupColor('Cervical'), isDark),
            const SizedBox(width: 8),
            _filterChip('Trunk', 'Trunk', Icons.straighten_rounded,
                AppTheme.groupColor('Trunk'), isDark),
          ]),
        ),
      ]),
    );
  }

  Widget _filterChip(String label, String? category, IconData icon, Color color, bool isDark) {
    final isActive = _selectedCategory == category;
    // "Patterns" chip is active when on landing page (null category)
    final isPatternChip = category == null;
    final active = isPatternChip ? _showPatternLanding : isActive;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedCategory = category;
        _selectedIndex = -1;
        if (category == null) {
          _searchQuery = '';
          _searchController.clear();
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color.withAlpha(120) : (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: active ? color : AppTheme.textTertiary),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.ibmPlexMono(
            fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5,
            color: active ? color : (isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight))),
        ]),
      ),
    );
  }

  Widget _navChip(IconData icon, String label, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.ibmPlexMono(
            fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: _searchFocusNode.hasFocus
              ? AppTheme.primary.withAlpha(100)
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: 1),
      ),
      child: Row(children: [
        Icon(Icons.search_rounded, color: AppTheme.primary.withAlpha(128), size: 18),
        const SizedBox(width: 10),
        Expanded(child: TextField(
          controller: _searchController, focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          style: GoogleFonts.sourceSans3(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search muscles, patterns, body regions...',
            border: InputBorder.none,
            hintStyle: GoogleFonts.sourceSans3(color: AppTheme.textTertiary, fontSize: 13),
            isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            borderRadius: BorderRadius.circular(4)),
          child: Text('/', style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppTheme.textTertiary)),
        ),
      ]),
    );
  }

  // ─── Pattern Landing Page ──────────────────────────────────

  List<Widget> _buildPatternLanding(bool isDark) {
    final sidePad = MediaQuery.of(context).size.width < 900 ? 16.0 : 24.0;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 4 : (width > 800 ? 3 : (width > 500 ? 2 : 1));

    // Group patterns by region
    final regionOrder = ['Face', 'Neck', 'Upper Extremity', 'Lower Extremity', 'Trunk'];
    final grouped = <String, List<SpasticityPattern>>{};
    for (final p in _patterns) {
      grouped.putIfAbsent(p.region, () => []).add(p);
    }

    final slivers = <Widget>[];

    // Landing header
    slivers.add(SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(sidePad, 8, sidePad, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('What pattern do you see?', style: GoogleFonts.sora(
            fontSize: 22, fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
          const SizedBox(height: 6),
          Text('Select a spasticity or dystonia pattern to see the recommended injection targets.',
            style: GoogleFonts.sourceSans3(
              fontSize: 14, height: 1.5,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight)),
        ]),
      ),
    ));

    // Build region sections
    for (final region in regionOrder) {
      final pats = grouped[region];
      if (pats == null || pats.isEmpty) continue;

      // Region header
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(sidePad, 16, sidePad, 10),
          child: Row(children: [
            Container(width: 3, height: 16, decoration: BoxDecoration(
              color: _regionColor(region), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(region.toUpperCase(), style: GoogleFonts.ibmPlexMono(
              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0,
              color: _regionColor(region))),
            const SizedBox(width: 10),
            Text('${pats.length} patterns', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, color: AppTheme.textTertiary)),
          ]),
        ),
      ));

      // Pattern cards grid
      slivers.add(SliverPadding(
        padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 8),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: width < 500 ? 3.0 : 2.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _patternCard(pats[i], isDark),
            childCount: pats.length,
          ),
        ),
      ));
    }

    // Bottom spacer
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 40)));

    return slivers;
  }

  Widget _patternCard(SpasticityPattern pattern, bool isDark) {
    final regionColor = _regionColor(pattern.region);
    return GestureDetector(
      onTap: () => setState(() { _selectedCategory = pattern.id; _selectedIndex = -1; }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: regionColor.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pattern name
            Text(pattern.shortName, style: GoogleFonts.sora(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            // Description
            Text(pattern.description, style: GoogleFonts.sourceSans3(
              fontSize: 11, height: 1.3,
              color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            // Muscle count badge
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: regionColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: regionColor.withAlpha(50))),
                child: Text('${pattern.muscles.length} muscles',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 9, fontWeight: FontWeight.w600, color: regionColor)),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 10,
                  color: AppTheme.textTertiary.withAlpha(100)),
            ]),
          ],
        ),
      ),
    );
  }

  Color _regionColor(String region) {
    switch (region) {
      case 'Face': return const Color(0xFFE17055);
      case 'Neck': return const Color(0xFF00B894);
      case 'Upper Extremity': return const Color(0xFFFF6B6B);
      case 'Lower Extremity': return const Color(0xFF0984E3);
      case 'Trunk': return const Color(0xFFFDAA5C);
      default: return AppTheme.primary;
    }
  }

  // ─── Muscle Grid (filtered view) ───────────────────────────

  List<Widget> _buildMuscleGrid(bool isDark) {
    final sidePad = MediaQuery.of(context).size.width < 900 ? 16.0 : 24.0;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1400 ? 4 : (width > 900 ? 3 : (width > 600 ? 2 : 1));
    final childAspectRatio = width < 600 ? 3.2 : (width < 900 ? 1.8 : 1.6);
    final filtered = _getFiltered(context);

    return [
      // Category header with back button
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(sidePad, 4, sidePad, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Back to patterns link
            GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = null;
                _searchQuery = '';
                _searchController.clear();
                _selectedIndex = -1;
              }),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_back_ios_rounded, size: 12, color: AppTheme.patternColor),
                const SizedBox(width: 4),
                Text('Back to patterns', style: GoogleFonts.ibmPlexMono(
                  fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.patternColor)),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(
                color: _catColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _selectedPattern?.name.toUpperCase() ?? (_selectedCategory ?? 'ALL').toUpperCase(),
                style: GoogleFonts.ibmPlexMono(
                  fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.5, color: _catColor))),
              const SizedBox(width: 10),
              Text('${filtered.length} muscles', style: GoogleFonts.ibmPlexMono(
                fontSize: 10, color: AppTheme.textTertiary, letterSpacing: 0.5)),
            ]),
            if (_selectedPattern != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: Text(_selectedPattern!.description,
                  style: GoogleFonts.sourceSans3(fontSize: 13, color: AppTheme.textSecondary)),
              ),
            ],
          ]),
        ),
      ),
      // Grid
      if (filtered.isNotEmpty)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => MuscleCard(
                muscle: filtered[i], isSelected: i == _selectedIndex),
              childCount: filtered.length,
            ),
          ),
        ),
      // Empty state
      if (filtered.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 40, color: AppTheme.textTertiary),
              const SizedBox(height: 12),
              Text('No muscles found', style: GoogleFonts.sourceSans3(
                fontSize: 14, color: AppTheme.textSecondary)),
            ],
          )),
        ),
    ];
  }
}
