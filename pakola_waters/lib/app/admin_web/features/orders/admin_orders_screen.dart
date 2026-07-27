import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../../../../shared/orders/others_date_preset.dart';
import 'admin_order_details_dialog.dart';
import 'admin_orders_controller.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrdersController>().bind();
    });
  }

  Future<void> _pickCustomRange(AdminOrdersController controller) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: controller.customRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminOrdersController>();
    final orders = controller.filteredOrders;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Orders',
                  style: context.texts.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
                label: 'Active',
                value: '${controller.activeCount}',
                color: context.colors.primaryContainer,
              ),
              _SummaryChip(
                label: 'Delivered',
                value: '${controller.deliveredCount}',
                color: context.colors.tertiaryContainer,
              ),
              _SummaryChip(
                label: 'Failed',
                value: '${controller.failedCount}',
                color: context.colors.errorContainer,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            labelText: 'Search customer, rider, supervisor, product, phone…',
            prefix: const Icon(Icons.search),
            onChanged: controller.setSearch,
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final branchField = DropdownButtonFormField<String?>(
                value: controller.branchFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Branch',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All branches'),
                  ),
                  ...controller.branches.map(
                    (branch) => DropdownMenuItem(
                      value: branch.id,
                      child: Text(branch.name),
                    ),
                  ),
                ],
                onChanged: controller.setBranchFilter,
              );
              final statusField = DropdownButtonFormField<OrderStatus?>(
                value: controller.statusFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...OrderStatus.values.map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  ),
                ],
                onChanged: controller.setStatusFilter,
              );

              if (wide) {
                return Row(
                  children: [
                    Expanded(child: branchField),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: statusField),
                  ],
                );
              }
              return Column(
                children: [
                  branchField,
                  const SizedBox(height: AppSpacing.sm),
                  statusField,
                ],
              );
            },
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
                    label: Text(preset.label),
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
          if (controller.datePreset == OthersDatePreset.custom &&
              controller.customRange != null) ...[
            const SizedBox(height: AppSpacing.xs),
                Text(
                  DateTimeFormatter.formatRange(
                    controller.customRange!.start,
                    controller.customRange!.end,
                  ),
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
          ],
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: orders.isEmpty
                ? const EmptyStateView(
                    title: 'No orders match filters',
                    subtitle: 'Try changing search, status, branch, or dates.',
                  )
                : Card(
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 1000) {
                          return ListView.separated(
                            itemCount: orders.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return _OrderListTile(
                                order: order,
                                supervisorName:
                                    controller.supervisorNameFor(order),
                                onTap: () => showAdminOrderDetailsDialog(
                                  context: context,
                                  order: order,
                                ),
                              );
                            },
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: SingleChildScrollView(
                              child: DataTable(
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(label: Text('Order')),
                                  DataColumn(label: Text('Customer')),
                                  DataColumn(label: Text('Supervisor')),
                                  DataColumn(label: Text('Rider')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Assign time')),
                                  DataColumn(label: Text('Delivery time')),
                                  DataColumn(label: Text('Total')),
                                  DataColumn(label: Text('Placed')),
                                ],
                                rows: orders.map((order) {
                                  return DataRow(
                                    onSelectChanged: (_) =>
                                        showAdminOrderDetailsDialog(
                                      context: context,
                                      order: order,
                                    ),
                                    cells: [
                                      DataCell(
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              order.productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'Rs ${order.lineTotal.toStringAsFixed(0)} · Qty ${order.quantity}',
                                              style: context.texts.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(order.customerName)),
                                      DataCell(
                                        Text(
                                          controller.supervisorNameFor(order),
                                        ),
                                      ),
                                      DataCell(
                                        Text(order.riderName ?? '—'),
                                      ),
                                      DataCell(
                                        Chip(
                                          label: Text(order.status.label),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          order.supervisorAssignDuration
                                                  ?.shortLabel ??
                                              '—',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          order.riderDeliveryDuration
                                                  ?.shortLabel ??
                                              '—',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          order.totalOrderDuration?.shortLabel ??
                                              '—',
                                        ),
                                      ),
                                      DataCell(
                                        Text(DateTimeFormatter.format(order.createdAt)),
                                      ),
                                    ],
                                  );
                                }).toList(),
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

class _OrderListTile extends StatelessWidget {
  const _OrderListTile({
    required this.order,
    required this.supervisorName,
    required this.onTap,
  });

  final DeliveryOrder order;
  final String supervisorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
          'Supervisor: $supervisorName',
          if (order.riderName != null) 'Rider: ${order.riderName}',
          if (order.supervisorAssignDuration != null)
            'Assign ${order.supervisorAssignDuration!.shortLabel}',
          if (order.totalOrderDuration != null)
            'Total ${order.totalOrderDuration!.shortLabel}',
          DateTimeFormatter.format(order.createdAt),
        ].join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
