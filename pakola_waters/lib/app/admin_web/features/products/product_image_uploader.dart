import 'dart:typed_data';

import 'package:firebase/firebase.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProductImageUploader {
  ProductImageUploader({
    FirebaseStorageService? storageService,
    ImagePicker? picker,
  })  : _storageService = storageService ?? FirebaseStorageService(),
        _picker = picker ?? ImagePicker();

  final FirebaseStorageService _storageService;
  final ImagePicker _picker;
  final _uuid = const Uuid();

  static const int maxPhotos = 2;

  Future<XFile?> pickImage() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
  }

  Future<Uint8List> compress(XFile file) async {
    final original = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      original,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );
    return compressed.isEmpty ? original : Uint8List.fromList(compressed);
  }

  Future<String> upload({
    required String productKey,
    required Uint8List bytes,
  }) {
    final path = 'products/$productKey/${_uuid.v4()}.jpg';
    return _storageService.uploadBytes(
      path: path,
      bytes: bytes,
      contentType: 'image/jpeg',
    );
  }

  Future<void> deleteUrls(List<String> urls) async {
    for (final url in urls) {
      await _storageService.deleteByUrl(url);
    }
  }
}
