import '../models/muscle.dart';

/// A documented dose range for one muscle and one brand, e.g. "50-100".
///
/// The corpus stores these as display strings. Planning needs arithmetic, so
/// they are parsed once, here, rather than in the widget that happens to need
/// a number — a plan that silently mis-parses a range is a plan that reports a
/// wrong total against a session ceiling.
class DoseRange {
  final double low;
  final double high;

  const DoseRange(this.low, this.high);

  bool get isSingle => low == high;

  /// The seeded planning dose: the BOTTOM of the documented range.
  ///
  /// Starting low is the conservative reading of a range, and the number stays
  /// editable in the session afterwards. Seeding the midpoint or the top would
  /// be the app making a dosing decision on the injector's behalf.
  double get seed => low;

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  String get label => isSingle ? _fmt(low) : '${_fmt(low)}–${_fmt(high)}';

  /// Parses "50", "50-100", "50 - 100". Returns null for anything else rather
  /// than guessing — an unparseable dose must drop out of the total visibly.
  static DoseRange? parse(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;
    final range = RegExp(r'^(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)$').firstMatch(s);
    if (range != null) {
      final a = double.parse(range.group(1)!);
      final b = double.parse(range.group(2)!);
      return a <= b ? DoseRange(a, b) : DoseRange(b, a);
    }
    final single = RegExp(r'^(\d+(?:\.\d+)?)$').firstMatch(s);
    if (single != null) {
      final v = double.parse(single.group(1)!);
      return DoseRange(v, v);
    }
    return null;
  }

  /// The range documented for [brand], or null when this muscle has none.
  static DoseRange? forBrand(Dosage? dosage, String brand) {
    if (dosage == null) return null;
    return switch (brand) {
      'Botox' => parse(dosage.botox),
      'Xeomin' => parse(dosage.xeomin),
      'Dysport' => parse(dosage.dysport),
      _ => null,
    };
  }
}
