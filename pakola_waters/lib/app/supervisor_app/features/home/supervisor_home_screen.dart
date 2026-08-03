import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:utilities/utilities.dart';
import '../../routing/supervisor_routes.dart';
import '../notifications/supervisor_notifications_bell_button.dart';
import '../notifications/supervisor_notifications_controller.dart';
import '../orders/supervisor_orders_controller.dart';
import '../../../../shared/requests/support_requests_app_bar_button.dart';

class SupervisorHomeScreen extends StatelessWidget {
  const SupervisorHomeScreen({super.key});

  Future<void> _pickDateRange(BuildContext context) async {
    final controller = context.read<SupervisorOrdersController>();
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
    final controller = context.watch<SupervisorOrdersController>();
    final notifications = context.watch<SupervisorNotificationsController>();
    final l10n = context.l10n;
    final hasNew = controller.newOrderCount > 0;
    final orderMessages = notifications.unreadOrderMessages;

    return Scaffold(
      appBar: AppBar(
        leading: const SupportRequestsAppBarButton(
          route: SupervisorRoutes.requests,
        ),
        title: Text(l10n.supervisorHomeTitle),
        actions: const [SupervisorNotificationsBellButton()],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (orderMessages.isNotEmpty)
              Card(
                color: context.colors.tertiaryContainer,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.message,
                        color: context.colors.onTertiaryContainer,
                      ),
                      title: Text(
                        '${orderMessages.length} new customer message(s)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.colors.onTertiaryContainer,
                        ),
                      ),
                      subtitle: Text(
                        orderMessages.first.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.onTertiaryContainer,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () =>
                            context.push(SupervisorRoutes.notifications),
                        child: Text(l10n.view),
                      ),
                    ),
                  ],
                ),
              ),
            if (hasNew)
              Card(
                color: context.colors.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: context.colors.onErrorContainer,
                  ),
                  title: Text(
                    l10n.newOrdersWaiting(controller.newOrderCount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onErrorContainer,
                    ),
                  ),
                  subtitle: Text(
                    l10n.openOrdersToAssignHint,
                    style: TextStyle(color: context.colors.onErrorContainer),
                  ),
                  onTap: () => context.go(SupervisorRoutes.orders),
                ),
              ),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = AppSpacing.md;
                final cardWidth = (constraints.maxWidth - gap) / 2;
                final cards = [
                  _StatCard(
                    label: l10n.statToday,
                    value: '${controller.todayOrderCount}',
                    icon: Icons.today,
                  ),
                  _StatCard(
                    label: l10n.statNewRequests,
                    value: '${controller.newOrderCount}',
                    icon: Icons.inbox,
                  ),
                  _StatCard(
                    label: l10n.statTotalRange,
                    value: '${controller.statsTotalOrders}',
                    icon: Icons.receipt_long,
                  ),
                  _StatCard(
                    label: l10n.statRevenue,
                    value:
                        'Rs ${controller.statsRevenue.toStringAsFixed(0)}',
                    icon: Icons.payments_outlined,
                  ),
                  _StatCard(
                    label: l10n.statPending,
                    value: '${controller.statsPendingOrders}',
                    icon: Icons.hourglass_top,
                  ),
                  _StatCard(
                    label: l10n.statInProgress,
                    value: '${controller.statsInProgressOrders}',
                    icon: Icons.local_shipping_outlined,
                  ),
                  _StatCard(
                    label: l10n.statCompleted,
                    value: '${controller.statsCompletedOrders}',
                    icon: Icons.check_circle_outline,
                  ),
                ];

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final card in cards)
                      SizedBox(width: cardWidth, child: card),
                  ],
                );
              },
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
