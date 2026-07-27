import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:models/models.dart';
import 'package:utilities/utilities.dart';

import 'app_snackbar.dart';
import 'order_timestamp_formatter.dart';

export 'order_timestamp_formatter.dart';

Future<void> showDeliveryOrderDetailsSheet({
  required BuildContext context,
  required DeliveryOrder order,
  OrderTimestampFormatter formatTs = DateTimeFormatter.format,
  List<Widget>? actionButtons,
  Stream<List<OrderMessage>>? messagesStream,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DeliveryOrderDetailsSheet(
      order: order,
      formatTs: formatTs,
      actionButtons: actionButtons,
      messagesStream: messagesStream,
    ),
  );
}

class DeliveryOrderDetailsSheet extends StatelessWidget {
  const DeliveryOrderDetailsSheet({
    super.key,
    required this.order,
    this.formatTs = DateTimeFormatter.format,
    this.actionButtons,
    this.messagesStream,
  });

  final DeliveryOrder order;
  final OrderTimestampFormatter formatTs;
  final List<Widget>? actionButtons;
  final Stream<List<OrderMessage>>? messagesStream;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.productName,
                    style: context.texts.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(label: Text(order.status.label)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(label: 'Customer', value: order.customerName),
            _InfoRow(
              label: 'Qty / Total',
              value:
                  '${order.quantity} · Rs ${order.lineTotal.toStringAsFixed(0)} · ${order.paymentMethod.label}',
            ),
            _InfoRow(label: 'Placed', value: formatTs(order.createdAt)),
            if (order.estimatedArrivalAt != null)
              _InfoRow(
                label: 'Supervisor ETA',
                value: formatTs(order.estimatedArrivalAt),
              ),
            if (order.riderName != null)
              _InfoRow(label: 'Rider', value: order.riderName!),
            if (order.supervisorName != null)
              _InfoRow(label: 'Supervisor', value: order.supervisorName!),
            if (order.note != null && order.note!.isNotEmpty)
              _InfoRow(label: 'Note', value: order.note!),
            const Divider(height: AppSpacing.xl),
            DeliveryContactSection(order: order),
            if (actionButtons != null && actionButtons!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ...actionButtons!,
            ],
            if (messagesStream != null) ...[
              const Divider(height: AppSpacing.xl),
              Text(
                'Messages',
                style: context.texts.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<List<OrderMessage>>(
                stream: messagesStream,
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
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          title: Text(message.message),
                          subtitle: Text(
                            '${message.createdByName} · ${message.type.label}'
                            '${message.createdAt != null ? ' · ${formatTs(message.createdAt)}' : ''}',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DeliveryContactSection extends StatelessWidget {
  const DeliveryContactSection({super.key, required this.order});

  final DeliveryOrder order;

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      AppSnackBar.success(context, '$label copied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = order.deliveryLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Delivery contact',
          style: context.texts.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (order.customerPhone != null && order.customerPhone!.isNotEmpty)
          _CopyableRow(
            label: 'Phone',
            value: order.customerPhone!,
            onCopy: () => _copy(context, 'Phone', order.customerPhone!),
          ),
        if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty)
          _CopyableRow(
            label: 'Address',
            value: order.deliveryAddress!,
            onCopy: () => _copy(context, 'Address', order.deliveryAddress!),
          ),
        if (location != null) ...[
          _CopyableRow(
            label: 'Latitude',
            value: location.latitude.toString(),
            onCopy: () =>
                _copy(context, 'Latitude', location.latitude.toString()),
          ),
          _CopyableRow(
            label: 'Longitude',
            value: location.longitude.toString(),
            onCopy: () =>
                _copy(context, 'Longitude', location.longitude.toString()),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _copy(
              context,
              'Coordinates',
              '${location.latitude}, ${location.longitude}',
            ),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy lat, lng'),
          ),
        ],
      ],
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

class _CopyableRow extends StatelessWidget {
  const _CopyableRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

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
            child: SelectableText(
              value,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy $label',
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
    );
  }
}
