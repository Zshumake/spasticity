import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/spasticity_pattern.dart';
import '../theme/app_theme.dart';
import '../theme/theme_manager.dart';

class DashboardSidebar extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final List<SpasticityPattern> patterns;
  final Function(String) onCategorySelected;
  final bool isMobile;

  const DashboardSidebar({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    this.patterns = const [],
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: isMobile ? double.infinity : 260,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(right: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1)),
      ),
      child: Column(children: [
        _buildHeader(isDark),
        const SizedBox(height: 8),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionLabel('CATEGORIES', isDark),
            ...categories.map((c) => _buildItem(context, c, isDark)),
            if (patterns.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionLabel('SPASTICITY PATTERNS', isDark),
              ...patterns.map((p) => _buildPatternItem(context, p, isDark)),
            ],
            const SizedBox(height: 16),
            _sectionLabel('TOOLS', isDark),
            _buildToolItem(context, 'Dose Calculator', Icons.calculate_outlined, isDark),
          ]),
        )),
        _buildFooter(context, isDark),
      ]),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(text, style: GoogleFonts.ibmPlexMono(
        fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2.5,
        color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(
        color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1))),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.primary.withAlpha(76), width: 1)),
          alignment: Alignment.center,
          child: const Icon(Icons.monitor_heart_outlined, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEUROINJECT', style: GoogleFonts.ibmPlexMono(
            fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.5,
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
          Text('SPASTICITY GUIDE', style: GoogleFonts.ibmPlexMono(
            fontSize: 8, fontWeight: FontWeight.w500, letterSpacing: 2.0,
            color: AppTheme.primary.withAlpha(150))),
        ]),
      ]),
    );
  }

  Widget _buildItem(BuildContext context, String title, bool isDark) {
    final isSelected = selectedCategory == title;
    final catColor = _catColor(title);
    return InkWell(
      onTap: () {
        onCategorySelected(title);
        if (isMobile) Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? catColor.withAlpha(isDark ? 20 : 15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: isSelected
              ? Border.all(color: catColor.withAlpha(50), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 3, height: 16,
            decoration: BoxDecoration(
              color: isSelected ? catColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Icon(_iconFor(title), size: 16,
            color: isSelected ? catColor : (isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.sourceSans3(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? catColor : (isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight)),
            overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _buildToolItem(BuildContext context, String title, IconData icon, bool isDark) {
    return InkWell(
      onTap: () {
        context.push('/calculator');
        if (isMobile) Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(children: [
          const SizedBox(width: 15),
          Icon(icon, size: 16, color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.sourceSans3(
            fontSize: 13, color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight))),
        ]),
      ),
    );
  }

  Widget _buildPatternItem(BuildContext context, SpasticityPattern pattern, bool isDark) {
    final isSelected = selectedCategory == pattern.id;
    final color = AppTheme.patternColor;
    return InkWell(
      onTap: () {
        onCategorySelected(pattern.id);
        if (isMobile) Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(isDark ? 20 : 15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: isSelected
              ? Border.all(color: color.withAlpha(50), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 3, height: 16,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Icon(Icons.gesture_rounded, size: 14,
            color: isSelected ? color : (isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pattern.shortName, style: GoogleFonts.sourceSans3(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : (isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight)),
                overflow: TextOverflow.ellipsis),
              Text('${pattern.muscles.length} muscles', style: GoogleFonts.ibmPlexMono(
                fontSize: 9, color: AppTheme.textTertiary)),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    final tm = context.read<ThemeManager>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(top: BorderSide(
        color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1))),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFFD980FA)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text('N', style: GoogleFonts.ibmPlexMono(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            Text('NeuroInject', style: GoogleFonts.sourceSans3(
              fontWeight: FontWeight.w600, fontSize: 12,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
            Text('v1.0', style: GoogleFonts.ibmPlexMono(
              color: AppTheme.textTertiary, fontSize: 10)),
          ],
        )),
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          onTap: () => tm.toggleTheme(!isDark),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 16, color: AppTheme.textSecondary),
          ),
        ),
      ]),
    );
  }

  Color _catColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'all': return AppTheme.primary;
      case 'favorites': return AppTheme.amber;
      case 'recent': return AppTheme.orchid;
      default: return AppTheme.groupColor(cat);
    }
  }

  IconData _iconFor(String cat) {
    switch (cat.toLowerCase()) {
      case 'all': return Icons.grid_view_rounded;
      case 'favorites': return Icons.star_rounded;
      case 'recent': return Icons.history_rounded;
      case 'upper extremity': return Icons.front_hand_rounded;
      case 'lower extremity': return Icons.directions_walk_rounded;
      case 'trunk': return Icons.accessibility_new_rounded;
      case 'neck': return Icons.person_rounded;
      default: return Icons.category_rounded;
    }
  }
}
