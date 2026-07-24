import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../routing/customer_routes.dart';
import '../notifications/notifications_bell_button.dart';
import 'orders_controller.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _formatTs(String? value) {
    if (value == null || value.isEmpty) return '—';
    final dt = DateTime.tryParse(value);
    if (dt == null) return value;
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
  }

  void _showDetails(BuildContext context, DeliveryOrder order) {
    showDetailsDialog(
      context: context,
      title: order.productName,
      fields: [
        DetailField(label: 'Status', value: order.status.label),
        DetailField(label: 'Quantity', value: '${order.quantity}'),
        DetailField(
          label: 'Total',
          value: 'Rs ${order.lineTotal.toStringAsFixed(0)}',
        ),
        DetailField(label: 'Payment', value: order.paymentMethod.label),
        DetailField(label: 'Note', value: order.note ?? ''),
        DetailField(label: 'Branch', value: order.branchName ?? order.branchId),
        DetailField(label: 'Rider', value: order.riderName ?? ''),
        DetailField(label: 'ETA', value: _formatTs(order.estimatedArrivalAt)),
        DetailField(label: 'Created', value: _formatTs(order.createdAt)),
        DetailField(label: 'Delivered', value: _formatTs(order.deliveredAt)),
        DetailField(label: 'Address', value: order.deliveryAddress ?? ''),
      ],
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
      body: controller.orders.isEmpty
          ? EmptyStateView(
              title: l10n.noOrdersYet,
              subtitle: l10n.noOrdersSubtitle,
            )
          : ListView.separated(
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
                        _formatTs(order.createdAt),
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
    );
  }
}
