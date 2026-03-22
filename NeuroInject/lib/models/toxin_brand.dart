import 'dart:ui';

class ToxinBrand {
  final String name;
  final String genericName;
  final String toxinType;
  final List<int> vialSizes;
  final int defaultVial;
  final List<DilutionPreset> commonDilutions;
  final String storageNote;
  final String maxDoseNote;
  final String? conversionNote;
  final Color color;

  /// Maps vial size (units) to pre-diluted volume (mL).
  /// Only applicable to Myobloc, which ships as a ready-to-use solution.
  final Map<int, double> preDilutedVolumes;

  const ToxinBrand({
    required this.name,
    required this.genericName,
    required this.toxinType,
    required this.vialSizes,
    required this.defaultVial,
    required this.commonDilutions,
    required this.storageNote,
    required this.maxDoseNote,
    this.conversionNote,
    required this.color,
    this.preDilutedVolumes = const {},
  });

  /// Returns the pre-diluted volume for a given vial size, or null if not pre-diluted.
  double? preDilutedVolumeFor(int vialUnits) => preDilutedVolumes[vialUnits];

  bool get isPreDiluted => preDilutedVolumes.isNotEmpty;
}

class DilutionPreset {
  final int vialUnits;
  final double salineMl;
  final String label;

  const DilutionPreset({
    required this.vialUnits,
    required this.salineMl,
    required this.label,
  });

  double get concentration => salineMl > 0 ? vialUnits / salineMl : 0;
}
