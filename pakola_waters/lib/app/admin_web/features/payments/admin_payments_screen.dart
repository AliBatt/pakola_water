import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../../../../shared/orders/others_date_preset.dart';
import 'admin_payments_controller.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPaymentsController>().bind();
    });
  }

  Future<void> _pickCustomRange(AdminPaymentsController controller) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: controller.customRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      controller.setCustomRange(
        DateTimeRange(
          start: picked.start.copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
          end: picked.end.copyWith(
            hour: 23,
            minute: 59,
            second: 59,
            millisecond: 999,
            microsecond: 999,
          ),
        ),
      );
    }
  }

  Future<void> _messageCustomer(DeliveryOrder order) async {
    final titleController = TextEditingController(
      text: 'Payment reminder',
    );
    final bodyController = TextEditingController(
      text:
          'Hi ${order.customerName}, please settle your credit payment of Rs ${order.lineTotal.toStringAsFixed(0)} for order ${order.productName}.',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notify customer'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Send a payment reminder to ${order.customerName}.',
                style: context.texts.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: titleController,
                labelText: 'Title',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: bodyController,
                labelText: 'Message',
                maxLines: 4,
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send notification'),
          ),
        ],
      ),
    );

    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    titleController.dispose();
    bodyController.dispose();

    if (confirmed != true || !mounted) return;
    if (title.isEmpty || body.isEmpty) {
      AppSnackBar.warning(context, 'Title and message are required');
      return;
    }

    final sender = context.read<AuthProvider>().user;
    if (sender == null) return;

    final result = await context.read<AdminPaymentsController>().notifyPaymentDue(
          order: order,
          sender: sender,
          title: title,
          body: body,
        );
    if (!mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Payment reminder sent');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  Future<void> _markPaid(DeliveryOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark payment as paid?'),
        content: Text(
          'Confirm that ${order.customerName} has paid Rs ${order.lineTotal.toStringAsFixed(0)} for this credit order.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark paid'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result =
        await context.read<AdminPaymentsController>().markPaid(order);
    if (!mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Marked as paid');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminPaymentsController>();

    if (controller.isLoading) {
      return const LoadingView(message: 'Loading payments...');
    }

    final orders = controller.filteredOrders;

    return Padding(
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
                      'Payments',
                      style: context.texts.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Track COD and credit payments. Remind unpaid credit customers.',
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _SummaryChip(
                label: 'Showing',
                value: '${controller.totalCount}',
              ),
              _SummaryChip(
                label: 'COD',
                value: '${controller.codCount}',
                color: context.colors.primaryContainer,
              ),
              _SummaryChip(
                label: 'Credit',
                value: '${controller.creditCount}',
                color: context.colors.secondaryContainer,
              ),
              _SummaryChip(
                label: 'Paid',
                value:
                    '${controller.paidCount} · Rs ${controller.paidRevenue.toStringAsFixed(0)}',
                color: AppColors.success.withValues(alpha: 0.15),
              ),
              _SummaryChip(
                label: 'Unpaid credit',
                value:
                    '${controller.unpaidCreditCount} · Rs ${controller.unpaidCreditRevenue.toStringAsFixed(0)}',
                color: context.colors.errorContainer,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            labelText: 'Search customer, phone, product, order…',
            prefix: const Icon(Icons.search),
            onChanged: controller.setSearch,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: const Text('All methods'),
                selected: controller.methodFilter == null &&
                    !controller.unpaidCreditOnly,
                onSelected: (_) {
                  controller.setUnpaidCreditOnly(false);
                  controller.setMethodFilter(null);
                },
              ),
              FilterChip(
                label: const Text('COD'),
                selected: controller.methodFilter == PaymentMethod.cod &&
                    !controller.unpaidCreditOnly,
                onSelected: (_) {
                  controller.setUnpaidCreditOnly(false);
                  controller.setMethodFilter(PaymentMethod.cod);
                },
              ),
              FilterChip(
                label: const Text('Credit'),
                selected: controller.methodFilter == PaymentMethod.credit &&
                    !controller.unpaidCreditOnly,
                onSelected: (_) {
                  controller.setUnpaidCreditOnly(false);
                  controller.setMethodFilter(PaymentMethod.credit);
                },
              ),
              FilterChip(
                label: const Text('Paid'),
                selected: controller.statusFilter == PaymentStatus.paid &&
                    !controller.unpaidCreditOnly,
                onSelected: (_) {
                  controller.setUnpaidCreditOnly(false);
                  controller.setStatusFilter(
                    controller.statusFilter == PaymentStatus.paid
                        ? null
                        : PaymentStatus.paid,
                  );
                },
              ),
              FilterChip(
                label: const Text('Unpaid'),
                selected:
                    controller.statusFilter == PaymentStatus.pending &&
                        !controller.unpaidCreditOnly,
                onSelected: (_) {
                  controller.setUnpaidCreditOnly(false);
                  controller.setStatusFilter(
                    controller.statusFilter == PaymentStatus.pending
                        ? null
                        : PaymentStatus.pending,
                  );
                },
              ),
              FilterChip(
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: controller.unpaidCreditOnly
                      ? context.colors.onErrorContainer
                      : context.colors.error,
                ),
                label: const Text('Unpaid credit'),
                selected: controller.unpaidCreditOnly,
                selectedColor: context.colors.errorContainer,
                onSelected: controller.setUnpaidCreditOnly,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: OthersDatePreset.values.map((preset) {
                final selected = controller.datePreset == preset;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(
                      preset == OthersDatePreset.custom &&
                              controller.customRange != null
                          ? DateTimeFormatter.formatRange(
                              controller.customRange!.start,
                              controller.customRange!.end,
                            )
                          : preset.label,
                    ),
                    selected: selected,
                    onSelected: (_) {
                      if (preset == OthersDatePreset.custom) {
                        _pickCustomRange(controller);
                      } else {
                        controller.setDatePreset(preset);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: orders.isEmpty
                ? EmptyStateView(
                    icon: Icons.payments_outlined,
                    title: 'No payments found',
                    subtitle: 'Try changing search or filters.',
                  )
                : Card(
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        if (!wide) {
                          return ListView.separated(
                            itemCount: orders.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return ListTile(
                                title: Text(order.customerName),
                                subtitle: Text(
                                  '${order.paymentMethod.label} · ${order.effectivePaymentStatus.label}\n'
                                  '${order.productName} · ${order.status.label}\n'
                                  '${DateTimeFormatter.formatLong(order.createdAt)}',
                                ),
                                isThreeLine: true,
                                trailing: _PaymentActions(
                                  order: order,
                                  acting: controller.isActing,
                                  onMessage: () => _messageCustomer(order),
                                  onMarkPaid: () => _markPaid(order),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: order.isUnpaidCredit
                                      ? context.colors.errorContainer
                                      : order.effectivePaymentStatus.isPaid
                                          ? AppColors.success
                                              .withValues(alpha: 0.2)
                                          : context.colors.surfaceContainerHighest,
                                  child: Text(
                                    'Rs\n${order.lineTotal.toStringAsFixed(0)}',
                                    textAlign: TextAlign.center,
                                    style: context.texts.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Customer')),
                                  DataColumn(label: Text('Method')),
                                  DataColumn(label: Text('Payment')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Order status')),
                                  DataColumn(label: Text('Placed')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: [
                                  for (final order in orders)
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                order.customerName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                order.customerPhone ?? order.id,
                                                style: context.texts.bodySmall
                                                    ?.copyWith(
                                                  color: context
                                                      .colors.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Chip(
                                            label: Text(
                                              order.paymentMethod.label,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        DataCell(
                                          Chip(
                                            label: Text(
                                              order.effectivePaymentStatus.label,
                                            ),
                                            backgroundColor:
                                                order.effectivePaymentStatus.isPaid
                                                    ? AppColors.success
                                                        .withValues(alpha: 0.15)
                                                    : context
                                                        .colors.errorContainer,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            'Rs ${order.lineTotal.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(order.status.label)),
                                        DataCell(
                                          Text(
                                            DateTimeFormatter.format(
                                              order.createdAt,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          _PaymentActions(
                                            order: order,
                                            acting: controller.isActing,
                                            onMessage: () =>
                                                _messageCustomer(order),
                                            onMarkPaid: () =>
                                                _markPaid(order),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaymentActions extends StatelessWidget {
  const _PaymentActions({
    required this.order,
    required this.acting,
    required this.onMessage,
    required this.onMarkPaid,
  });

  final DeliveryOrder order;
  final bool acting;
  final VoidCallback onMessage;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    if (order.blocksPaymentActions) {
      return Text(
        order.status == OrderStatus.cancelled
            ? 'Cancelled · Unpaid'
            : '${order.status.label} · no payment action',
        style: context.texts.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      );
    }

    if (!order.isUnpaidCredit) {
      return Text(
        order.effectivePaymentStatus.label,
        style: context.texts.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Message customer',
          onPressed: acting ? null : onMessage,
          icon: const Icon(Icons.notifications_active_outlined),
        ),
        TextButton(
          onPressed: acting ? null : onMarkPaid,
          child: const Text('Mark paid'),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color,
      label: Text('$label: $value'),
    );
  }
}
