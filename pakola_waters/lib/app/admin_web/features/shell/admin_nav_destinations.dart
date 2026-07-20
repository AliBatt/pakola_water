import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../routing/admin_routes.dart';

class AdminNavDestination {
  const AdminNavDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.labelBuilder,
  });

  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) labelBuilder;

  static final List<AdminNavDestination> items = [
    AdminNavDestination(
      route: AdminRoutes.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelBuilder: (l10n) => l10n.navHome,
    ),
    AdminNavDestination(
      route: AdminRoutes.branches,
      icon: Icons.store_outlined,
      selectedIcon: Icons.store,
      labelBuilder: (l10n) => l10n.navBranches,
    ),
    AdminNavDestination(
      route: AdminRoutes.supervisors,
      icon: Icons.supervisor_account_outlined,
      selectedIcon: Icons.supervisor_account,
      labelBuilder: (l10n) => l10n.navSupervisors,
    ),
    AdminNavDestination(
      route: AdminRoutes.riders,
      icon: Icons.delivery_dining_outlined,
      selectedIcon: Icons.delivery_dining,
      labelBuilder: (l10n) => l10n.navRiders,
    ),
    AdminNavDestination(
      route: AdminRoutes.customers,
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      labelBuilder: (l10n) => l10n.navCustomers,
    ),
    AdminNavDestination(
      route: AdminRoutes.payments,
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments,
      labelBuilder: (l10n) => l10n.navPayments,
    ),
    AdminNavDestination(
      route: AdminRoutes.reports,
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      labelBuilder: (l10n) => l10n.navReports,
    ),
    AdminNavDestination(
      route: AdminRoutes.inventory,
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      labelBuilder: (l10n) => l10n.navInventory,
    ),
    AdminNavDestination(
      route: AdminRoutes.products,
      icon: Icons.water_drop_outlined,
      selectedIcon: Icons.water_drop,
      labelBuilder: (l10n) => l10n.navProducts,
    ),
    AdminNavDestination(
      route: AdminRoutes.notifications,
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      labelBuilder: (l10n) => l10n.navNotifications,
    ),
    AdminNavDestination(
      route: AdminRoutes.requests,
      icon: Icons.inbox_outlined,
      selectedIcon: Icons.inbox,
      labelBuilder: (l10n) => l10n.navRequests,
    ),
    AdminNavDestination(
      route: AdminRoutes.orders,
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      labelBuilder: (l10n) => l10n.navOrders,
    ),
    AdminNavDestination(
      route: AdminRoutes.settings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelBuilder: (l10n) => l10n.navSettings,
    ),
  ];

  static int indexForLocation(String location) {
    final path = Uri.parse(location).path;
    final index = items.indexWhere((item) => item.route == path);
    return index < 0 ? 0 : index;
  }
}
