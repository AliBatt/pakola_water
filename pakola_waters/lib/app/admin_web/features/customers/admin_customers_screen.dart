import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../routing/admin_routes.dart';
import '../orders/admin_orders_controller.dart';
import 'admin_customer_details_dialog.dart';
import 'admin_customers_controller.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCustomersController>().load();
    });
  }

  void _openInOrders(AppUser customer) {
    final orders = context.read<AdminOrdersController>();
    orders.setSearch(customer.id);
    orders.setBranchFilter(null);
    orders.setStatusFilter(null);
    context.go(AdminRoutes.orders);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminCustomersController>();
    final customers = controller.customers;

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
                      'Customers',
                      style: context.texts.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Search customers, filter by preferred branch, and open their orders.',
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: controller.load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Chip(label: Text('Showing: ${controller.totalCount}')),
              Chip(
                backgroundColor: context.colors.primaryContainer,
                label: Text('Active: ${controller.activeCount}'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            labelText: 'Search name, email, phone, address, branch…',
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
                  labelText: 'Preferred branch',
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
              final statusField = DropdownButtonFormField<UserStatus?>(
                value: controller.statusFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All statuses')),
                  DropdownMenuItem(
                    value: UserStatus.active,
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: UserStatus.inactive,
                    child: Text('Inactive'),
                  ),
                  DropdownMenuItem(
                    value: UserStatus.suspended,
                    child: Text('Suspended'),
                  ),
                  DropdownMenuItem(
                    value: UserStatus.pending,
                    child: Text('Pending'),
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
          if (controller.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              controller.error!,
              style: TextStyle(color: context.colors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: controller.isLoading
                ? const LoadingView(message: 'Loading customers...')
                : customers.isEmpty
                    ? const EmptyStateView(
                        title: 'No customers found',
                        subtitle: 'Try changing search or branch filters.',
                        icon: Icons.people_outline,
                      )
                    : Card(
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 900;
                            if (!wide) {
                              return ListView.separated(
                                itemCount: customers.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final customer = customers[index];
                                  return ListTile(
                                    title: Text(customer.displayName),
                                    subtitle: Text(
                                      '${customer.phone ?? customer.email}\n'
                                      '${controller.branchNameFor(customer)} · '
                                      '${customer.status.name}',
                                    ),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      tooltip: 'Open orders',
                                      onPressed: () => _openInOrders(customer),
                                      icon: const Icon(Icons.receipt_long),
                                    ),
                                    onTap: () => showAdminCustomerDetailsDialog(
                                      context: context,
                                      customer: customer,
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
                                      DataColumn(label: Text('Phone')),
                                      DataColumn(label: Text('Preferred branch')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: [
                                      for (final customer in customers)
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
                                                    customer.displayName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    customer.email,
                                                    style: context
                                                        .texts.bodySmall
                                                        ?.copyWith(
                                                      color: context.colors
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () =>
                                                  showAdminCustomerDetailsDialog(
                                                context: context,
                                                customer: customer,
                                              ),
                                            ),
                                            DataCell(
                                              Text(customer.phone ?? '—'),
                                            ),
                                            DataCell(
                                              Text(
                                                controller
                                                    .branchNameFor(customer),
                                              ),
                                            ),
                                            DataCell(
                                              Chip(
                                                label: Text(
                                                  customer.status.name,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        showAdminCustomerDetailsDialog(
                                                      context: context,
                                                      customer: customer,
                                                    ),
                                                    child: const Text(
                                                      'Details',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        _openInOrders(
                                                      customer,
                                                    ),
                                                    child: const Text(
                                                      'Orders',
                                                    ),
                                                  ),
                                                ],
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
