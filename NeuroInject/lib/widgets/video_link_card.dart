import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// A card that displays a video link and opens it in the system browser.
/// Works on macOS (no iframe needed).
class VideoLinkCard extends StatelessWidget {
  final String videoUrl;
  final String muscleTitle;
  final Color accentColor;

  const VideoLinkCard({
    super.key,
    required this.videoUrl,
    required this.muscleTitle,
    required this.accentColor,
  });

  bool get _isYouTube {
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return false;
    return uri.host.contains('youtube.com') || uri.host == 'youtu.be';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              child: Icon(Icons.play_circle_outline_rounded,
                  color: accentColor, size: 14),
            ),
            const SizedBox(width: 10),
            Text(
              'PROCEDURE VIDEO',
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
        InkWell(
          onTap: () async {
            final uri = Uri.parse(videoUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: accentColor.withAlpha(40),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isYouTube
                        ? Colors.red.withAlpha(25)
                        : accentColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    _isYouTube
                        ? Icons.smart_display_rounded
                        : Icons.videocam_outlined,
                    color: _isYouTube ? Colors.red : accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$muscleTitle — Injection Technique',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textPrimary
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isYouTube
                            ? 'Watch on YouTube'
                            : 'Open video in browser',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 12,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: isDark
                      ? AppTheme.textTertiary
                      : AppTheme.textSecondaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
