/// Which side(s) a muscle is being injected on. Bilateral counts the dose
/// twice toward the session total — a common arithmetic slip when planning.
enum InjectionSide {
  right,
  left,
  bilateral;

  String get label => switch (this) {
        InjectionSide.right => 'Right',
        InjectionSide.left => 'Left',
        InjectionSide.bilateral => 'Bilateral',
      };

  String get short => switch (this) {
        InjectionSide.right => 'R',
        InjectionSide.left => 'L',
        InjectionSide.bilateral => 'B',
      };

  /// How many times the per-side dose is delivered this session.
  int get multiplier => this == InjectionSide.bilateral ? 2 : 1;
}

/// One planned injection in a treatment session: a muscle, the brand and
/// per-side dose chosen for it, and which side(s). Stored locally only — it
/// carries no patient identifiers.
class SessionItem {
  final String muscleId;
  final String muscleName;
  final String group;

  /// Brand name: 'Botox' | 'Xeomin' | 'Dysport' | 'Myobloc'.
  final String brand;

  /// Dose in [brand]'s units, per side.
  final double dose;

  final InjectionSide side;

  /// Injection sites actually performed this session. Counted up as they
  /// happen rather than down from a plan: fewer than half the muscles
  /// document a site count, and those that do give a range (1-4), so a target
  /// number would be invented for most of the list.
  final int sitesLogged;

  /// When this muscle was marked finished, or null while it is still to do.
  /// A muscle finished with [sitesLogged] of 0 was deliberately skipped.
  final int? completedAtMillis;

  const SessionItem({
    required this.muscleId,
    required this.muscleName,
    required this.group,
    required this.brand,
    required this.dose,
    this.side = InjectionSide.right,
    this.sitesLogged = 0,
    this.completedAtMillis,
  });

  bool get isDone => completedAtMillis != null;
  bool get wasSkipped => isDone && sitesLogged == 0;

  /// Total units this item contributes to the session (doubled if bilateral).
  double get totalUnits => dose * side.multiplier;

  /// [clearCompletedAt] is the only way to un-finish an item: passing null to
  /// `completedAtMillis` cannot be told apart from omitting it.
  SessionItem copyWith({
    String? brand,
    double? dose,
    InjectionSide? side,
    int? sitesLogged,
    int? completedAtMillis,
    bool clearCompletedAt = false,
  }) {
    return SessionItem(
      muscleId: muscleId,
      muscleName: muscleName,
      group: group,
      brand: brand ?? this.brand,
      dose: dose ?? this.dose,
      side: side ?? this.side,
      sitesLogged: sitesLogged ?? this.sitesLogged,
      completedAtMillis:
          clearCompletedAt ? null : (completedAtMillis ?? this.completedAtMillis),
    );
  }

  Map<String, dynamic> toJson() => {
        'muscleId': muscleId,
        'muscleName': muscleName,
        'group': group,
        'brand': brand,
        'dose': dose,
        'side': side.name,
        'sitesLogged': sitesLogged,
        'completedAt': completedAtMillis,
      };

  factory SessionItem.fromJson(Map<String, dynamic> json) {
    return SessionItem(
      muscleId: json['muscleId'] as String,
      muscleName: json['muscleName'] as String,
      group: json['group'] as String? ?? '',
      brand: json['brand'] as String,
      dose: (json['dose'] as num).toDouble(),
      side: InjectionSide.values.firstWhere(
        (s) => s.name == json['side'],
        orElse: () => InjectionSide.right,
      ),
      // Absent in plans saved before live sessions existed: an old plan
      // reloads as one that has not been started, which is correct.
      sitesLogged: (json['sitesLogged'] as num?)?.toInt() ?? 0,
      completedAtMillis: (json['completedAt'] as num?)?.toInt(),
    );
  }
}

/// Midpoint of a dose-range string: "100-200" -> 150, "100" -> 100.
/// Returns null when no number can be parsed.
double? midpointOfDoseRange(String range) {
  final nums = RegExp(r'\d+(?:\.\d+)?')
      .allMatches(range)
      .map((m) => double.parse(m.group(0)!))
      .toList();
  if (nums.isEmpty) return null;
  if (nums.length == 1) return nums.first;
  return ((nums.first + nums[1]) / 2).roundToDouble();
}
