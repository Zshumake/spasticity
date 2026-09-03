import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/us_annotation.dart';
import '../../theme/app_theme.dart';
import 'baked_highlight.dart';
import 'structure_legend.dart';

/// The scan, enlarged, with everything that makes it mean something still on
/// it: the highlight, the presentation crop and the lettered structures, with
/// the index underneath.
///
/// The reference panel on the muscle page is deliberately small — it sits in a
/// column of other material. Four letters on a 180pt panel are legible but the
/// echotexture around them is not, and reading the speckle is the whole point.
/// So enlarging has to carry the annotations rather than dropping back to the
/// bare file: a zoom that loses the highlight and the letters is not a zoom of
/// what the reader was looking at.
class AnnotatedScanViewer extends StatelessWidget {
  final String scanAsset;
  final String maskAsset;
  final Color accent;
  final Rect? crop;
  final List<StructureLabel> labels;
  final String title;

  const AnnotatedScanViewer({
    super.key,
    required this.scanAsset,
    required this.maskAsset,
    required this.accent,
    required this.title,
    this.crop,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppTheme.textStrong,
        title: Text(title,
            style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 6.0,
              // Contain, not cover: enlarging is the one place the WHOLE
              // cropped frame should be visible at once before the reader
              // chooses what to magnify.
              child: BakedHighlight(
                scanAsset: scanAsset,
                maskAsset: maskAsset,
                accent: accent,
                crop: crop,
                labels: labels,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (labels.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: AppTheme.borderDark)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: StructureLetterLegend(labels: labels, onDark: true),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Open the enlarged view. Kept beside the widget so call sites do not each
/// re-decide the route type.
void showAnnotatedScan(
  BuildContext context, {
  required String scanAsset,
  required String maskAsset,
  required Color accent,
  required String title,
  Rect? crop,
  List<StructureLabel> labels = const [],
}) {
  Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => AnnotatedScanViewer(
      scanAsset: scanAsset,
      maskAsset: maskAsset,
      accent: accent,
      title: title,
      crop: crop,
      labels: labels,
    ),
  ));
}
