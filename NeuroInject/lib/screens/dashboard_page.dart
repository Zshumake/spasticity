import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/muscle_provider.dart';
import '../models/muscle.dart';
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

  final _pageFocusNode = FocusNode();
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  void dispose() {
    _pageFocusNode.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Muscle> _getFiltered(BuildContext context) {
    final data = context.watch<MuscleDataProvider>();
    final favs = context.watch<FavoritesManager>();
    final recent = context.watch<RecentlyViewedManager>();
    if (!data.isLoaded) return [];

    if (_selectedCategory == 'Recent') {
      return recent.recentIds
          .map((id) => data.findById(id))
          .where((m) => m != null)
          .cast<Muscle>()
          .where((m) => _matchesSearch(m))
          .toList();
    }

    return data.muscles.where((m) {
      final matchSearch = _matchesSearch(m);
      final bool matchCat;
      if (_selectedCategory == 'All') {
        matchCat = true;
      } else if (_selectedCategory == 'Favorites') {
        matchCat = favs.isFavorite(m.id);
      } else {
        matchCat = m.group == _selectedCategory;
      }
      return matchSearch && matchCat;
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
    final list = _getFilteredSync();
    if (list.isEmpty) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      setState(() => _selectedIndex = (_selectedIndex + 1).clamp(0, list.length - 1));
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      setState(() => _selectedIndex = (_selectedIndex - 1).clamp(0, list.length - 1));
    } else if (event.logicalKey == LogicalKeyboardKey.enter && _selectedIndex >= 0) {
      context.go('/muscle/${list[_selectedIndex].id}');
    }
  }

  List<Muscle> _getFilteredSync() {
    final data = context.read<MuscleDataProvider>();
    final favs = context.read<FavoritesManager>();
    final recent = context.read<RecentlyViewedManager>();
    if (!data.isLoaded) return [];
    if (_selectedCategory == 'Recent') {
      return recent.recentIds.map((id) => data.findById(id)).where((m) => m != null).cast<Muscle>().where(_matchesSearch).toList();
    }
    return data.muscles.where((m) {
      if (!_matchesSearch(m)) return false;
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Favorites') return favs.isFavorite(m.id);
      return m.group == _selectedCategory;
    }).toList();
  }

  Color get _catColor {
    switch (_selectedCategory.toLowerCase()) {
      case 'all': return AppTheme.primary;
      case 'favorites': return AppTheme.amber;
      case 'recent': return const Color(0xFFD980FA);
      default: return AppTheme.groupColor(_selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return KeyboardListener(
      focusNode: _pageFocusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
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
            onCategorySelected: (c) => setState(() { _selectedCategory = c; _selectedIndex = -1; }),
            isMobile: true),
        ) : null,
        body: Row(children: [
          if (!isMobile) DashboardSidebar(
            selectedCategory: _selectedCategory, categories: _categories,
            onCategorySelected: (c) => setState(() { _selectedCategory = c; _selectedIndex = -1; })),
          Expanded(child: _buildMain(filtered, isMobile, isDark)),
        ]),
      ),
    );
  }

  Widget _buildMain(List<Muscle> muscles, bool isMobile, bool isDark) {
    return Column(children: [
      _buildSearchBar(isMobile, isDark),
      Expanded(child: ListView(
        padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, 24),
        children: [
          // Category header
          Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(
              color: _catColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Text(_selectedCategory.toUpperCase(), style: GoogleFonts.ibmPlexMono(
              fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.5, color: _catColor)),
            const SizedBox(width: 10),
            Text('${muscles.length} muscles', style: GoogleFonts.ibmPlexMono(
              fontSize: 10, color: AppTheme.textTertiary, letterSpacing: 0.5)),
          ])),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 4
                  : (MediaQuery.of(context).size.width > 900 ? 3
                  : (MediaQuery.of(context).size.width > 600 ? 2 : 1)),
              childAspectRatio: MediaQuery.of(context).size.width < 600 ? 3.2
                  : (MediaQuery.of(context).size.width < 900 ? 1.8 : 1.6),
              crossAxisSpacing: 10, mainAxisSpacing: 10,
            ),
            itemCount: muscles.length,
            itemBuilder: (ctx, i) => MuscleCard(
              muscle: muscles[i], isSelected: i == _selectedIndex),
          ),
          if (muscles.isEmpty) Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(child: Column(children: [
              Icon(Icons.search_off_rounded, size: 40, color: AppTheme.textTertiary),
              const SizedBox(height: 12),
              Text('No muscles found', style: GoogleFonts.sourceSans3(fontSize: 14, color: AppTheme.textSecondary)),
            ]))),
        ],
      )),
    ]);
  }

  Widget _buildSearchBar(bool isMobile, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 12 : 32, isMobile ? 16 : 24, 16),
      child: Container(
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
