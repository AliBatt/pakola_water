import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<void> initialize({FirebaseOptions? options}) async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(options: options);
  }
}
