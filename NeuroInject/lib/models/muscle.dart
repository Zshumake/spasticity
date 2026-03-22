class Muscle {
  final String id;
  final String name;
  final String group;
  final String pattern;
  final List<String> landmarks;
  final List<String> placement;
  final List<String> setup;
  final UltrasoundGuide? ultrasound;
  final String? dosage;
  final MarkerPosition? marker;
  final List<String> referenceImages;
  final List<String> probePlacementImages;
  final String? probePlacementHint;
  final List<String> pearls;
  final List<String> supplies;
  final String? videoUrl;
  final bool hasReferenceImage;

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
    this.marker,
    this.referenceImages = const [],
    this.probePlacementImages = const [],
    this.probePlacementHint,
    this.pearls = const [],
    this.supplies = const [],
    this.videoUrl,
    this.hasReferenceImage = false,
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
      dosage: json['dosage'] as String?,
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
      pearls: json['pearls'] != null
          ? (json['pearls'] as List).cast<String>()
          : const [],
      supplies: json['supplies'] != null
          ? (json['supplies'] as List).cast<String>()
          : const [],
      videoUrl: json['videoUrl'] as String?,
      hasReferenceImage: json['hasReferenceImage'] as bool? ?? false,
    );
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
