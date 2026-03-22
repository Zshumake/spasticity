import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Upgraded US image gallery with main viewer, thumbnail strip, and label overlays.
class USImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final List<String> imageLabels;
  final Color accentColor;
  final String muscleTitle;

  const USImageGallery({
    super.key,
    required this.imagePaths,
    required this.imageLabels,
    required this.accentColor,
    required this.muscleTitle,
  });

  @override
  State<USImageGallery> createState() => _USImageGalleryState();
}

class _USImageGalleryState extends State<USImageGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: widget.accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(Icons.collections_rounded,
                  color: widget.accentColor, size: 14),
            ),
            const SizedBox(width: 10),
            Text(
              'US IMAGE GALLERY',
              style: GoogleFonts.ibmPlexMono(
                color: widget.accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Text(
              '${_selectedIndex + 1} / ${widget.imagePaths.length}',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 10,
                color: isDark
                    ? AppTheme.textTertiary
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main image with label overlay
        GestureDetector(
          onTap: () => _showFullImage(context),
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: widget.accentColor.withAlpha(50)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.imagePaths[_selectedIndex],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: AppTheme.textTertiary, size: 48),
                  ),
                ),
                // Label overlay
                if (_currentLabel.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withAlpha(204),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        _currentLabel,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Tap to enlarge hint
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.zoom_in, size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text('Tap to enlarge',
                            style: GoogleFonts.sourceSans3(
                                fontSize: 9, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Thumbnail strip (only if multiple images)
        if (widget.imagePaths.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imagePaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final isActive = index == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive
                            ? widget.accentColor
                            : (isDark
                                ? AppTheme.borderDark
                                : AppTheme.borderLight),
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      widget.imagePaths[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark
                            ? AppTheme.surfaceDark
                            : AppTheme.bgLight,
                        child: Icon(Icons.image_outlined,
                            size: 16, color: AppTheme.textTertiary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  String get _currentLabel {
    if (_selectedIndex < widget.imageLabels.length) {
      return widget.imageLabels[_selectedIndex];
    }
    return '';
  }

  void _showFullImage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            '${widget.muscleTitle} — ${_currentLabel.isNotEmpty ? _currentLabel : "US View"}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        body: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: Image.asset(
              widget.imagePaths[_selectedIndex],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child:
                    Text('Image not found', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
