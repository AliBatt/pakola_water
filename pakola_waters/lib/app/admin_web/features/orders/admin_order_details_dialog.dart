import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:repositories/repositories.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import 'admin_orders_controller.dart';

Future<void> showAdminOrderDetailsDialog({
  required BuildContext context,
  required DeliveryOrder order,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AdminOrderDetailsDialog(order: order),
  );
}

class AdminOrderDetailsDialog extends StatefulWidget {
  const AdminOrderDetailsDialog({super.key, required this.order});

  final DeliveryOrder order;

  @override
  State<AdminOrderDetailsDialog> createState() =>
      _AdminOrderDetailsDialogState();
}

class _AdminOrderDetailsDialogState extends State<AdminOrderDetailsDialog> {
  late final TextEditingController _notesController;
  late final TextEditingController _reasonController;
  late final TextEditingController _messageController;
  bool _savingNotes = false;
  bool _sendingMessage = false;

  DeliveryOrder get order {
    for (final o in context.watch<AdminOrdersController>().orders) {
      if (o.id == widget.order.id) return o;
    }
    return widget.order;
  }

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.order.adminNotes ?? '');
    _reasonController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _duration(Duration? value) => value?.shortLabel ?? '—';

  Future<void> _markComplete() async {
    final admin = context.read<AuthProvider>().user;
    if (admin == null) return;

    final notes = await _promptNotes(
      title: 'Mark order complete',
      subtitle: 'Optional admin notes will be saved with this action.',
      requireReason: false,
    );
    if (notes == null || !mounted) return;

    final result = await context.read<AdminOrdersController>().markDelivered(
          order: order,
          admin: admin,
          adminNotes: notes.isEmpty ? null : notes,
        );
    if (!mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Order marked as delivered');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  Future<void> _markFailed() async {
    final admin = context.read<AuthProvider>().user;
    if (admin == null) return;

    final result = await _promptNotes(
      title: 'Mark order failed',
      subtitle: 'A failure reason is required.',
      requireReason: true,
    );
    if (result == null || !mounted) return;

    final parts = result.split('\n---\n');
    final reason = parts.first;
    final notes = parts.length > 1 ? parts[1] : '';

    final action = await context.read<AdminOrdersController>().markFailed(
          order: order,
          admin: admin,
          failureReason: reason,
          adminNotes: notes.isEmpty ? null : notes,
        );
    if (!mounted) return;
    switch (action) {
      case Success():
        AppSnackBar.success(context, 'Order marked as failed');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  Future<String?> _promptNotes({
    required String title,
    required String subtitle,
    required bool requireReason,
  }) async {
    _reasonController.clear();
    final notesSeed = _notesController.text;
    final tempNotes = TextEditingController(text: notesSeed);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(subtitle),
              if (requireReason) ...[
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _reasonController,
                  labelText: 'Failure reason *',
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: tempNotes,
                labelText: 'Admin notes (optional)',
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (requireReason && _reasonController.text.trim().isEmpty) {
                AppSnackBar.warning(context, 'Enter a failure reason');
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      tempNotes.dispose();
      return null;
    }

    final notes = tempNotes.text.trim();
    tempNotes.dispose();
    if (requireReason) {
      return '${_reasonController.text.trim()}\n---\n$notes';
    }
    return notes;
  }

  Future<void> _saveNotes() async {
    setState(() => _savingNotes = true);
    final result = await context.read<AdminOrdersController>().saveNotes(
          order: order,
          adminNotes: _notesController.text,
        );
    if (!mounted) return;
    setState(() => _savingNotes = false);
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Notes saved');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  Future<void> _sendCustomerMessage() async {
    final admin = context.read<AuthProvider>().user;
    if (admin == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      AppSnackBar.warning(context, 'Enter a message');
      return;
    }

    setState(() => _sendingMessage = true);
    final result = await context.read<OrderMessageRepository>().sendStaffMessage(
          order: order,
          sender: admin,
          message: text,
          recipientUserId: order.customerId,
        );
    if (!mounted) return;
    setState(() => _sendingMessage = false);
    switch (result) {
      case Success():
        _messageController.clear();
        AppSnackBar.success(context, 'Message sent to customer');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  List<_LifecycleStep> _lifecycleSteps(
    DeliveryOrder current,
    String supervisorName,
  ) {
    final status = current.status;
    final reachedOutForDelivery = status == OrderStatus.outForDelivery ||
        status == OrderStatus.riderArrived ||
        status == OrderStatus.delivered ||
        (status == OrderStatus.failed &&
            (current.outForDeliveryAt != null ||
                current.riderArrivedAt != null));
    final reachedArrived = status == OrderStatus.riderArrived ||
        status == OrderStatus.delivered ||
        (status == OrderStatus.failed && current.riderArrivedAt != null);

    final assignDetail = <String>[
      if (current.riderName != null) 'Rider: ${current.riderName}',
      if (supervisorName != '—') 'By: $supervisorName',
      if (current.estimatedArrivalAt != null)
        'ETA: ${DateTimeFormatter.formatLong(current.estimatedArrivalAt)}',
    ].join(' · ');

    return [
      _LifecycleStep(
        title: 'Order placed by customer',
        detail: current.customerName,
        timestamp: current.createdAt,
        done: true,
        icon: Icons.shopping_bag_outlined,
      ),
      _LifecycleStep(
        title: 'Supervisor notified',
        detail: current.branchName ?? current.branchId,
        timestamp: current.supervisorNotifiedAt,
        done: current.supervisorNotifiedAt != null ||
            status.index >= OrderStatus.supervisorNotified.index,
        icon: Icons.campaign_outlined,
      ),
      _LifecycleStep(
        title: 'Assigned to rider',
        detail: assignDetail.isEmpty ? null : assignDetail,
        timestamp: current.assignedAt,
        done: current.assignedAt != null ||
            status.index >= OrderStatus.assigned.index,
        icon: Icons.person_pin_circle_outlined,
      ),
      _LifecycleStep(
        title: 'Out for delivery',
        detail: current.riderName,
        timestamp: current.outForDeliveryAt,
        done: current.outForDeliveryAt != null || reachedOutForDelivery,
        icon: Icons.local_shipping_outlined,
      ),
      _LifecycleStep(
        title: 'Rider arrived',
        detail: current.riderName,
        timestamp: current.riderArrivedAt,
        done: current.riderArrivedAt != null || reachedArrived,
        icon: Icons.location_on_outlined,
      ),
      if (status == OrderStatus.failed)
        _LifecycleStep(
          title: 'Marked failed',
          detail: current.failureReason ??
              (current.adminActionByName != null
                  ? 'By ${current.adminActionByName}'
                  : null),
          timestamp: current.failedAt,
          done: true,
          icon: Icons.cancel_outlined,
          isError: true,
        )
      else
        _LifecycleStep(
          title: 'Customer confirmed delivery',
          detail: current.adminActionByName != null
              ? 'Confirmed / closed by ${current.adminActionByName}'
              : current.customerName,
          timestamp: current.deliveredAt,
          done: status == OrderStatus.delivered,
          icon: Icons.check_circle_outline,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminOrdersController>();
    final current = order;
    final canAct = current.status.isActive;
    final location = current.deliveryLocation;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 860),
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
                          current.productName,
                          style: context.texts.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Order ${current.id}',
                          style: context.texts.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(label: Text(current.status.label)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListView(
                        children: [
                          _SectionTitle('Order summary'),
                          _InfoRow('Customer', current.customerName),
                          _InfoRow('Phone', current.customerPhone ?? '—'),
                          _InfoRow(
                            'Branch',
                            current.branchName ?? current.branchId,
                          ),
                          _InfoRow(
                            'Qty / Total',
                            '${current.quantity} · Rs ${current.lineTotal.toStringAsFixed(0)} · ${current.paymentMethod.label}',
                          ),
                          _InfoRow(
                            'Address',
                            current.deliveryAddress ?? '—',
                          ),
                          if (location != null)
                            _InfoRow(
                              'Coordinates',
                              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                            ),
                          if (current.note != null && current.note!.isNotEmpty)
                            _InfoRow('Customer note', current.note!),
                          const SizedBox(height: AppSpacing.md),
                          _SectionTitle('People'),
                          _InfoRow(
                            'Supervisor',
                            controller.supervisorNameFor(current),
                          ),
                          _InfoRow('Rider', current.riderName ?? 'Not assigned'),
                          if (current.adminActionByName != null)
                            _InfoRow(
                              'Admin action by',
                              current.adminActionByName!,
                            ),
                          const SizedBox(height: AppSpacing.md),
                          _SectionTitle('Full lifecycle'),
                          Builder(
                            builder: (context) {
                              final steps = _lifecycleSteps(
                                current,
                                controller.supervisorNameFor(current),
                              );
                              return Column(
                                children: [
                                  for (var i = 0; i < steps.length; i++)
                                    _LifecycleTile(
                                      step: steps[i],
                                      isLast: i == steps.length - 1,
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SectionTitle('Performance'),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _MetricChip(
                                label: 'Supervisor to assign',
                                value: _duration(
                                  current.supervisorAssignDuration,
                                ),
                              ),
                              _MetricChip(
                                label: 'Rider to deliver',
                                value: _duration(current.riderDeliveryDuration),
                              ),
                              _MetricChip(
                                label: 'Customer to confirm',
                                value: _duration(
                                  current.customerConfirmDuration,
                                ),
                              ),
                              _MetricChip(
                                label: 'Total order time',
                                value: _duration(current.totalOrderDuration),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          StreamBuilder<List<OrderMessage>>(
                            stream: context
                                .read<OrderMessageRepository>()
                                .watchMessages(current.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Could not load messages: ${snapshot.error}',
                                  style: context.texts.bodyMedium?.copyWith(
                                    color: context.colors.error,
                                  ),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final messages = snapshot.data!;
                              final customerMessages = messages
                                  .where(
                                    (m) =>
                                        m.type ==
                                        OrderMessageType.customerMessage,
                                  )
                                  .toList();
                              final reviews = messages
                                  .where(
                                    (m) => m.type == OrderMessageType.review,
                                  )
                                  .toList();
                              final staffMessages = messages
                                  .where(
                                    (m) =>
                                        m.type == OrderMessageType.staffMessage,
                                  )
                                  .toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SectionTitle(
                                    'Customer messages (${customerMessages.length})',
                                  ),
                                  if (customerMessages.isEmpty)
                                    const _EmptyHint(
                                      'No customer messages during this order.',
                                    )
                                  else
                                    ...customerMessages.map(
                                      (m) => _MessageCard(message: m),
                                    ),
                                  const SizedBox(height: AppSpacing.md),
                                  _SectionTitle(
                                    'Customer reviews (${reviews.length})',
                                  ),
                                  if (reviews.isEmpty)
                                    const _EmptyHint(
                                      'No reviews submitted yet.',
                                    )
                                  else
                                    ...reviews.map(
                                      (m) => _MessageCard(message: m),
                                    ),
                                  const SizedBox(height: AppSpacing.md),
                                  _SectionTitle(
                                    'Staff messages (${staffMessages.length})',
                                  ),
                                  if (staffMessages.isEmpty)
                                    const _EmptyHint(
                                      'No staff messages yet.',
                                    )
                                  else
                                    ...staffMessages.map(
                                      (m) => _MessageCard(message: m),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 2,
                      child: ListView(
                        children: [
                          _SectionTitle('Admin actions'),
                          if (canAct) ...[
                            FilledButton.icon(
                              onPressed:
                                  controller.isActing ? null : _markComplete,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Mark complete'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            OutlinedButton.icon(
                              onPressed:
                                  controller.isActing ? null : _markFailed,
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: context.colors.error,
                              ),
                              label: Text(
                                'Mark failed',
                                style: TextStyle(color: context.colors.error),
                              ),
                            ),
                          ] else
                            Text(
                              'This order is already closed (${current.status.label}).',
                              style: context.texts.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: AppSpacing.lg),
                          _SectionTitle('Manual notes'),
                          AppTextField(
                            controller: _notesController,
                            labelText: 'Admin notes',
                            maxLines: 4,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: _savingNotes ? null : _saveNotes,
                              child: _savingNotes
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save notes'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _SectionTitle('Message customer'),
                          AppTextField(
                            controller: _messageController,
                            labelText: 'Message',
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.tonalIcon(
                              onPressed:
                                  _sendingMessage ? null : _sendCustomerMessage,
                              icon: const Icon(Icons.send),
                              label: const Text('Send'),
                            ),
                          ),
                        ],
                      ),
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

class _LifecycleStep {
  const _LifecycleStep({
    required this.title,
    required this.done,
    required this.icon,
    this.detail,
    this.timestamp,
    this.isError = false,
  });

  final String title;
  final String? detail;
  final String? timestamp;
  final bool done;
  final IconData icon;
  final bool isError;
}

class _LifecycleTile extends StatelessWidget {
  const _LifecycleTile({required this.step, required this.isLast});

  final _LifecycleStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = !step.done
        ? context.colors.outlineVariant
        : step.isError
            ? context.colors.error
            : AppColors.success;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: step.done
                        ? color.withValues(alpha: 0.15)
                        : context.colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(color: color),
                  ),
                  child: Icon(
                    step.done
                        ? (step.isError ? Icons.close : Icons.check)
                        : step.icon,
                    size: 16,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: step.done
                          ? color.withValues(alpha: 0.4)
                          : context.colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: context.texts.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: step.done
                          ? context.colors.onSurface
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                  if (step.detail != null && step.detail!.isNotEmpty)
                    Text(
                      step.detail!,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    step.timestamp != null
                        ? DateTimeFormatter.formatLong(step.timestamp)
                        : (step.done ? 'Completed (time not recorded)' : 'Pending'),
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
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

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final OrderMessage message;

  @override
  Widget build(BuildContext context) {
    final accent = switch (message.type) {
      OrderMessageType.review => AppColors.warning,
      OrderMessageType.staffMessage => AppColors.info,
      OrderMessageType.customerMessage => context.colors.primary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    message.type.label,
                    style: context.texts.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  message.createdAt != null
                      ? DateTimeFormatter.formatLong(message.createdAt)
                      : '—',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message.message,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.createdByName} · ${message.createdByRole}',
              style: context.texts.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: context.texts.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
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
            width: 150,
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.texts.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
