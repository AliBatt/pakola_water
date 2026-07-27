import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:utilities/utilities.dart';

import '../../routing/driver_routes.dart';
import '../orders/driver_orders_controller.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  Future<void> _pickDateRange(BuildContext context) async {
    final controller = context.read<DriverOrdersController>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: controller.statsRange,
    );
    if (picked != null) {
      controller.setStatsRange(
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DriverOrdersController>();
    final l10n = context.l10n;
    final newAssigned = controller.newAssignedCount;
    final active = controller.assignedOrders;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverHomeTitle)),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (newAssigned > 0)
              Card(
                color: context.colors.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: context.colors.onErrorContainer,
                  ),
                  title: Text(
                    '$newAssigned new assignment(s)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onErrorContainer,
                    ),
                  ),
                  subtitle: Text(
                    'Open Orders → Newly Assigned to start delivery',
                    style: TextStyle(color: context.colors.onErrorContainer),
                  ),
                  onTap: () => context.go(DriverRoutes.orders),
                ),
              ),
            if (active.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Active deliveries',
                style: context.texts.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...active.take(3).map(
                    (order) => Card(
                      child: ListTile(
                        title: Text(order.productName),
                        subtitle: Text(
                          [
                            order.customerName,
                            order.status.label,
                            if (order.estimatedArrivalAt != null)
                              'ETA ${DateTimeFormatter.formatTime(order.estimatedArrivalAt)}',
                          ].join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(DriverRoutes.orders),
                      ),
                    ),
                  ),
              if (active.length > 3)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.go(DriverRoutes.orders),
                    child: Text('View all ${active.length} active'),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _pickDateRange(context),
              icon: const Icon(Icons.date_range),
              label: Text(
                DateTimeFormatter.formatRange(
                  controller.statsRange.start,
                  controller.statsRange.end,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _StatCard(
                  label: 'Today',
                  value: '${controller.todayOrderCount}',
                  icon: Icons.today,
                ),
                _StatCard(
                  label: 'New assigned',
                  value: '${controller.newAssignedCount}',
                  icon: Icons.inbox,
                ),
                _StatCard(
                  label: 'In progress',
                  value: '${controller.statsInProgressOrders}',
                  icon: Icons.local_shipping_outlined,
                ),
                _StatCard(
                  label: 'Completed',
                  value: '${controller.statsCompletedOrders}',
                  icon: Icons.check_circle_outline,
                ),
                _StatCard(
                  label: 'Failed',
                  value: '${controller.statsFailedOrders}',
                  icon: Icons.cancel_outlined,
                ),
                _StatCard(
                  label: 'Total (range)',
                  value: '${controller.statsTotalOrders}',
                  icon: Icons.receipt_long,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: context.colors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: context.texts.headlineSmall?.copyWith(
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
        ),
      ),
    );
  }
}
