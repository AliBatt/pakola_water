import 'package:authentication/authentication.dart';

import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../features/home/home_screen.dart';

GoRouter createAppRouter({
  required AppConfig config,
  required AuthProvider authProvider,
}) {
  return GoRouter(
    initialLocation: AuthRoutes.login,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final auth = authProvider;
      final isLogin = state.matchedLocation == AuthRoutes.login;

      if (auth.status == AuthStatus.unknown) {
        return null;
      }

      if (auth.status == AuthStatus.unauthenticated ||
          auth.status == AuthStatus.suspended) {
        return isLogin ? null : AuthRoutes.login;
      }

      final user = auth.user;
      if (user != null && user.role != config.requiredRole) {
        return AuthRoutes.login;
      }

      if (isLogin) {
        return AuthRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AuthRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AuthRoutes.home,
        builder: (context, state) => HomeScreen(config: config),
      ),
    ],
  );
}
