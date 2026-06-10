import 'package:flutter_test/flutter_test.dart';
import 'package:neuroinject/models/clinical_photo.dart';

void main() {
  group('ClinicalPhotoSlot', () {
    test('there are exactly four slots with the expected keys', () {
      expect(ClinicalPhotoSlot.values.map((s) => s.key).toList(),
          ['position', 'probe', 'needle', 'us']);
    });

    test('fileName follows the <muscleId>-<key>.jpg convention', () {
      expect(ClinicalPhotoSlot.position.fileName('fcr'), 'fcr-position.jpg');
      expect(ClinicalPhotoSlot.probe.fileName('fcr'), 'fcr-probe.jpg');
      expect(ClinicalPhotoSlot.needle.fileName('fcr'), 'fcr-needle.jpg');
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
