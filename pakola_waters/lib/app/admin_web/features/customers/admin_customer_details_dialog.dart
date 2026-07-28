import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:utilities/utilities.dart';

import '../../routing/admin_routes.dart';
import '../orders/admin_order_details_dialog.dart';
import '../orders/admin_orders_controller.dart';
import 'admin_customers_controller.dart';

Future<void> showAdminCustomerDetailsDialog({
  required BuildContext context,
  required AppUser customer,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AdminCustomerDetailsDialog(customer: customer),
  );
}

class AdminCustomerDetailsDialog extends StatelessWidget {
  const AdminCustomerDetailsDialog({super.key, required this.customer});

  final AppUser customer;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminCustomersController>();
    final preferred = controller.preferredBranchNames(customer);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.displayName,
                          style: context.texts.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          customer.email,
                          style: context.texts.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(label: Text(customer.status.name)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    _SectionTitle('Profile'),
                    _InfoRow('Phone', customer.phone ?? '—'),
                    _InfoRow('Address', customer.address ?? '—'),
                    _InfoRow('Preferred branch', preferred.join(', ')),
                    if (customer.location != null)
                      _InfoRow(
                        'Coordinates',
                        '${customer.location!.latitude.toStringAsFixed(6)}, '
                        '${customer.location!.longitude.toStringAsFixed(6)}',
                      ),
                    _InfoRow('Customer ID', customer.id),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(child: _SectionTitle('Orders')),
                        TextButton.icon(
                          onPressed: () {
                            final orders =
                                context.read<AdminOrdersController>();
                            orders.setSearch(customer.id);
                            orders.setBranchFilter(null);
                            orders.setStatusFilter(null);
                            Navigator.pop(context);
                            context.go(AdminRoutes.orders);
                          },
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Open in Orders'),
                        ),
                      ],
                    ),
                    StreamBuilder<List<DeliveryOrder>>(
                      stream: controller.watchCustomerOrders(customer.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Could not load orders: ${snapshot.error}',
                            style: TextStyle(color: context.colors.error),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final orders = snapshot.data!;
                        if (orders.isEmpty) {
                          return Text(
                            'No orders yet for this customer.',
                            style: context.texts.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (final order in orders)
                              Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: ListTile(
                                  title: Text(order.productName),
                                  subtitle: Text(
                                    '${order.status.label} · '
                                    '${order.paymentMethod.label} · '
                                    '${order.effectivePaymentStatus.label}\n'
                                    '${DateTimeFormatter.formatLong(order.createdAt)}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Text(
                                    'Rs ${order.lineTotal.toStringAsFixed(0)}',
                                    style: context.texts.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onTap: () {
                                    showAdminOrderDetailsDialog(
                                      context: context,
                                      order: order,
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
