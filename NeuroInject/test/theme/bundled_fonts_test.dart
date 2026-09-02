import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The brand fonts are bundled so a first launch with no network (a locked
/// down hospital Wi-Fi, airplane mode) still renders Sora, Source Sans 3 and
/// IBM Plex Mono rather than the system fallback. google_fonts finds them by
/// NAME in the asset manifest — `<Family>-<Variant>.ttf`, family without
/// spaces — so a renamed or dropped file silently reverts to a network fetch.
/// This pins every weight the app actually asks for.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every font weight the app uses is bundled under its google_fonts name',
      () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();
    const expected = [
      // Sora: display, w400 default through the w800 hero titles.
      'Sora-Regular', 'Sora-Medium', 'Sora-SemiBold', 'Sora-Bold', 'Sora-ExtraBold',
      // Source Sans 3: body, plus the italic probe hints.
      'SourceSans3-Regular', 'SourceSans3-SemiBold', 'SourceSans3-Bold',
      'SourceSans3-Italic', 'SourceSans3-SemiBoldItalic',
      // IBM Plex Mono: eyebrow labels and tabular clinical numbers.
      'IBMPlexMono-Regular', 'IBMPlexMono-Medium', 'IBMPlexMono-SemiBold',
      'IBMPlexMono-Bold',
    ];
    for (final name in expected) {
      expect(assets, contains('assets/fonts/$name.ttf'), reason: name);
    }
  });
}
