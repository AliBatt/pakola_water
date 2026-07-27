import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import '../../../../shared/orders/others_date_preset.dart';
import 'admin_reports_controller.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReportsController>().bind();
    });
  }

  Future<void> _pickCustomRange(AdminReportsController controller) async {
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

  String _money(double value) => 'Rs ${value.toStringAsFixed(0)}';

  String _dur(Duration? value) => value?.shortLabel ?? '—';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminReportsController>();

    if (controller.isLoading) {
      return const LoadingView();
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business reports',
                      style: context.texts.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Revenue, performance, and operational timings across the business.',
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
          const SizedBox(height: AppSpacing.md),
          _FiltersBar(
            controller: controller,
            onPickCustomRange: () => _pickCustomRange(controller),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _KpiCard(
                label: 'Revenue',
                value: _money(controller.totalRevenue),
                icon: Icons.payments_outlined,
                color: AppColors.success,
              ),
              _KpiCard(
                label: 'Delivered orders',
                value: '${controller.deliveredCount}',
                icon: Icons.check_circle_outline,
                color: context.colors.primary,
              ),
              _KpiCard(
                label: 'Active / Failed',
                value:
                    '${controller.activeCount} / ${controller.failedCount}',
                icon: Icons.timelapse,
                color: AppColors.warning,
              ),
              _KpiCard(
                label: 'Avg assign time',
                value: _dur(controller.averageAssignTime),
                icon: Icons.assignment_ind_outlined,
                color: AppColors.info,
              ),
              _KpiCard(
                label: 'Avg arrive time',
                value: _dur(controller.averageArriveTime),
                icon: Icons.speed,
                color: context.colors.tertiary,
              ),
              _KpiCard(
                label: 'Avg total delivery',
                value: _dur(controller.averageDeliveryTime),
                icon: Icons.schedule,
                color: context.colors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1000;
              final cards = [
                _HighlightCard(
                  title: 'Top branch',
                  subtitle: controller.topBranch?.name ?? '—',
                  detail: controller.topBranch == null
                      ? 'No delivered orders'
                      : '${_money(controller.topBranch!.revenue)} · ${controller.topBranch!.deliveredCount} deliveries',
                  icon: Icons.storefront_outlined,
                ),
                _HighlightCard(
                  title: 'Top rider',
                  subtitle: controller.topRider?.name ?? '—',
                  detail: controller.topRider == null
                      ? 'No rider activity'
                      : '${controller.topRider!.deliveredCount} deliveries · ${_money(controller.topRider!.revenue)}',
                  icon: Icons.two_wheeler_outlined,
                ),
                _HighlightCard(
                  title: 'Fastest arrive (rider)',
                  subtitle: controller.fastestRider?.name ?? '—',
                  detail: controller.fastestRider == null
                      ? 'No arrive timings'
                      : 'Avg ${_dur(controller.fastestRider!.avgArriveDuration)} to arrive',
                  icon: Icons.flash_on_outlined,
                ),
                _HighlightCard(
                  title: 'Fastest assign (supervisor)',
                  subtitle: controller.fastestSupervisor?.name ?? '—',
                  detail: controller.fastestSupervisor == null
                      ? 'No assign timings'
                      : 'Avg ${_dur(controller.fastestSupervisor!.avgAssignDuration)} to assign',
                  icon: Icons.bolt_outlined,
                ),
              ];
              if (wide) {
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: cards
                    .map(
                      (c) => SizedBox(
                        width: constraints.maxWidth >= 600
                            ? (constraints.maxWidth - AppSpacing.sm) / 2
                            : constraints.maxWidth,
                        child: c,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1000;
              final branchChart = _ChartCard(
                title: 'Revenue by branch',
                child: _BranchRevenueChart(
                  stats: controller.branchStats.take(8).toList(),
                  money: _money,
                ),
              );
              final trendChart = _ChartCard(
                title: 'Revenue trend',
                child: _RevenueTrendChart(
                  points: controller.revenueTrend,
                  money: _money,
                ),
              );
              final statusChart = _ChartCard(
                title: 'Orders by status',
                child: _StatusPieChart(
                  breakdown: controller.statusBreakdown,
                  total: controller.totalOrders,
                ),
              );

              if (wide) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: branchChart),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(flex: 2, child: statusChart),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    trendChart,
                  ],
                );
              }
              return Column(
                children: [
                  branchChart,
                  const SizedBox(height: AppSpacing.md),
                  statusChart,
                  const SizedBox(height: AppSpacing.md),
                  trendChart,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1100;
              final riders = _RankedTableCard(
                title: 'Riders (max deliveries → lowest)',
                trailing: DropdownButton<RiderRankBy>(
                  value: controller.riderRankBy,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: RiderRankBy.deliveries,
                      child: Text('Sort: deliveries'),
                    ),
                    DropdownMenuItem(
                      value: RiderRankBy.revenue,
                      child: Text('Sort: revenue'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) controller.setRiderRankBy(v);
                  },
                ),
                columns: const [
                  'Rider',
                  'Deliveries',
                  'Revenue',
                  'Avg arrive',
                  'Failed',
                ],
                rows: controller.riderStats.take(15).map((s) {
                  return [
                    s.name,
                    '${s.deliveredCount}',
                    _money(s.revenue),
                    _dur(s.avgArriveDuration),
                    '${s.failedCount}',
                  ];
                }).toList(),
              );
              final customers = _RankedTableCard(
                title: 'Customers (highest revenue)',
                trailing: DropdownButton<CustomerRankBy>(
                  value: controller.customerRankBy,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: CustomerRankBy.revenue,
                      child: Text('Sort: revenue'),
                    ),
                    DropdownMenuItem(
                      value: CustomerRankBy.orders,
                      child: Text('Sort: orders'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) controller.setCustomerRankBy(v);
                  },
                ),
                columns: const [
                  'Customer',
                  'Orders',
                  'Delivered',
                  'Revenue',
                ],
                rows: controller.customerStats.take(15).map((s) {
                  return [
                    s.name,
                    '${s.orderCount}',
                    '${s.deliveredCount}',
                    _money(s.revenue),
                  ];
                }).toList(),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: riders),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: customers),
                  ],
                );
              }
              return Column(
                children: [
                  riders,
                  const SizedBox(height: AppSpacing.md),
                  customers,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1100;
              final branches = _RankedTableCard(
                title: 'Branches by revenue',
                columns: const [
                  'Branch',
                  'Orders',
                  'Delivered',
                  'Revenue',
                  'Avg assign',
                ],
                rows: controller.branchStats.map((s) {
                  return [
                    s.name,
                    '${s.orderCount}',
                    '${s.deliveredCount}',
                    _money(s.revenue),
                    _dur(s.avgAssignDuration),
                  ];
                }).toList(),
              );
              final supervisors = _RankedTableCard(
                title: 'Supervisor performance',
                columns: const [
                  'Supervisor',
                  'Assigned',
                  'Delivered',
                  'Revenue',
                  'Avg assign',
                ],
                rows: controller.supervisorStats.map((s) {
                  return [
                    s.name,
                    '${s.orderCount}',
                    '${s.deliveredCount}',
                    _money(s.revenue),
                    _dur(s.avgAssignDuration),
                  ];
                }).toList(),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: branches),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: supervisors),
                  ],
                );
              }
              return Column(
                children: [
                  branches,
                  const SizedBox(height: AppSpacing.md),
                  supervisors,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.controller,
    required this.onPickCustomRange,
  });

  final AdminReportsController controller;
  final VoidCallback onPickCustomRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                      onPickCustomRange();
                    } else {
                      controller.setDatePreset(preset);
                    }
                  },
                ),
              );
            }).toList(),
          ),
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
            final paymentField = DropdownButtonFormField<PaymentMethod?>(
              value: controller.paymentFilter,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Payment',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All payments'),
                ),
                ...PaymentMethod.values.map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(method.label),
                  ),
                ),
              ],
              onChanged: controller.setPaymentFilter,
            );
            final basisField = DropdownButtonFormField<ReportsDateBasis>(
              value: controller.dateBasis,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Date basis',
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: ReportsDateBasis.created,
                  child: Text('Order created date'),
                ),
                DropdownMenuItem(
                  value: ReportsDateBasis.delivered,
                  child: Text('Delivered date'),
                ),
              ],
              onChanged: (v) {
                if (v != null) controller.setDateBasis(v);
              },
            );

            if (wide) {
              return Row(
                children: [
                  Expanded(child: branchField),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: paymentField),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: basisField),
                ],
              );
            }
            return Column(
              children: [
                branchField,
                const SizedBox(height: AppSpacing.sm),
                paymentField,
                const SizedBox(height: AppSpacing.sm),
                basisField,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.texts.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
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

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.colors.primaryContainer,
              child: Icon(icon, color: context.colors.onPrimaryContainer),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.texts.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(height: 260, child: child),
          ],
        ),
      ),
    );
  }
}

class _BranchRevenueChart extends StatelessWidget {
  const _BranchRevenueChart({required this.stats, required this.money});

  final List<ReportEntityStat> stats;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text('No branch revenue in this range'));
    }

    final maxY = stats
        .map((s) => s.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 1.0 : maxY * 1.2;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                value >= 1000
                    ? '${(value / 1000).toStringAsFixed(0)}k'
                    : value.toStringAsFixed(0),
                style: context.texts.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= stats.length) {
                  return const SizedBox.shrink();
                }
                final label = stats[index].name;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label.length > 10 ? '${label.substring(0, 10)}…' : label,
                    style: context.texts.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < stats.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: stats[i].revenue,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  color: context.colors.primary,
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final stat = stats[group.x];
              return BarTooltipItem(
                '${stat.name}\n${money(stat.revenue)}',
                TextStyle(color: context.colors.onInverseSurface),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RevenueTrendChart extends StatelessWidget {
  const _RevenueTrendChart({required this.points, required this.money});

  final List<RevenuePoint> points;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No delivered revenue trend yet'));
    }

    final maxY = points
        .map((p) => p.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 1.0 : maxY * 1.2;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: chartMax,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                value >= 1000
                    ? '${(value / 1000).toStringAsFixed(0)}k'
                    : value.toStringAsFixed(0),
                style: context.texts.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: points.length <= 7
                  ? 1
                  : (points.length / 6).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                final d = points[index].day;
                return Text(
                  '${d.day}/${d.month}',
                  style: context.texts.labelSmall,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].revenue),
            ],
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            dotData: FlDotData(show: points.length <= 14),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withValues(alpha: 0.12),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) {
              return touched.map((spot) {
                final point = points[spot.x.toInt()];
                return LineTooltipItem(
                  '${DateTimeFormatter.format(point.day.toIso8601String())}\n${money(point.revenue)} · ${point.orders} orders',
                  TextStyle(color: context.colors.onInverseSurface),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  const _StatusPieChart({
    required this.breakdown,
    required this.total,
  });

  final Map<OrderStatus, int> breakdown;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total == 0 || breakdown.isEmpty) {
      return const Center(child: Text('No orders in this range'));
    }

    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = <OrderStatus, Color>{
      OrderStatus.pending: context.colors.outline,
      OrderStatus.supervisorNotified: AppColors.info,
      OrderStatus.assigned: context.colors.primary,
      OrderStatus.outForDelivery: AppColors.warning,
      OrderStatus.riderArrived: context.colors.tertiary,
      OrderStatus.delivered: AppColors.success,
      OrderStatus.cancelled: context.colors.onSurfaceVariant,
      OrderStatus.failed: context.colors.error,
    };

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: [
                for (final entry in entries)
                  PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: entry.value.toString(),
                    color: colors[entry.key] ?? context.colors.primary,
                    radius: 54,
                    titleStyle: context.texts.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ListView(
            children: [
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[entry.key] ?? context.colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.key.label,
                          style: context.texts.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: context.texts.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankedTableCard extends StatelessWidget {
  const _RankedTableCard({
    required this.title,
    required this.columns,
    required this.rows,
    this.trailing,
  });

  final String title;
  final List<String> columns;
  final List<List<String>> rows;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  'No data for current filters.',
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('#')),
                    ...columns.map((c) => DataColumn(label: Text(c))),
                  ],
                  rows: [
                    for (var i = 0; i < rows.length; i++)
                      DataRow(
                        cells: [
                          DataCell(Text('${i + 1}')),
                          ...rows[i].map((cell) => DataCell(Text(cell))),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
