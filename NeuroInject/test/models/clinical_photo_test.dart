import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/clinical_photo.dart';

void main() {
  group('ClinicalPhotoSlot', () {
    test('there are exactly three slots with the expected keys', () {
      expect(ClinicalPhotoSlot.values.map((s) => s.key).toList(),
          ['position', 'probe', 'us']);
    });

    test('probe slot is the combined probe + needle site photo', () {
      expect(ClinicalPhotoSlot.probe.label, 'Probe + Needle Site');
    });

    test('fileName follows the <muscleId>-<key>.jpg convention', () {
      expect(ClinicalPhotoSlot.position.fileName('fcr'), 'fcr-position.jpg');
      expect(ClinicalPhotoSlot.probe.fileName('fcr'), 'fcr-probe.jpg');
      expect(ClinicalPhotoSlot.ultrasound.fileName('pec-major'),
          'pec-major-us.jpg');
    });

    test('assetPath lives under the clinical asset dir', () {
      expect(ClinicalPhotoSlot.ultrasound.assetPath('pec-major'),
          'assets/images/clinical/pec-major-us.jpg');
      expect(ClinicalPhotoSlot.dir, 'assets/images/clinical');
    });
  });
}
