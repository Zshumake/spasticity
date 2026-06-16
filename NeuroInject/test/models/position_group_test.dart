import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/clinical_photo.dart';
import 'package:neuroinject/models/muscle.dart';

/// Patient-position photos are shared across muscles set up the same way:
/// every muscle in a [Muscle.positionGroup] reuses one `pos-<group>.jpg`,
/// while probe and ultrasound photos stay per-muscle.
void main() {
  final muscles = (json.decode(
              File('assets/data/muscles.json').readAsStringSync()) as List)
      .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
      .toList();
  Muscle byId(String id) => muscles.firstWhere((m) => m.id == id);

  test('every muscle has a positionGroup and positionLabel', () {
    final missing = muscles
        .where((m) => (m.positionGroup ?? '').isEmpty ||
            (m.positionLabel ?? '').isEmpty)
        .map((m) => m.id);
    expect(missing, isEmpty, reason: 'missing position data: ${missing.join(', ')}');
  });

  test('position photo path/filename is keyed by group, not muscle id', () {
    final m = byId('gastrocnemius-medial');
    expect(m.clinicalPhotoFileName(ClinicalPhotoSlot.position),
        'pos-${m.positionGroup}.jpg');
    expect(m.clinicalPhotoPath(ClinicalPhotoSlot.position),
        'assets/images/clinical/pos-${m.positionGroup}.jpg');
  });

  test('probe and ultrasound stay per-muscle', () {
    final m = byId('gastrocnemius-medial');
    expect(m.clinicalPhotoFileName(ClinicalPhotoSlot.probe),
        'gastrocnemius-medial-probe.jpg');
    expect(m.clinicalPhotoFileName(ClinicalPhotoSlot.ultrasound),
        'gastrocnemius-medial-us.jpg');
  });

  test('muscles in the same group share ONE position photo', () {
    // The prone-feet-off-bed group: gastroc + soleus + FHL.
    final group = ['gastrocnemius-medial', 'gastrocnemius-lateral',
            'soleus-medial', 'soleus-lateral', 'fhl']
        .map(byId)
        .toList();
    final positionPaths = group
        .map((m) => m.clinicalPhotoPath(ClinicalPhotoSlot.position))
        .toSet();
    expect(positionPaths, hasLength(1),
        reason: 'these muscles should reuse one position photo');
    // ...but each has its own probe photo.
    final probePaths = group
        .map((m) => m.clinicalPhotoPath(ClinicalPhotoSlot.probe))
        .toSet();
    expect(probePaths, hasLength(group.length));
  });

  test('shared position photos meaningfully reduce the shot count', () {
    final uniquePositions = muscles.map((m) => m.positionGroup).toSet();
    expect(uniquePositions.length, lessThan(muscles.length));
  });
}
