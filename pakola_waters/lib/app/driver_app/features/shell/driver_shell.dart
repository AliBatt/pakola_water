import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../../../shared/push/app_push_controller.dart';
import '../orders/driver_orders_controller.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
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
    final newAssigned = context.watch<DriverOrdersController>().newAssignedCount;

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
              isLabelVisible: newAssigned > 0,
              label: Text(newAssigned > 9 ? '9+' : '$newAssigned'),
              child: const Icon(Icons.local_shipping_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: newAssigned > 0,
              label: Text(newAssigned > 9 ? '9+' : '$newAssigned'),
              child: const Icon(Icons.local_shipping),
            ),
            label: l10n.navOrders,
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
