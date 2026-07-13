import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

  // TODO: Replace with flutterfire-generated options per environment.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (kDebugMode) {
      debugPrint(
        'FirebaseBootstrap: add firebase_options via flutterfire configure',
      );
    }
  }
}
