import 'package:provider/provider.dart';
import 'package:repositories/repositories.dart';

import '../providers/auth_provider.dart';

class AuthProviders {
  const AuthProviders._();

  static List<ChangeNotifierProvider<AuthProvider>> build({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) {
    return [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(
          authRepository: authRepository,
          userRepository: userRepository,
        )..initialize(),
      ),
    ];
  }
}
