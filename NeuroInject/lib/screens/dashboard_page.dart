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
import '../widgets/dashboard_sidebar.dart';

class DashboardPage extends StatefulWidget {
  final String? initialCategory;
  const DashboardPage({super.key, this.initialCategory});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchQuery = '';
  late String _selectedCategory;
  final _categories = [
    'All', 'Favorites', 'Recent',
    'Upper Extremity', 'Lower Extremity', 'Trunk', 'Neck',
  ];
  List<SpasticityPattern> _patterns = [];

  final _pageFocusNode = FocusNode();
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _loadPatterns();
    _searchFocusNode.addListener(() { if (mounted) setState(() {}); });
  }

  Future<void> _loadPatterns() async {
    final patterns = await MuscleData.loadPatterns();
    if (mounted) setState(() => _patterns = patterns);
  }

  /// Check if the selected category is a pattern ID
  bool get _isPatternCategory =>
      _patterns.any((p) => p.id == _selectedCategory);

  SpasticityPattern? get _selectedPattern =>
      _patterns.where((p) => p.id == _selectedCategory).firstOrNull;

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
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Favorites') return favs.isFavorite(m.id);
      if (_isPatternCategory) return m.spasticityPatterns.contains(_selectedCategory);
      return m.group == _selectedCategory;
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

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.slash && !_searchFocusNode.hasFocus) {
      _searchFocusNode.requestFocus();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
      if (_searchQuery.isNotEmpty) {
        setState(() { _searchQuery = ''; _searchController.clear(); });
      }
      _selectedIndex = -1;
      return;
    }
    if (_searchFocusNode.hasFocus) return;
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
    switch (_selectedCategory.toLowerCase()) {
      case 'all': return AppTheme.primary;
      case 'favorites': return AppTheme.amber;
      case 'recent': return AppTheme.orchid;
      default:
        if (_isPatternCategory) return AppTheme.patternColor;
        return AppTheme.groupColor(_selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Watch data provider for initial load; watch favs/recent only when
    // viewing those categories to avoid unnecessary full-page rebuilds
    context.watch<MuscleDataProvider>();
    if (_selectedCategory == 'Favorites') context.watch<FavoritesManager>();
    if (_selectedCategory == 'Recent') context.watch<RecentlyViewedManager>();
    final filtered = _getFiltered(context);
    final data = context.watch<MuscleDataProvider>();

    if (!data.isLoaded) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 32, height: 32,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary.withAlpha(150))),
            const SizedBox(height: 16),
            Text('LOADING MUSCLES', style: GoogleFonts.ibmPlexMono(
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
        appBar: isMobile ? AppBar(
          backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          elevation: 0, scrolledUnderElevation: 0,
          title: Text('NEUROINJECT', style: GoogleFonts.ibmPlexMono(
            fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5,
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
          leading: Builder(builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: isDark ? AppTheme.primary : AppTheme.primaryDim, size: 20),
            onPressed: () => Scaffold.of(ctx).openDrawer())),
        ) : null,
        drawer: isMobile ? Drawer(
          width: 280,
          backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          child: DashboardSidebar(
            selectedCategory: _selectedCategory, categories: _categories,
            patterns: _patterns,
            onCategorySelected: (c) => setState(() { _selectedCategory = c; _selectedIndex = -1; }),
            isMobile: true),
        ) : null,
        body: Row(children: [
          if (!isMobile) DashboardSidebar(
            selectedCategory: _selectedCategory, categories: _categories,
            patterns: _patterns,
            onCategorySelected: (c) => setState(() { _selectedCategory = c; _selectedIndex = -1; })),
          Expanded(child: _buildMain(filtered, isMobile, isDark)),
        ]),
      ),
    );
  }

  Widget _buildMain(List<Muscle> muscles, bool isMobile, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1400 ? 4 : (width > 900 ? 3 : (width > 600 ? 2 : 1));
    final childAspectRatio = width < 600 ? 3.2 : (width < 900 ? 1.8 : 1.6);
    final sidePad = isMobile ? 16.0 : 24.0;

    return CustomScrollView(
      slivers: [
        // Search bar
        SliverToBoxAdapter(child: _buildSearchBar(isMobile, isDark)),
        // Category header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(width: 4, height: 20, decoration: BoxDecoration(
                    color: _catColor, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    _selectedPattern?.name.toUpperCase() ?? _selectedCategory.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.5, color: _catColor))),
                  const SizedBox(width: 10),
                  Text('${muscles.length} muscles', style: GoogleFonts.ibmPlexMono(
                    fontSize: 10, color: AppTheme.textTertiary, letterSpacing: 0.5)),
                ]),
                if (_selectedPattern != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 6),
                    child: Text(_selectedPattern!.description,
                      style: GoogleFonts.sourceSans3(fontSize: 13, color: AppTheme.textSecondary)),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Grid — lazy, only builds visible cards
        if (muscles.isNotEmpty)
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
                  muscle: muscles[i], isSelected: i == _selectedIndex),
                childCount: muscles.length,
              ),
            ),
          ),
        // Empty state
        if (muscles.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 40, color: AppTheme.textTertiary),
                const SizedBox(height: 12),
                Text('No muscles found', style: GoogleFonts.sourceSans3(fontSize: 14, color: AppTheme.textSecondary)),
              ],
            )),
          ),
      ],
    );
  }

  Widget _buildSearchBar(bool isMobile, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 12 : 32, isMobile ? 16 : 24, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: _searchFocusNode.hasFocus ? AppTheme.primary.withAlpha(100) : (isDark ? AppTheme.borderDark : AppTheme.borderLight), width: 1),
        ),
        child: Row(children: [
          Icon(Icons.search_rounded, color: AppTheme.primary.withAlpha(128), size: 18),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller: _searchController, focusNode: _searchFocusNode,
            onChanged: (v) => setState(() { _searchQuery = v; _selectedIndex = -1; }),
            style: GoogleFonts.sourceSans3(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search muscles, patterns...',
              border: InputBorder.none,
              hintStyle: GoogleFonts.sourceSans3(color: AppTheme.textTertiary, fontSize: 13),
              isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, borderRadius: BorderRadius.circular(4)),
            child: Text('/', style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppTheme.textTertiary)),
          ),
        ]),
      ),
    );
  }
}
