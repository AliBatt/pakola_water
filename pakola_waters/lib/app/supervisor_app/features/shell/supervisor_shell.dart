import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../../../shared/push/app_push_controller.dart';
import '../orders/supervisor_orders_controller.dart';

class SupervisorShell extends StatefulWidget {
  const SupervisorShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<SupervisorShell> createState() => _SupervisorShellState();
}

class _SupervisorShellState extends State<SupervisorShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppPushController>().ensureStarted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final newOrders = context.watch<SupervisorOrdersController>().newOrderCount;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: widget.navigationShell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: newOrders > 0,
              label: Text(newOrders > 9 ? '9+' : '$newOrders'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: newOrders > 0,
              label: Text(newOrders > 9 ? '9+' : '$newOrders'),
              child: const Icon(Icons.receipt_long),
            ),
            label: l10n.navOrders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.delivery_dining_outlined),
            selectedIcon: const Icon(Icons.delivery_dining),
            label: l10n.navRiders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
