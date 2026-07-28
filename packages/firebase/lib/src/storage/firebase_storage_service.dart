import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final ref = _storage.ref(path);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }

  /// Downloads file bytes via the Storage SDK (works on Flutter web
  /// without requiring a GCS CORS config for Image.network).
  Future<Uint8List?> downloadBytesByUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    try {
      final data = await _storage.refFromURL(trimmed).getData(5 * 1024 * 1024);
      if (data == null || data.isEmpty) return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // Ignore missing/orphan files.
    }
  }
}
