import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

/// Embedded YouTube player — works on all platforms (macOS via WKWebView,
/// iOS/Android via native WebView, web via an iframe backed by the
/// webview_flutter_web federated implementation).
class VideoLinkCard extends StatefulWidget {
  final String videoUrl;
  final String muscleTitle;
  final Color accentColor;

  const VideoLinkCard({
    super.key,
    required this.videoUrl,
    required this.muscleTitle,
    required this.accentColor,
  });

  @override
  State<VideoLinkCard> createState() => _VideoLinkCardState();
}

class _VideoLinkCardState extends State<VideoLinkCard> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isExpanded = false;

  String? get _videoId {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) return null;
    // youtube.com/watch?v=ID
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    // youtu.be/ID
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
    // youtube.com/embed/ID
    if (uri.pathSegments.contains('embed') && uri.pathSegments.length > 1) {
      final idx = uri.pathSegments.indexOf('embed');
      if (idx + 1 < uri.pathSegments.length) {
        return uri.pathSegments[idx + 1];
      }
    }
    return null;
  }

  bool get _isYouTube => _videoId != null;

  @override
  void initState() {
    super.initState();
    if (_isYouTube) {
      _initWebView();
    }
  }

  void _initWebView() {
    final vid = _videoId!;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (_) {
          if (mounted) setState(() { _isLoading = false; _hasError = true; });
        },
      ))
      ..loadRequest(Uri.parse(
        'https://www.youtube.com/embed/$vid?rel=0&modestbranding=1&playsinline=1&color=white',
      ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.accentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: Icon(Icons.play_circle_outline_rounded,
                color: widget.accentColor, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('PROCEDURE VIDEO',
            style: GoogleFonts.ibmPlexMono(
              color: widget.accentColor, fontWeight: FontWeight.w700,
              fontSize: 9, letterSpacing: 1.5))),
          // External link button
          InkWell(
            onTap: () async {
              final uri = Uri.parse(widget.videoUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.open_in_new_rounded, size: 12,
                  color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight),
                const SizedBox(width: 4),
                Text('Open in browser', style: GoogleFonts.ibmPlexMono(
                  fontSize: 9, color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Embedded player — works on macOS, iOS, Android, and web (via iframe).
        if (_isYouTube && _controller != null)
          _buildEmbeddedPlayer(isDark)
        else
          _buildExternalLink(isDark),
      ],
    );
  }

  Widget _buildEmbeddedPlayer(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: _isExpanded ? 450 : 280,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: widget.accentColor.withAlpha(40)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller!),
            // Loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: widget.accentColor)),
                      const SizedBox(height: 12),
                      Text('Loading video...', style: GoogleFonts.ibmPlexMono(
                        fontSize: 10, color: AppTheme.textTertiary)),
                    ],
                  )),
                ),
              ),
            // Error overlay
            if (_hasError)
              Positioned.fill(
                child: Container(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 32,
                        color: AppTheme.textTertiary),
                      const SizedBox(height: 8),
                      Text('Video failed to load', style: GoogleFonts.sourceSans3(
                        fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(widget.videoUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: const Text('Open in browser'),
                      ),
                    ],
                  )),
                ),
              ),
            // Expand/collapse hint
            Positioned(
              bottom: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.circular(4)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_isExpanded ? Icons.compress_rounded : Icons.expand_rounded,
                    size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(_isExpanded ? 'Click to shrink' : 'Click to expand',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9, color: Colors.white70)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExternalLink(bool isDark) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(widget.videoUrl);
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
          border: Border.all(color: widget.accentColor.withAlpha(40))),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: widget.accentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: Icon(Icons.videocam_outlined, color: widget.accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.muscleTitle} — Injection Technique',
                style: GoogleFonts.sourceSans3(fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight)),
              const SizedBox(height: 2),
              Text('Open video in browser', style: GoogleFonts.sourceSans3(
                fontSize: 12, color: widget.accentColor)),
            ],
          )),
          Icon(Icons.open_in_new_rounded, size: 18,
            color: isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight),
        ]),
      ),
    );
  }
}
