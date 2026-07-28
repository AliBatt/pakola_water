import 'dart:typed_data';

/// Stub for non-web platforms — admin reports export targets Flutter web.
void downloadBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) {
  throw UnsupportedError(
    'Report download is only supported in the admin web app.',
  );
}
