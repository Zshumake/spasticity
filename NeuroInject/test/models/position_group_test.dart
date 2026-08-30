import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/clinical_photo.dart';
import 'package:neuroinject/models/muscle.dart';

/// Two clinical-photo slots are shared between muscles, for different reasons:
///
///  * position  — muscles set up identically reuse one `pos-<group>.jpg`.
///  * ultrasound — one transverse view usually contains several muscles, so
///    muscles in an [Muscle.ultrasoundGroup] reuse one `us-<group>.jpg` and are
///    told apart by their own highlight mask.
///
/// The probe photo is always per-muscle.
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

  test('the probe photo is always per-muscle', () {
    expect(byId('gastrocnemius-medial').clinicalPhotoFileName(ClinicalPhotoSlot.probe),
        'gastrocnemius-medial-probe.jpg');
    expect(byId('soleus-medial').clinicalPhotoFileName(ClinicalPhotoSlot.probe),
        'soleus-medial-probe.jpg');
  });

  test('ultrasound is keyed by group when the scan is shared', () {
    final m = byId('gastrocnemius-medial');
    expect(m.ultrasoundGroup, isNotNull);
    expect(m.clinicalPhotoFileName(ClinicalPhotoSlot.ultrasound),
        'us-${m.ultrasoundGroup}.jpg');
  });

  test('ultrasound falls back to the muscle id when the scan is not shared', () {
    final m = byId('fhl');
    expect(m.ultrasoundGroup, isNull);
    expect(m.clinicalPhotoFileName(ClinicalPhotoSlot.ultrasound), 'fhl-us.jpg');
  });

  test('muscles in one US view share the scan but keep separate masks', () {
    // A single calf view shows medial gastrocnemius above the aponeurosis and
    // soleus below it — the relationship is the lesson, so the pixels are
    // shared and only the highlight mask differs.
    final pair = ['gastrocnemius-medial', 'soleus-medial'].map(byId).toList();
    final scans = pair
        .map((m) => m.clinicalPhotoPath(ClinicalPhotoSlot.ultrasound))
        .toSet();
    expect(scans, hasLength(1), reason: 'one scan serves both muscles');
    final masks = pair.map((m) => m.ultrasoundMaskPath).toSet();
    expect(masks, hasLength(2), reason: 'but each muscle needs its own mask');
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
