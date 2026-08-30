/// @docImport 'coco_download_io.dart';
/// @docImport 'coco_download_web.dart';
library;

/// Save exported JSON to a real file, on whichever platform is running.
///
/// The captures that back the training set live in `shared_preferences`, which
/// on web is nothing more than browser localStorage — clearing site data, or an
/// ephemeral browser profile, takes the whole set with it. Copying to the
/// clipboard is not a backup: it survives exactly until the next copy. Writing
/// a file is what actually gets the work out of the browser.
///
/// Implementation is chosen at compile time: `dart:io` where there is a
/// filesystem, a Blob download in the browser.
export 'coco_download_web.dart' if (dart.library.io) 'coco_download_io.dart';
