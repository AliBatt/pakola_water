import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:repositories/repositories.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import 'driver_orders_controller.dart';

Future<void> showDriverOrderDetailsSheet({
  required BuildContext context,
  required DeliveryOrder order,
  bool allowActions = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (context) => DriverOrderDetailsSheet(
      orderId: order.id,
      fallbackOrder: order,
      allowActions: allowActions,
    ),
  );
}

class DriverOrderDetailsSheet extends StatelessWidget {
  const DriverOrderDetailsSheet({
    super.key,
    required this.orderId,
    required this.fallbackOrder,
    this.allowActions = true,
  });

  final String orderId;
  final DeliveryOrder fallbackOrder;
  final bool allowActions;

  Future<void> _startDelivery(
    BuildContext context,
    DriverOrdersController controller,
  ) async {
    final result = await controller.markOutForDelivery(orderId);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Marked out for delivery');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  Future<void> _markArrived(
    BuildContext context,
    DriverOrdersController controller,
  ) async {
    final result = await controller.markRiderArrived(orderId);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Marked as arrived');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<DriverOrdersController>();
    final order = controller.orderById(orderId) ?? fallbackOrder;
    final messageRepo = context.read<OrderMessageRepository>();
    final height = MediaQuery.sizeOf(context).height * 0.92;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.back,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    l10n.orderDetails,
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(label: Text(order.status.label)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    order.productName,
                    style: context.texts.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(label: l10n.status, value: order.status.label),
                  _InfoRow(label: l10n.customer, value: order.customerName),
                  _InfoRow(
                    label: l10n.qtyTotal,
                    value:
                        '${order.quantity} · Rs ${order.lineTotal.toStringAsFixed(0)} · ${order.paymentMethod.label}',
                  ),
                  _InfoRow(
                    label: l10n.placed,
                    value: DateTimeFormatter.format(order.createdAt),
                  ),
                  if (order.estimatedArrivalAt != null)
                    _InfoRow(
                      label: l10n.supervisorEta,
                      value: DateTimeFormatter.format(order.estimatedArrivalAt),
                    ),
                  if (order.supervisorName != null)
                    _InfoRow(label: l10n.supervisor, value: order.supervisorName!),
                  if (order.note != null && order.note!.isNotEmpty)
                    _InfoRow(label: l10n.note, value: order.note!),
                  const Divider(height: AppSpacing.xl),
                  DeliveryContactSection(order: order),
                  if (allowActions) ...[
                    const SizedBox(height: AppSpacing.lg),
                    if (order.status == OrderStatus.assigned)
                      FilledButton.icon(
                        onPressed: controller.isUpdating
                            ? null
                            : () => _startDelivery(context, controller),
                        icon: controller.isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.local_shipping_outlined),
                        label: Text(l10n.startDelivery),
                      )
                    else if (order.status == OrderStatus.outForDelivery)
                      FilledButton.icon(
                        onPressed: controller.isUpdating
                            ? null
                            : () => _markArrived(context, controller),
                        icon: controller.isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.place_outlined),
                        label: Text(l10n.markArrived),
                      )
                    else if (order.status == OrderStatus.riderArrived)
                      Text(
                        l10n.waitingCustomerConfirm,
                        style: context.texts.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                  const Divider(height: AppSpacing.xl),
                  Text(
                    'Messages',
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  StreamBuilder<List<OrderMessage>>(
                    stream: messageRepo.watchMessages(order.id),
                    builder: (context, snapshot) {
                      final messages = snapshot.data ?? [];
                      if (messages.isEmpty) {
                        return Text(
                          'No messages yet.',
                          style: context.texts.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        );
                      }
                      return Column(
                        children: messages.map((message) {
                          return Card(
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              title: Text(message.message),
                              subtitle: Text(
                                '${message.createdByName} · ${message.type.label}'
                                '${message.createdAt != null ? ' · ${DateTimeFormatter.format(message.createdAt)}' : ''}',
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
            width: 120,
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
