import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/muscle.dart';
import '../theme/app_theme.dart';
import '../theme/favorites_manager.dart';

class MuscleCard extends StatefulWidget {
  final Muscle muscle;
  final bool isSelected;

  const MuscleCard({super.key, required this.muscle, this.isSelected = false});

  @override
  State<MuscleCard> createState() => _MuscleCardState();
}

class _MuscleCardState extends State<MuscleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = context.select<FavoritesManager, bool>(
      (favs) => favs.isFavorite(widget.muscle.id),
    );
    final catColor = AppTheme.groupColor(widget.muscle.group);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push('/muscle/${widget.muscle.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: widget.isSelected
                  ? catColor
                  : _isHovered
                      ? catColor.withAlpha(100)
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: _isHovered || widget.isSelected
                ? [BoxShadow(color: catColor.withAlpha(20), blurRadius: 20, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [catColor, catColor.withAlpha(0)]),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMd),
                    topRight: Radius.circular(AppTheme.radiusMd)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group label + favorite
                      Row(children: [
                        Text(widget.muscle.group.toUpperCase(),
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            letterSpacing: 1.5, color: catColor)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.read<FavoritesManager>().toggleFavorite(widget.muscle.id),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                              key: ValueKey(isFav),
                              color: isFav ? AppTheme.amber : AppTheme.textTertiary,
                              size: 18),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      // Muscle name
                      Text(widget.muscle.name,
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w600, fontSize: 13, height: 1.3,
                          color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      // Pattern
                      Text(widget.muscle.pattern,
                        style: GoogleFonts.sourceSans3(fontSize: 11,
                          color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      // Tags: dosage + probe type
                      Wrap(spacing: 4, runSpacing: 4, children: [
                        if (widget.muscle.dosage != null)
                          _tag(widget.muscle.dosage!.displayShort, catColor, isDark),
                        if (widget.muscle.ultrasound != null)
                          _tag(widget.muscle.ultrasound!.probe, catColor, isDark),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color c, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withAlpha(isDark ? 20 : 15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.withAlpha(38), width: 0.5),
      ),
      child: Text(text.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          fontSize: 8, fontWeight: FontWeight.w600,
          color: c.withAlpha(200), letterSpacing: 0.5)),
    );
  }
}
