import 'dart:convert';
import 'dart:typed_data';

import 'download_bytes_stub.dart'
    if (dart.library.html) 'download_bytes_web.dart' as download;

void downloadBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) {
  download.downloadBytes(
    bytes: bytes,
    filename: filename,
    mimeType: mimeType,
  );
}

void downloadText({
  required String text,
  required String filename,
  required String mimeType,
}) {
  downloadBytes(
    bytes: Uint8List.fromList(utf8.encode(text)),
    filename: filename,
    mimeType: mimeType,
  );
}
