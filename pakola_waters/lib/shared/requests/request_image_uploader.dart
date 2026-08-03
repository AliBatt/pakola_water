import 'package:firebase/firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../widgets/storage_network_image.dart';

class RequestImageUploader {
  RequestImageUploader({
    FirebaseStorageService? storageService,
    ImagePicker? picker,
  })  : _storageService = storageService ?? FirebaseStorageService(),
        _picker = picker ?? ImagePicker();

  final FirebaseStorageService _storageService;
  final ImagePicker _picker;
  final _uuid = const Uuid();

  Future<XFile?> pickImage() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
  }

  Future<Uint8List> compress(XFile file) async {
    final original = await file.readAsBytes();
    if (kIsWeb) return original;
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        original,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );
      return compressed.isEmpty ? original : Uint8List.fromList(compressed);
    } catch (_) {
      return original;
    }
  }

  Future<String> upload({
    required String requestKey,
    required Uint8List bytes,
  }) {
    final path = 'support_requests/$requestKey/${_uuid.v4()}.jpg';
    return _storageService.uploadBytes(
      path: path,
      bytes: bytes,
      contentType: 'image/jpeg',
    );
  }

  Future<void> deleteUrl(String url) async {
    await _storageService.deleteByUrl(url);
    StorageNetworkImage.clearCache(url);
  }
}
