import 'clinical_photo.dart';

class Muscle {
  final String id;
  final String name;
  final String group;
  final String pattern;
  final List<String> landmarks;
  final List<String> placement;
  final List<String> setup;
  final UltrasoundGuide? ultrasound;
  final Dosage? dosage;
  final String? dosageNote;
  final MarkerPosition? marker;
  final List<String> referenceImages;
  final List<String> probePlacementImages;
  final String? probePlacementHint;
  /// Rendered anatomy reference images keyed by view name
  /// ('anterior', 'posterior', 'lateral'). Filename only; the app
  /// prepends 'assets/images/anatomy/' on render.
  final Map<String, String> anatomyImages;
  /// Short caption shown as an overlay on the anatomy card.
  /// Example: "Anterior forearm · FCR highlighted"
  final String? anatomyCaption;
  /// Which view to show first when the detail page opens.
  /// Used to default posterior-aspect muscles (hamstrings, gastroc,
  /// triceps, etc.) to their posterior view. When null, defaults
  /// to 'anterior'.
  final String? defaultAnatomyView;
  final List<String> pearls;
  /// Adjacent-structure hazards — "if you go wrong direction, you hit Y"
  /// items sourced from the book's "Topographical indication" section.
  /// Rendered as an amber safety callout in the UI, separate from the
  /// general `pearls` list so safety-critical information is visually
  /// demoted from clinical-teaching commentary.
  final List<String> dangerZones;
  final List<String> supplies;
  final String? videoUrl;
  final List<String> spasticityPatterns;
  final List<String> relatedMuscles;
  final bool hasReferenceImage;
  /// Key identifying the shared patient-position photo. Muscles with the same
  /// [positionGroup] are set up identically, so they reuse ONE position photo
  /// (`assets/images/clinical/pos-<positionGroup>.jpg`) instead of each having
  /// their own. [positionLabel] is the human-readable position.
  final String? positionGroup;
  final String? positionLabel;

  /// Key identifying a shared ultrasound scan. One transverse view usually
  /// contains several muscles — a calf view shows medial gastrocnemius AND
  /// soleus — and the relationship between them is itself the lesson. Muscles
  /// with the same [ultrasoundGroup] share ONE scan
  /// (`assets/images/clinical/us-<ultrasoundGroup>.jpg`) and are told apart by
  /// their own highlight mask, rather than each duplicating identical pixels.
  final String? ultrasoundGroup;

  /// Alternative ultrasound views for muscles that can be scanned (and
  /// injected) from more than one window — e.g. tibialis posterior is seen
  /// both on the anterior TA view and on the medial FDL view. When non-empty
  /// this REPLACES the single ultrasoundGroup/mask pair: the detail screen
  /// shows a toggle and each view carries its own scan and highlight mask.
  final List<UltrasoundView> ultrasoundViews;

  const Muscle({
    required this.id,
    required this.name,
    required this.group,
    required this.pattern,
    required this.landmarks,
    required this.placement,
    required this.setup,
    this.ultrasound,
    this.dosage,
    this.dosageNote,
    this.marker,
    this.referenceImages = const [],
    this.probePlacementImages = const [],
    this.probePlacementHint,
    this.anatomyImages = const {},
    this.anatomyCaption,
    this.defaultAnatomyView,
    this.pearls = const [],
    this.dangerZones = const [],
    this.supplies = const [],
    this.videoUrl,
    this.spasticityPatterns = const [],
    this.relatedMuscles = const [],
    this.hasReferenceImage = false,
    this.positionGroup,
    this.positionLabel,
    this.ultrasoundGroup,
    this.ultrasoundViews = const [],
  });

  factory Muscle.fromJson(Map<String, dynamic> json) {
    return Muscle(
      id: json['id'] as String,
      name: json['name'] as String,
      group: json['group'] as String,
      pattern: json['pattern'] as String,
      landmarks: _parseStringOrList(json['landmarks']),
      placement: _parseStringOrList(json['placement']),
      setup: _parseStringOrList(json['setup']),
      ultrasound: json['ultrasound'] != null
          ? UltrasoundGuide.fromJson(json['ultrasound'] as Map<String, dynamic>)
          : null,
      dosage: Dosage.tryParse(json['dosage']),
      dosageNote: json['dosageNote'] as String?,
      marker: json['marker'] != null
          ? MarkerPosition.fromJson(json['marker'] as Map<String, dynamic>)
          : null,
      referenceImages: json['referenceImages'] != null
          ? (json['referenceImages'] as List).cast<String>()
          : const [],
      probePlacementImages: json['probePlacementImages'] != null
          ? (json['probePlacementImages'] as List).cast<String>()
          : const [],
      probePlacementHint: json['probePlacementHint'] as String?,
      anatomyImages: _parseAnatomyImages(json['anatomyImages']),
      anatomyCaption: json['anatomyCaption'] as String?,
      defaultAnatomyView: json['defaultAnatomyView'] as String?,
      pearls: json['pearls'] != null
          ? (json['pearls'] as List).cast<String>()
          : const [],
      dangerZones: json['dangerZones'] != null
          ? (json['dangerZones'] as List).cast<String>()
          : const [],
      supplies: json['supplies'] != null
          ? (json['supplies'] as List).cast<String>()
          : const [],
      videoUrl: json['videoUrl'] as String?,
      spasticityPatterns: json['spasticityPatterns'] != null
          ? (json['spasticityPatterns'] as List).cast<String>()
          : const [],
      relatedMuscles: json['relatedMuscles'] != null
          ? (json['relatedMuscles'] as List).cast<String>()
          : const [],
      hasReferenceImage: json['hasReferenceImage'] as bool? ?? false,
      positionGroup: json['positionGroup'] as String?,
      positionLabel: json['positionLabel'] as String?,
      ultrasoundGroup: json['ultrasoundGroup'] as String?,
      ultrasoundViews: json['ultrasoundViews'] != null
          ? [
              for (final v in json['ultrasoundViews'] as List)
                UltrasoundView.fromJson(v as Map<String, dynamic>)
            ]
          : const [],
    );
  }

  /// Bundled asset path for a clinical photo [slot].
  ///
  /// Two slots can be shared between muscles: the patient-position photo by
  /// [positionGroup] (one `pos-<group>.jpg` per identical setup) and the
  /// ultrasound scan by [ultrasoundGroup] (one `us-<group>.jpg` per view, with
  /// each muscle distinguished by its own [ultrasoundMaskPath]). The probe
  /// photo is always per-muscle.
  String clinicalPhotoPath(ClinicalPhotoSlot slot) =>
      '${ClinicalPhotoSlot.dir}/${clinicalPhotoFileName(slot)}';

  /// Bare filename for a clinical photo [slot] (see [clinicalPhotoPath]).
  String clinicalPhotoFileName(ClinicalPhotoSlot slot) => switch (slot) {
        ClinicalPhotoSlot.position when positionGroup != null =>
          'pos-$positionGroup.jpg',
        ClinicalPhotoSlot.ultrasound when ultrasoundGroup != null =>
          'us-$ultrasoundGroup.jpg',
        _ => slot.fileName(id),
      };

  /// Baked highlight mask for this muscle, produced by
  /// `tools/refine_highlights.py`. Always per-muscle even when the underlying
  /// scan is shared — the mask is what separates one muscle from its
  /// neighbours in the same view.
  String get ultrasoundMaskPath =>
      'assets/images/us_reference/$id-us.mask.png';

  /// The ultrasound views to render, always at least one: the explicit
  /// [ultrasoundViews] when present, else the muscle's single default
  /// scan/mask pair. Every US surface (detail slot, highlighter) iterates
  /// this instead of touching the raw fields, so multi-view muscles work
  /// everywhere without special-casing.
  List<UltrasoundView> get resolvedUltrasoundViews => ultrasoundViews.isNotEmpty
      ? ultrasoundViews
      : [
          UltrasoundView(
            label: 'Ultrasound',
            scanAsset: clinicalPhotoPath(ClinicalPhotoSlot.ultrasound),
            maskAsset: ultrasoundMaskPath,
            probeAsset: clinicalPhotoPath(ClinicalPhotoSlot.probe),
          )
        ];

  /// Parse anatomyImages: supports new `Map<String, String>` schema (keyed
  /// by view name: 'anterior', 'posterior', 'lateral') and legacy
  /// `List<String>` schema (treated as {'anterior': filename}).
  static Map<String, String> _parseAnatomyImages(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      return Map<String, String>.from(value.cast<String, String>());
    }
    if (value is List && value.isNotEmpty) {
      return {'anterior': value.first.toString()};
    }
    return const {};
  }

  /// Handles both legacy string format and new array format
  static List<String> _parseStringOrList(dynamic value) {
    if (value is List) {
      return value.cast<String>();
    }
    if (value is String) {
      return [value];
    }
    return [];
  }

  bool get isUpperExtremity => group.contains('Upper');
  bool get isLowerExtremity => group.contains('Lower');
}

/// Typed, brand-specific dosage for botulinum toxin injection.
///
/// Each field is a human-readable range string (e.g. "100-200") in that
/// product's units. Botox (onabotulinumtoxinA), Xeomin (incobotulinumtoxinA),
/// and Dysport (abobotulinumtoxinA) are NOT interchangeable 1:1 — Dysport
/// is roughly 2.5–3× the unit count of Botox/Xeomin for the same effect.
///
/// Always display the brand name alongside the number. Never show a bare
/// "100 units" label.
class Dosage {
  /// onabotulinumtoxinA (Botox) range, e.g. "100-200"
  final String? botox;

  /// incobotulinumtoxinA (Xeomin) range, e.g. "100-200"
  final String? xeomin;

  /// abobotulinumtoxinA (Dysport) range, e.g. "300-600"
  final String? dysport;

  const Dosage({this.botox, this.xeomin, this.dysport});

  /// Parse from JSON. Accepts both the new typed object format and the
  /// legacy string format (treated as Botox for backward compatibility
  /// during migration).
  static Dosage? tryParse(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final map = value.cast<String, dynamic>();
      return Dosage(
        botox: map['botox'] as String?,
        xeomin: map['xeomin'] as String?,
        dysport: map['dysport'] as String?,
      );
    }
    if (value is String) {
      // Legacy: assume the number is a Botox dose.
      return Dosage(botox: value.replaceAll(RegExp(r'\s*units?\s*$'), ''));
    }
    return null;
  }

  /// Preferred single-line display — Botox first, then Xeomin, then Dysport.
  /// Example: "Botox 100-200 U · Dysport 300-600 U"
  String get displayFull {
    final parts = <String>[];
    if (botox != null) parts.add('Botox $botox U');
    if (xeomin != null) parts.add('Xeomin $xeomin U');
    if (dysport != null) parts.add('Dysport $dysport U');
    return parts.join(' · ');
  }

  /// Short label for compact chips — shows Botox only, with brand.
  /// Example: "100-200 U Botox"
  String get displayShort {
    if (botox != null) return '$botox U Botox';
    if (xeomin != null) return '$xeomin U Xeomin';
    if (dysport != null) return '$dysport U Dysport';
    return '';
  }

  /// True if at least one brand dose is specified.
  bool get hasAny => botox != null || xeomin != null || dysport != null;
}

class UltrasoundGuide {
  final String probe;
  final String orientation;
  final List<String> viewSteps;
  final List<String> safetyNotes;
  final ProbePosition? probeDiagram;
  final String? depth;
  final String? videoSource;

  const UltrasoundGuide({
    required this.probe,
    required this.orientation,
    required this.viewSteps,
    required this.safetyNotes,
    this.probeDiagram,
    this.depth,
    this.videoSource,
  });

  factory UltrasoundGuide.fromJson(Map<String, dynamic> json) {
    return UltrasoundGuide(
      probe: json['probe'] as String,
      orientation: json['orientation'] as String,
      viewSteps: (json['viewSteps'] as List).cast<String>(),
      safetyNotes: (json['safetyNotes'] as List).cast<String>(),
      probeDiagram: json['probeDiagram'] != null
          ? ProbePosition.fromJson(json['probeDiagram'] as Map<String, dynamic>)
          : null,
      depth: json['depth'] as String?,
      videoSource: json['videoSource'] as String?,
    );
  }
}

class ProbePosition {
  final double cx;
  final double cy;
  final double angle;
  final double length;

  const ProbePosition({
    required this.cx,
    required this.cy,
    required this.angle,
    required this.length,
  });

  factory ProbePosition.fromJson(Map<String, dynamic> json) {
    return ProbePosition(
      cx: (json['cx'] as num).toDouble(),
      cy: (json['cy'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      length: (json['length'] as num).toDouble(),
    );
  }
}

class MarkerPosition {
  final String body;
  final double x;
  final double y;

  const MarkerPosition({
    required this.body,
    required this.x,
    required this.y,
  });

  factory MarkerPosition.fromJson(Map<String, dynamic> json) {
    return MarkerPosition(
      body: json['body'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}

/// One labelled ultrasound window onto a muscle: which bundled scan shows it
/// and which baked mask highlights it there. Multi-view muscles (tibialis
/// posterior: anterior TA window vs medial FDL window) carry one of these per
/// approach; the mask is view-specific because the muscle's outline differs
/// completely between windows.
class UltrasoundView {
  final String label;
  final String scanAsset;
  final String maskAsset;

  /// Probe-placement illustration for THIS approach. The blue-bar/red-dot
  /// picture encodes where the transducer sits on the skin, so it must swap
  /// together with the scan — an anterior-window scan next to a medial-window
  /// probe picture would teach the wrong needle entry.
  final String? probeAsset;

  const UltrasoundView({
    required this.label,
    required this.scanAsset,
    required this.maskAsset,
    this.probeAsset,
  });

  factory UltrasoundView.fromJson(Map<String, dynamic> json) => UltrasoundView(
        label: json['label'] as String,
        scanAsset: json['scan'] as String,
        maskAsset: json['mask'] as String,
        probeAsset: json['probe'] as String?,
      );
}
