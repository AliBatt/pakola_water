import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:utilities/utilities.dart';

import 'app_snackbar.dart';
import 'app_text_field.dart';
import 'order_timestamp_formatter.dart';

Future<void> showOrderDetailsSheet({
  required BuildContext context,
  required DeliveryOrder order,
  OrderTimestampFormatter formatTs = DateTimeFormatter.format,
  Stream<List<OrderMessage>>? messagesStream,
  bool allowCustomerMessage = false,
  bool allowReview = false,
  Future<Result<void>> Function(String message, OrderMessageType type)? onSendMessage,
  bool allowStaffMessage = false,
  Future<Result<void>> Function(String message)? onStaffMessage,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (context) => OrderDetailsSheet(
      order: order,
      formatTs: formatTs,
      messagesStream: messagesStream,
      allowCustomerMessage: allowCustomerMessage,
      allowReview: allowReview,
      onSendMessage: onSendMessage,
      allowStaffMessage: allowStaffMessage,
      onStaffMessage: onStaffMessage,
    ),
  );
}

class OrderDetailsSheet extends StatefulWidget {
  const OrderDetailsSheet({
    super.key,
    required this.order,
    this.formatTs = DateTimeFormatter.format,
    this.messagesStream,
    this.allowCustomerMessage = false,
    this.allowReview = false,
    this.onSendMessage,
    this.allowStaffMessage = false,
    this.onStaffMessage,
  });

  final DeliveryOrder order;
  final OrderTimestampFormatter formatTs;
  final Stream<List<OrderMessage>>? messagesStream;
  final bool allowCustomerMessage;
  final bool allowReview;
  final Future<Result<void>> Function(String message, OrderMessageType type)?
      onSendMessage;
  final bool allowStaffMessage;
  final Future<Result<void>> Function(String message)? onStaffMessage;

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send(OrderMessageType type) async {
    final onSend = type == OrderMessageType.staffMessage
        ? null
        : widget.onSendMessage;
    final onStaff = widget.onStaffMessage;

    if (type == OrderMessageType.staffMessage) {
      if (onStaff == null) return;
    } else if (onSend == null) {
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) {
      AppSnackBar.warning(context, 'Enter a message');
      return;
    }

    setState(() => _sending = true);
    final result = type == OrderMessageType.staffMessage
        ? await onStaff!(text)
        : await onSend!(text, type);
    if (!mounted) return;
    setState(() => _sending = false);

    switch (result) {
      case Success():
        _messageController.clear();
        if (type == OrderMessageType.review) {
          AppSnackBar.success(context, 'Review submitted');
          Navigator.pop(context);
        } else {
          AppSnackBar.success(context, 'Message sent');
        }
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
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
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    'Order details',
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(
                  label: Text(order.status.label),
                  backgroundColor: context.colors.primaryContainer,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg + bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    order.productName,
                    style: context.texts.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(label: 'Customer', value: order.customerName),
                  if (order.customerPhone != null)
                    _InfoRow(label: 'Phone', value: order.customerPhone!),
                  _InfoRow(
                    label: 'Branch',
                    value: order.branchName ?? order.branchId,
                  ),
                  _InfoRow(
                    label: 'Quantity',
                    value:
                        '${order.quantity} × Rs ${order.unitPrice.toStringAsFixed(0)}',
                  ),
                  _InfoRow(
                    label: 'Total',
                    value:
                        'Rs ${order.lineTotal.toStringAsFixed(0)} · ${order.paymentMethod.label}',
                  ),
                  _InfoRow(
                    label: 'Placed',
                    value: widget.formatTs(order.createdAt),
                  ),
                  _InfoRow(
                    label: 'Supervisor ETA',
                    value: order.estimatedArrivalAt == null
                        ? 'Not set'
                        : widget.formatTs(order.estimatedArrivalAt),
                  ),
                  if (order.riderName != null)
                    _InfoRow(label: 'Rider', value: order.riderName!),
                  if (order.note != null && order.note!.isNotEmpty)
                    _InfoRow(label: 'Note', value: order.note!),
                  if (order.deliveryAddress != null)
                    _InfoRow(label: 'Address', value: order.deliveryAddress!),
                  const Divider(height: AppSpacing.xl),
                  Text(
                    'Messages',
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (widget.messagesStream != null)
                    StreamBuilder<List<OrderMessage>>(
                      stream: widget.messagesStream,
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
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: ListTile(
                                title: Text(message.message),
                                subtitle: Text(
                                  '${message.createdByName} · ${message.type.label}'
                                  '${message.createdAt != null ? ' · ${widget.formatTs(message.createdAt)}' : ''}',
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  else
                    Text(
                      'Messages unavailable.',
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  if (widget.allowCustomerMessage ||
                      widget.allowReview ||
                      widget.allowStaffMessage) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _messageController,
                      labelText: widget.allowReview && !widget.allowCustomerMessage
                          ? 'Write a review'
                          : 'Write a message',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (widget.allowCustomerMessage) ...[
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ActionChip(
                            label: const Text('Please hurry up'),
                            onPressed: _sending
                                ? null
                                : () {
                                    _messageController.text = 'Please hurry up';
                                    _send(OrderMessageType.customerMessage);
                                  },
                          ),
                          ActionChip(
                            label: const Text('Where is my order?'),
                            onPressed: _sending
                                ? null
                                : () {
                                    _messageController.text =
                                        'Where is my order?';
                                    _send(OrderMessageType.customerMessage);
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton(
                        onPressed: _sending
                            ? null
                            : () => _send(OrderMessageType.customerMessage),
                        child: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Send message'),
                      ),
                    ],
                    if (widget.allowReview) ...[
                      if (widget.allowCustomerMessage)
                        const SizedBox(height: AppSpacing.sm),
                      FilledButton(
                        onPressed: _sending
                            ? null
                            : () => _send(OrderMessageType.review),
                        child: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Submit review'),
                      ),
                    ],
                    if (widget.allowStaffMessage)
                      FilledButton.icon(
                        onPressed: _sending
                            ? null
                            : () => _send(OrderMessageType.staffMessage),
                        icon: const Icon(Icons.send),
                        label: const Text('Send to customer'),
                      ),
                  ],
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
