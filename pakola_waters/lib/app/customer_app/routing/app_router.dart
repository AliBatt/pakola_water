import 'package:authentication/authentication.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';

import '../config/app_config.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/products/products_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/customer_shell.dart';
import '../../../shared/requests/support_requests_screen.dart';
import 'customer_routes.dart';

GoRouter createAppRouter({
  required AppConfig config,
  required AuthProvider authProvider,
}) {
  return GoRouter(
    initialLocation: AuthRoutes.login,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final auth = authProvider;
      final location = state.matchedLocation;
      final isLogin = location == AuthRoutes.login;
      final isSignup = location == AuthRoutes.signup;
      final isAuthRoute = isLogin || isSignup;

      if (auth.status == AuthStatus.unknown) {
        return null;
      }

      if (auth.status == AuthStatus.unauthenticated ||
          auth.status == AuthStatus.suspended) {
        return isAuthRoute ? null : AuthRoutes.login;
      }

      final user = auth.user;
      if (user != null && user.role != config.requiredRole) {
        return AuthRoutes.login;
      }

      if (isAuthRoute) {
        return CustomerRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AuthRoutes.login,
        builder: (context, state) => LoginScreen(
          requiredRole: AppRole.customer,
          onSignUp: () => context.go(AuthRoutes.signup),
        ),
      ),
      GoRoute(
        path: AuthRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: CustomerRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: CustomerRoutes.requests,
        builder: (context, state) => const SupportRequestsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CustomerRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CustomerRoutes.products,
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CustomerRoutes.orders,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CustomerRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
