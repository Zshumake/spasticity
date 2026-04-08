class SpasticityPattern {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final List<String> muscles;
  final String region;

  const SpasticityPattern({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.muscles,
    required this.region,
  });

  factory SpasticityPattern.fromJson(Map<String, dynamic> json) {
    return SpasticityPattern(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      description: json['description'] as String,
      muscles: (json['muscles'] as List).cast<String>(),
      region: json['region'] as String,
    );
  }
}
