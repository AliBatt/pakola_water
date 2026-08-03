import 'package:authentication/authentication.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:rider_management/rider_management.dart';

import '../config/app_config.dart';
import '../features/branches/branches_screen.dart';
import '../features/customers/admin_customers_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/admin_notifications_screen.dart';
import '../features/orders/admin_orders_screen.dart';
import '../features/payments/admin_payments_screen.dart';
import '../features/products/products_screen.dart';
import '../features/reports/admin_reports_screen.dart';
import '../features/requests/admin_requests_screen.dart';
import '../features/settings/admin_settings_screen.dart';
import '../features/shell/admin_shell.dart';
import '../features/supervisors/supervisors_screen.dart';
import 'admin_routes.dart';

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
      final isAdminRoute = AdminRoutes.all.contains(location);

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
        return AdminRoutes.home;
      }

      if (!isAdminRoute && !isLogin) {
        return AdminRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AuthRoutes.login,
        builder: (context, state) => const LoginScreen(
          requiredRole: AppRole.admin,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AdminRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.branches,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BranchesScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.supervisors,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SupervisorsScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.riders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RidersScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.customers,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminCustomersScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.payments,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminPaymentsScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminReportsScreen(),
            ),
          ),
          // Inventory route kept for later; nav entry is commented out.
          // GoRoute(
          //   path: AdminRoutes.inventory,
          //   pageBuilder: (context, state) => NoTransitionPage(
          //     child: AdminPlaceholderPage(
          //       title: context.l10n.navInventory,
          //     ),
          //   ),
          // ),
          GoRoute(
            path: AdminRoutes.products,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductsScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.notifications,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminNotificationsScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.requests,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminRequestsScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.orders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminOrdersScreen(),
            ),
          ),
          GoRoute(
            path: AdminRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminSettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
