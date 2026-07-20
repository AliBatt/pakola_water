import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Creates Auth users without signing out the current admin session.
class FirebaseAuthAdminService {
  FirebaseAuthAdminService({FirebaseOptions? options}) : _options = options;

  final FirebaseOptions? _options;
  static const String _secondaryAppName = 'pakolaSecondaryAuth';

  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    final options = _options ?? Firebase.app().options;
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app(_secondaryAppName);
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: _secondaryAppName,
        options: options,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await secondaryAuth.signOut();
      return credential;
    } catch (_) {
      await secondaryAuth.signOut();
      rethrow;
    }
  }
}
