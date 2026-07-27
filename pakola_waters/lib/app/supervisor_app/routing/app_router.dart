import 'package:authentication/authentication.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../features/riders/supervisor_riders_screen.dart';
import '../features/home/supervisor_home_screen.dart';
import '../features/notifications/supervisor_notifications_screen.dart';
import '../features/orders/supervisor_orders_screen.dart';
import '../features/settings/supervisor_settings_screen.dart';
import '../features/shell/supervisor_shell.dart';
import '../routing/supervisor_routes.dart';

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
        return SupervisorRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AuthRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SupervisorRoutes.notifications,
        builder: (context, state) => const SupervisorNotificationsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SupervisorShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SupervisorRoutes.home,
                builder: (context, state) => const SupervisorHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SupervisorRoutes.orders,
                builder: (context, state) => const SupervisorOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SupervisorRoutes.riders,
                builder: (context, state) => const SupervisorRidersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SupervisorRoutes.settings,
                builder: (context, state) => const SupervisorSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
