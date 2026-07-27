import 'package:authentication/authentication.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../features/home/driver_home_screen.dart';
import '../features/notifications/driver_notifications_screen.dart';
import '../features/orders/driver_orders_screen.dart';
import '../features/settings/driver_settings_screen.dart';
import '../features/shell/driver_shell.dart';
import 'driver_routes.dart';

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
        return DriverRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AuthRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: DriverRoutes.notifications,
        builder: (context, state) => const DriverNotificationsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DriverShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: DriverRoutes.home,
                builder: (context, state) => const DriverHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: DriverRoutes.orders,
                builder: (context, state) => const DriverOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: DriverRoutes.settings,
                builder: (context, state) => const DriverSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
