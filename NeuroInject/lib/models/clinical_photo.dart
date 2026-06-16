import 'package:flutter/material.dart';

/// The three standardized clinical photos captured per muscle.
///
/// Paths follow a strict convention, so adding a photo is just dropping a
/// correctly-named file into `assets/images/clinical/`:
///
///     assets/images/clinical/<muscleId>-<key>.jpg
///
/// e.g. for `pec-major`: `pec-major-position.jpg`, `pec-major-probe.jpg`,
/// `pec-major-us.jpg`. No JSON or code edit is needed — the muscle detail
/// page auto-detects the file and swaps the placeholder for the photo.
///
/// The probe slot is one annotated surface photo covering both probe
/// placement and the needle insertion site: a blue bar marks the probe
/// footprint and a red dot marks the needle entry point.
enum ClinicalPhotoSlot {
  position(
    key: 'position',
    label: 'Patient Position',
    description: 'How the patient is positioned and the segment exposed',
    icon: Icons.airline_seat_flat_rounded,
  ),
  probe(
    key: 'probe',
    label: 'Probe + Needle Site',
    description: 'Blue bar = probe footprint · red dot = needle entry',
    icon: Icons.sensors_rounded,
  ),
  ultrasound(
    key: 'us',
    label: 'Ultrasound Image',
    description: 'US view of the target muscle (needle in muscle if shown)',
    icon: Icons.monitor_heart_outlined,
  );

  const ClinicalPhotoSlot({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String key;
  final String label;
  final String description;
  final IconData icon;

  /// Folder (and pubspec asset directory) that holds every clinical photo.
  static const String dir = 'assets/images/clinical';

  /// Conventional bare filename for this slot on [muscleId] (e.g. `fcr-probe.jpg`).
  String fileName(String muscleId) => '$muscleId-$key.jpg';

  /// Conventional bundled asset path for this slot on [muscleId].
  String assetPath(String muscleId) => '$dir/${fileName(muscleId)}';
}
