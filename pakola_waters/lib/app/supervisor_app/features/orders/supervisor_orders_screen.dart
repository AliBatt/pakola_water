import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import 'assign_order_sheet.dart';
import '../notifications/supervisor_notifications_bell_button.dart';
import 'others_orders_tab.dart';
import 'supervisor_orders_controller.dart';

class SupervisorOrdersScreen extends StatelessWidget {
  const SupervisorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupervisorOrdersController>();
    final l10n = context.l10n;
    final requested = controller.requestedOrders;
    final othersCount = controller.filteredOthersOrders.length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              title: Text(l10n.navOrders),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              actions: const [SupervisorNotificationsBellButton()],
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Requested'),
                        if (requested.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Badge(label: Text('${requested.length}')),
                        ],
                      ],
                    ),
                  ),
                  Tab(text: 'Others ($othersCount)'),
                ],
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _RequestedOrdersTab(),
              OthersOrdersTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestedOrdersTab extends StatelessWidget {
  const _RequestedOrdersTab();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupervisorOrdersController>();
    final requested = controller.requestedOrders;

    if (requested.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: const EmptyStateView(
                title: 'No requested orders',
                subtitle: 'New customer orders will appear here.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: requested.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final order = requested[index];
          return Card(
            child: ListTile(
              onTap: () => showAssignOrderSheet(context: context, order: order),
              title: Text(order.productName),
              subtitle: Text(
                [
                  order.customerName,
                  'Qty ${order.quantity}',
                  'Rs ${order.lineTotal.toStringAsFixed(0)}',
                  order.status.label,
                  DateTimeFormatter.format(order.createdAt),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
