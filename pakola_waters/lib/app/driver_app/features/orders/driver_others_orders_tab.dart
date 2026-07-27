import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../../../../shared/orders/others_date_preset.dart';
import 'driver_order_details_sheet.dart';
import 'driver_orders_controller.dart';

class DriverOthersOrdersTab extends StatelessWidget {
  const DriverOthersOrdersTab({super.key});

  Future<void> _pickCustomRange(BuildContext context) async {
    final controller = context.read<DriverOrdersController>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: controller.othersCustomRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      controller.setOthersCustomRange(
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
    final orders = controller.filteredOthersOrders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                labelText: 'Search customer or phone',
                prefix: const Icon(Icons.search),
                onChanged: controller.setOthersSearch,
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: OthersDatePreset.values.map((preset) {
                    final selected = controller.othersDatePreset == preset;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(preset.label),
                        selected: selected,
                        onSelected: (_) {
                          if (preset == OthersDatePreset.custom) {
                            _pickCustomRange(context);
                          } else {
                            controller.setOthersDatePreset(preset);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (controller.othersDatePreset == OthersDatePreset.custom &&
                  controller.othersCustomRange != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateTimeFormatter.formatRange(
                    controller.othersCustomRange!.start,
                    controller.othersCustomRange!.end,
                  ),
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<OrderStatus?>(
                value: controller.othersStatusFilter,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...OrderStatus.values
                      .where((s) => s.isCompleted)
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      ),
                ],
                onChanged: controller.setOthersStatusFilter,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: orders.isEmpty
              ? RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.35,
                        child: const EmptyStateView(
                          title: 'No orders match filters',
                          subtitle: 'Try changing search or filters.',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        child: ListTile(
                          onTap: () => showDriverOrderDetailsSheet(
                            context: context,
                            order: order,
                            allowActions: false,
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(order.productName)),
                              Chip(
                                label: Text(order.status.label),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          subtitle: Text(
                            [
                              order.customerName,
                              'Qty ${order.quantity}',
                              'Rs ${order.lineTotal.toStringAsFixed(0)}',
                              DateTimeFormatter.format(order.createdAt),
                            ].join(' · '),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
