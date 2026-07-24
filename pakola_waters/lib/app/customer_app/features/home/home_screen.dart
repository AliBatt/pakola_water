import 'dart:async';

import 'package:core/core.dart';
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
import '../orders/orders_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _confirmDelivery(DeliveryOrder order) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeliveryTitle),
        content: Text(l10n.confirmDeliveryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result =
        await context.read<OrdersController>().confirmDelivery(order.id);
    if (!mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, l10n.orderCompleted);
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  String _elapsed(DeliveryOrder order) {
    final created = DateTime.tryParse(order.createdAt ?? '');
    if (created == null) return '—';
    final diff = DateTime.now().difference(created);
    if (diff.inHours >= 1) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m';
  }

  String _formatTs(String? value) {
    if (value == null || value.isEmpty) return '—';
    final dt = DateTime.tryParse(value);
    if (dt == null) return value;
    return DateFormat('dd MMM, hh:mm a').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrdersController>();
    final order = controller.activeOrder;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: const [NotificationsBellButton()],
      ),
      body: order == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 56,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.noOngoingOrder,
                      style: context.texts.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.noOngoingOrderSubtitle,
                      textAlign: TextAlign.center,
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => context.go(CustomerRoutes.products),
                      child: Text(l10n.browseProducts),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  l10n.ongoingOrder,
                  style: context.texts.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: context.texts.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Qty ${order.quantity} · Rs ${order.lineTotal.toStringAsFixed(0)} · ${order.paymentMethod.label}',
                        ),
                        if (order.note != null && order.note!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text('Note: ${order.note}'),
                        ],
                        const Divider(height: AppSpacing.xl),
                        _DetailRow(
                          label: 'Status',
                          value: order.status.label,
                        ),
                        _DetailRow(
                          label: 'Created',
                          value: _formatTs(order.createdAt),
                        ),
                        _DetailRow(
                          label: 'Time spent',
                          value: _elapsed(order),
                        ),
                        _DetailRow(
                          label: 'Supervisor notified',
                          value: order.supervisorNotifiedAt != null ||
                                  order.status.index >=
                                      OrderStatus.supervisorNotified.index
                              ? _formatTs(
                                  order.supervisorNotifiedAt ?? order.createdAt,
                                )
                              : 'Waiting…',
                        ),
                        _DetailRow(
                          label: 'Rider',
                          value: order.riderName?.isNotEmpty == true
                              ? order.riderName!
                              : (order.status.index >=
                                      OrderStatus.assigned.index
                                  ? 'Assigned'
                                  : 'Not assigned yet'),
                        ),
                        _DetailRow(
                          label: 'ETA',
                          value: order.estimatedArrivalAt == null
                              ? 'Not set yet'
                              : _formatTs(order.estimatedArrivalAt),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _StatusTimeline(order: order),
                        if (order.status == OrderStatus.riderArrived) ...[
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => _confirmDelivery(order),
                              child: Text(l10n.confirmDelivery),
                            ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    final steps = [
      OrderStatus.pending,
      OrderStatus.supervisorNotified,
      OrderStatus.assigned,
      OrderStatus.outForDelivery,
      OrderStatus.riderArrived,
      OrderStatus.delivered,
    ];

    return Column(
      children: [
        for (final step in steps)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              order.status.index >= step.index
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: order.status.index >= step.index
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            title: Text(step.label),
          ),
      ],
    );
  }
}
