import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import 'driver_order_details_sheet.dart';
import 'driver_orders_controller.dart';
import 'driver_others_orders_tab.dart';

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DriverOrdersController>();
    final l10n = context.l10n;
    final assigned = controller.assignedOrders;
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
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Newly Assigned'),
                        if (assigned.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Badge(label: Text('${assigned.length}')),
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
              _AssignedOrdersTab(),
              DriverOthersOrdersTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignedOrdersTab extends StatelessWidget {
  const _AssignedOrdersTab();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DriverOrdersController>();
    final assigned = controller.assignedOrders;

    if (assigned.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: const EmptyStateView(
                title: 'No assigned orders',
                subtitle: 'New deliveries from your supervisor will appear here.',
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
        itemCount: assigned.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final order = assigned[index];
          return Card(
            child: ListTile(
              onTap: () => showDriverOrderDetailsSheet(
                context: context,
                order: order,
              ),
              title: Row(
                children: [
                  Expanded(child: Text(order.productName)),
                  Chip(
                    label: Text(order.status.label),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              subtitle: Text(
                [
                  order.customerName,
                  if (order.customerPhone != null) order.customerPhone!,
                  'Qty ${order.quantity}',
                  if (order.estimatedArrivalAt != null)
                    'ETA ${DateTimeFormatter.format(order.estimatedArrivalAt)}',
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
