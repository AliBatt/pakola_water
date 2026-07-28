import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'branch_form_dialog.dart';
import 'branches_controller.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BranchesController>().load();
    });
  }

  void _showBranchDetails(
    BuildContext context,
    BranchesController controller,
    Branch branch,
  ) {
    final supervisor = controller.supervisorFor(branch);
    final location = branch.location == null
        ? ''
        : '${branch.location!.latitude.toStringAsFixed(5)}, '
            '${branch.location!.longitude.toStringAsFixed(5)}';

    showDetailsDialog(
      context: context,
      title: branch.name,
      subtitle: 'Branch details',
      fields: [
        DetailField(
          label: 'Branch code',
          value: branch.code,
          copyable: true,
          monospace: true,
          icon: Icons.tag,
        ),
        DetailField(
          label: 'Supervisor',
          value: supervisor?.displayName ?? '',
          copyable: supervisor != null,
          icon: Icons.person_outline,
        ),
        if (supervisor?.phone != null && supervisor!.phone!.isNotEmpty)
          DetailField(
            label: 'Supervisor phone',
            value: supervisor.phone!,
            copyable: true,
            icon: Icons.phone_outlined,
          ),
        DetailField(
          label: 'Address',
          value: branch.address ?? '',
          copyable: true,
          icon: Icons.place_outlined,
        ),
        DetailField(
          label: 'City',
          value: branch.city ?? '',
          copyable: true,
          icon: Icons.location_city_outlined,
        ),
        DetailField(
          label: 'Phone',
          value: branch.phone ?? '',
          copyable: true,
          icon: Icons.call_outlined,
        ),
        DetailField(
          label: 'Email',
          value: branch.email ?? '',
          copyable: true,
          icon: Icons.email_outlined,
        ),
        DetailField(
          label: 'Coordinates',
          value: location,
          copyable: true,
          monospace: true,
          icon: Icons.my_location_outlined,
        ),
        DetailField(
          label: 'Riders assigned',
          value: '${branch.riderIds.length}',
          icon: Icons.two_wheeler_outlined,
        ),
        DetailField(
          label: 'Status',
          value: branch.status.name,
          icon: Icons.flag_outlined,
        ),
        DetailField(
          label: 'Branch ID',
          value: branch.id,
          copyable: true,
          monospace: true,
          icon: Icons.fingerprint,
        ),
        DetailField(
          label: 'Notes',
          value: branch.notes ?? '',
          icon: Icons.notes_outlined,
        ),
      ],
      onEdit: () => showBranchFormDialog(
        context: context,
        controller: controller,
        branch: branch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BranchesController>();
    final branches = controller.branches;
    final activeCount =
        branches.where((b) => b.status == BranchStatus.active).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;

        return Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
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
                          'Branches',
                          style: context.texts.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Manage locations, supervisors, and contact details.',
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
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: () => showBranchFormDialog(
                      context: context,
                      controller: controller,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(compact ? 'Create' : 'Create branch'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(label: Text('Showing: ${branches.length}')),
                  Chip(
                    backgroundColor: AppColors.success.withValues(alpha: 0.12),
                    label: Text('Active: $activeCount'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (compact) ...[
                AppTextField(
                  labelText: 'Search name, code, city…',
                  prefix: const Icon(Icons.search),
                  onChanged: controller.setSearch,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<BranchStatus?>(
                  value: controller.statusFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All statuses')),
                    DropdownMenuItem(
                      value: BranchStatus.active,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: BranchStatus.inactive,
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: controller.setStatusFilter,
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        labelText: 'Search name, code, city…',
                        prefix: const Icon(Icons.search),
                        onChanged: controller.setSearch,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<BranchStatus?>(
                        value: controller.statusFilter,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All statuses'),
                          ),
                          DropdownMenuItem(
                            value: BranchStatus.active,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: BranchStatus.inactive,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: controller.setStatusFilter,
                      ),
                    ),
                  ],
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
                    ? const LoadingView(message: 'Loading branches...')
                    : branches.isEmpty
                        ? const EmptyStateView(
                            title: 'No branches found',
                            subtitle:
                                'Create a branch and assign a supervisor to it.',
                            icon: Icons.storefront_outlined,
                          )
                        : Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                              itemCount: branches.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final branch = branches[index];
                                final supervisor =
                                    controller.supervisorFor(branch);
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  onTap: () => _showBranchDetails(
                                    context,
                                    controller,
                                    branch,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        context.colors.primaryContainer,
                                    child: Icon(
                                      Icons.storefront_outlined,
                                      color: context.colors.onPrimaryContainer,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          branch.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(
                                        status: branch.status.name,
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          [
                                            'Code ${branch.code}',
                                            if (supervisor != null)
                                              supervisor.displayName
                                            else
                                              'No supervisor',
                                            if (branch.city != null &&
                                                branch.city!.isNotEmpty)
                                              branch.city!,
                                            '${branch.riderIds.length} riders',
                                          ].join(' · '),
                                        ),
                                        if (branch.phone != null &&
                                            branch.phone!.isNotEmpty)
                                          Text(
                                            branch.phone!,
                                            style: context.texts.bodySmall
                                                ?.copyWith(
                                              color: context
                                                  .colors.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  isThreeLine: true,
                                  trailing: Wrap(
                                    spacing: 0,
                                    children: [
                                      CopyValueButton(
                                        value: branch.code,
                                        label: 'branch code',
                                        icon: Icons.tag,
                                      ),
                                      if (branch.phone != null)
                                        CopyValueButton(
                                          value: branch.phone!,
                                          label: 'phone',
                                          icon: Icons.call_outlined,
                                        ),
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () => showBranchFormDialog(
                                          context: context,
                                          controller: controller,
                                          branch: branch,
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        onPressed: () => _confirmDelete(
                                          context,
                                          controller,
                                          branch,
                                        ),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: context.colors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BranchesController controller,
    Branch branch,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete branch?'),
        content: Text('Remove ${branch.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await controller.delete(branch.id);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Branch deleted');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }
}
