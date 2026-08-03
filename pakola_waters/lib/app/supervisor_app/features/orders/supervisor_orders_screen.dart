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
import '../../../../shared/requests/support_requests_app_bar_button.dart';
import '../../routing/supervisor_routes.dart';

class SupervisorOrdersScreen extends StatelessWidget {
  const SupervisorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupervisorOrdersController>();
    final l10n = context.l10n;
    final requested = controller.requestedOrders;
    final scheduled = controller.scheduledOrders;
    final othersCount = controller.filteredOthersOrders.length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              leading: const SupportRequestsAppBarButton(
                route: SupervisorRoutes.requests,
              ),
              title: Text(l10n.navOrders),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              actions: const [SupervisorNotificationsBellButton()],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.tabRequested),
                        if (requested.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Badge(label: Text('${requested.length}')),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.tabScheduled),
                        if (scheduled.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Badge(label: Text('${scheduled.length}')),
                        ],
                      ],
                    ),
                  ),
                  Tab(text: l10n.tabOthersWithCount(othersCount)),
                ],
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _RequestedOrdersTab(),
              _ScheduledOrdersTab(),
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
    final l10n = context.l10n;
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
              child: EmptyStateView(
                title: l10n.noRequestedOrders,
                subtitle: l10n.noRequestedOrdersSubtitle,
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
                  order.orderType.label,
                  l10n.qtyWithValue(order.quantity),
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

class _ScheduledOrdersTab extends StatelessWidget {
  const _ScheduledOrdersTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<SupervisorOrdersController>();
    final scheduled = controller.scheduledOrders;

    if (scheduled.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: EmptyStateView(
                title: l10n.noScheduledOrders,
                subtitle: l10n.noScheduledOrdersSubtitle,
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
        itemCount: scheduled.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final order = scheduled[index];
          return Card(
            child: ListTile(
              onTap: () => showAssignOrderSheet(context: context, order: order),
              leading: const Icon(Icons.schedule),
              title: Text(order.productName),
              subtitle: Text(
                [
                  order.customerName,
                  l10n.scheduledForLabel(
                    DateTimeFormatter.formatLong(order.scheduledFor),
                  ),
                  l10n.qtyWithValue(order.quantity),
                  'Rs ${order.lineTotal.toStringAsFixed(0)}',
                ].join(' · '),
              ),
              trailing: Chip(
                label: Text(l10n.waiting),
                visualDensity: VisualDensity.compact,
                backgroundColor: context.colors.secondaryContainer,
              ),
            ),
          );
        },
      ),
    );
  }
}
