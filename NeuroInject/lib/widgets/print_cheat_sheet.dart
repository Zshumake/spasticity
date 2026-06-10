import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/toxin_data.dart';
import '../models/muscle.dart';
import '../models/session_item.dart';

/// Generates and prints a one-page procedure cheat sheet for a muscle injection.
Future<void> printCheatSheet(BuildContext context, Muscle muscle) async {
  final doc = pw.Document();
  final us = muscle.ultrasound;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(36),
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title bar
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1E1B18'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(muscle.name,
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.SizedBox(height: 2),
                  pw.Text('${muscle.group} — ${muscle.pattern}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey300)),
                  if (muscle.dosage != null)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text('Dosage: ${muscle.dosage!.displayFull}',
                          style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.amber)),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Two-column layout
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left column
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('BONY LANDMARKS'),
                      ...muscle.landmarks.map((l) => _bullet(l)),
                      pw.SizedBox(height: 10),
                      _sectionHeader('NEEDLE PLACEMENT'),
                      ...muscle.placement.asMap().entries.map(
                          (e) => _numberedStep(e.key + 1, e.value)),
                      if (muscle.setup.isNotEmpty) ...[
                        pw.SizedBox(height: 10),
                        _sectionHeader('SETUP & TIPS'),
                        ...muscle.setup.map((s) => _bullet(s)),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                // Right column
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (us != null) ...[
                        _sectionHeader('ULTRASOUND GUIDE'),
                        _labelValue('Probe', us.probe),
                        _labelValue('Orientation', us.orientation),
                        if (us.depth != null)
                          _labelValue('Depth', us.depth!),
                        pw.SizedBox(height: 8),
                        _sectionHeader('WHAT YOU SEE'),
                        ...us.viewSteps.map((s) => _bullet(s)),
                        if (us.safetyNotes.isNotEmpty) ...[
                          pw.SizedBox(height: 8),
                          _sectionHeader('SAFETY'),
                          ...us.safetyNotes.map((s) => _warningBullet(s)),
                        ],
                      ],
                      if (muscle.supplies.isNotEmpty) ...[
                        pw.SizedBox(height: 10),
                        _sectionHeader('SUPPLIES'),
                        ...muscle.supplies.map((s) => _checkbox(s)),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            pw.Spacer(),
            // Footer
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(top: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
              ),
              child: pw.Text(
                'NeuroInject — Spasticity Injection Guide',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey500),
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => doc.save(),
    name: '${muscle.name} — Cheat Sheet',
  );
}

pw.Widget _sectionHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(children: [
      pw.Container(width: 10, height: 1.5, color: PdfColor.fromHex('#E17055')),
      pw.SizedBox(width: 6),
      pw.Text(text,
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#E17055'),
              letterSpacing: 1.5)),
    ]),
  );
}

pw.Widget _bullet(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Container(
              width: 3, height: 3,
              decoration: const pw.BoxDecoration(
                  color: PdfColors.grey600, shape: pw.BoxShape.circle)),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(text,
              style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.3)),
        ),
      ],
    ),
  );
}

pw.Widget _numberedStep(int n, String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 16,
          height: 16,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FCEAE5'),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text('$n',
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#C05A44'))),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 1),
            child: pw.Text(text,
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.3)),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _labelValue(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 70,
          child: pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600)),
        ),
        pw.Expanded(
          child: pw.Text(value,
              style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
    ),
  );
}

pw.Widget _warningBullet(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('⚠ ',
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#F9CA24'))),
        pw.Expanded(
          child: pw.Text(text,
              style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.3)),
        ),
      ],
    ),
  );
}

pw.Widget _checkbox(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3),
    child: pw.Row(children: [
      pw.Container(
        width: 10,
        height: 10,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(2),
          border: pw.Border.all(color: PdfColors.grey500, width: 1),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
      ),
    ]),
  );
}

/// Prints a one-or-more-page summary of a whole injection session: every
/// planned muscle with side / brand / per-side dose / total, plus per-brand
/// totals checked against the labeled session maximum.
Future<void> printSessionPlan(
    BuildContext context, List<SessionItem> items) async {
  if (items.isEmpty) return;

  final totals = <String, double>{};
  for (final it in items) {
    totals[it.brand] = (totals[it.brand] ?? 0) + it.totalUnits;
  }

  final now = DateTime.now();
  final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';

  String fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(36),
      footer: (ctx) => pw.Container(
        alignment: pw.Alignment.centerLeft,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'NeuroInject — Spasticity Injection Guide   ·   '
          'Page ${ctx.pageNumber}/${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ),
      build: (pw.Context ctx) => [
        // Title bar
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#1E1B18'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Injection Session Plan',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white)),
                pw.SizedBox(height: 2),
                pw.Text('${items.length} muscle${items.length == 1 ? '' : 's'}',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey300)),
              ]),
              pw.Text(dateStr,
                  style:
                      const pw.TextStyle(fontSize: 10, color: PdfColors.grey300)),
            ],
          ),
        ),
        pw.SizedBox(height: 14),

        // Per-brand totals vs ceiling
        _sectionHeader('SESSION TOTALS (vs labeled max)'),
        ...totals.entries.map((e) {
          final ceiling = brandByName(e.key)?.maxSessionUnits ?? 0;
          final over = ceiling > 0 && e.value > ceiling;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(top: 3),
            child: pw.Row(children: [
              pw.SizedBox(
                  width: 90,
                  child: pw.Text(e.key,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold))),
              pw.Text('${fmt(e.value)} / $ceiling U',
                  style: pw.TextStyle(
                      fontSize: 10,
                      color: over ? PdfColors.red : PdfColors.black,
                      fontWeight:
                          over ? pw.FontWeight.bold : pw.FontWeight.normal)),
              if (over)
                pw.Text('   ⚠ over labeled max',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.red)),
            ]),
          );
        }),
        pw.SizedBox(height: 14),

        // Muscle table
        _sectionHeader('MUSCLES'),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1.6),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1.7),
            4: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FCEAE5')),
              children: [
                _th('Muscle'),
                _th('Side'),
                _th('Brand'),
                _th('Dose/side'),
                _th('Total'),
              ],
            ),
            ...items.map((it) => pw.TableRow(children: [
                  _td(it.muscleName),
                  _td(it.side.label),
                  _td(it.brand),
                  _td('${fmt(it.dose)} U'),
                  _td('${fmt(it.totalUnits)} U'),
                ])),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Advisory only. Brands are not interchangeable 1:1 — verify doses '
          'and per-session maxima against current product labeling before '
          'injecting.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => doc.save(),
    name: 'Injection Session Plan — $dateStr',
  );
}

pw.Widget _th(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#C05A44'))),
    );

pw.Widget _td(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
