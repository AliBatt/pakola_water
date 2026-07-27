import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../../routing/customer_routes.dart';
import '../notifications/notifications_bell_button.dart';
import 'orders_controller.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  void _showDetails(BuildContext context, DeliveryOrder order) {
    final controller = context.read<OrdersController>();
    showOrderDetailsSheet(
      context: context,
      order: order,
      
      messagesStream: controller.watchOrderMessages(order.id),
      allowCustomerMessage: order.status.isActive,
      allowReview: order.status == OrderStatus.delivered,
      onSendMessage: (message, type) async {
        final result = await controller.sendOrderMessage(
          order: order,
          message: message,
          type: type,
        );
        switch (result) {
          case Success():
            return const Success(null);
          case FailureResult(:final failure):
            return FailureResult(failure);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdersController>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navOrders),
        actions: const [NotificationsBellButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (controller.hasActiveOrder) {
            AppSnackBar.warning(context, l10n.activeOrderBlock);
            return;
          }
          context.go(CustomerRoutes.products);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newOrder),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: controller.orders.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    child: EmptyStateView(
                      title: l10n.noOrdersYet,
                      subtitle: l10n.noOrdersSubtitle,
                    ),
                  ),
                ],
              )
            : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: controller.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return Card(
                  child: ListTile(
                    onTap: () => _showDetails(context, order),
                    title: Text(order.productName),
                    subtitle: Text(
                      [
                        order.status.label,
                        'Qty ${order.quantity}',
                        'Rs ${order.lineTotal.toStringAsFixed(0)}',
                        DateTimeFormatter.formatLong(order.createdAt),
                      ].join(' · '),
                    ),
                    trailing: Icon(
                      order.status.isActive
                          ? Icons.timelapse
                          : Icons.check_circle_outline,
                      color: order.status.isActive
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
