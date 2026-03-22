import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Split-view anatomy diagram: probe position (left) + expected US view (right).
/// Shows placeholder slots until user adds their own clinical images.
class AnatomyDiagram extends StatelessWidget {
  final String? probePositionImg;
  final String? expectedUsImg;
  final Color accentColor;
  final String muscleTitle;
  final VoidCallback? onTapProbe;
  final VoidCallback? onTapUs;

  const AnatomyDiagram({
    super.key,
    this.probePositionImg,
    this.expectedUsImg,
    required this.accentColor,
    required this.muscleTitle,
    this.onTapProbe,
    this.onTapUs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(Icons.schema_outlined, color: accentColor, size: 14),
            ),
            const SizedBox(width: 10),
            Text(
              'ANATOMY DIAGRAM',
              style: GoogleFonts.ibmPlexMono(
                color: accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isMobile)
          Column(
            children: [
              _buildPanel(context, isDark: isDark, label: 'PROBE POSITION',
                  icon: Icons.sensors_outlined, imagePath: probePositionImg,
                  placeholderText: 'Probe placement photo\nwill be added',
                  onTap: onTapProbe),
              const SizedBox(height: 12),
              _buildPanel(context, isDark: isDark, label: 'EXPECTED US VIEW',
                  icon: Icons.monitor_heart_outlined, imagePath: expectedUsImg,
                  placeholderText: 'Expected sonographic\nview will be added',
                  onTap: onTapUs),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPanel(context, isDark: isDark, label: 'PROBE POSITION',
                    icon: Icons.sensors_outlined, imagePath: probePositionImg,
                    placeholderText: 'Probe placement photo\nwill be added',
                    onTap: onTapProbe),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 90),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: accentColor.withAlpha(80), size: 20),
                ),
              ),
              Expanded(
                child: _buildPanel(context, isDark: isDark, label: 'EXPECTED US VIEW',
                    icon: Icons.monitor_heart_outlined, imagePath: expectedUsImg,
                    placeholderText: 'Expected sonographic\nview will be added',
                    onTap: onTapUs),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPanel(BuildContext context, {
    required bool isDark,
    required String label,
    required IconData icon,
    String? imagePath,
    required String placeholderText,
    VoidCallback? onTap,
  }) {
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return GestureDetector(
      onTap: hasImage ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(isDark ? 15 : 10),
                border: Border(
                  bottom: BorderSide(color: accentColor.withAlpha(25)),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 12, color: accentColor),
                  const SizedBox(width: 6),
                  Text(label, style: GoogleFonts.ibmPlexMono(
                    fontSize: 8, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5, color: accentColor)),
                ],
              ),
            ),
            // Image or placeholder
            SizedBox(
              width: double.infinity,
              height: 180,
              child: hasImage
                  ? Image.asset(imagePath, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholderContent(isDark, placeholderText))
                  : _placeholderContent(isDark, placeholderText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderContent(bool isDark, String text) {
    return Container(
      color: isDark ? AppTheme.bgDark.withAlpha(128) : AppTheme.bgLight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: accentColor.withAlpha(50), size: 28),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(fontSize: 11, height: 1.4,
                color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}
