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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BranchesController>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  labelText: 'Search branches',
                  prefix: const Icon(Icons.search),
                  onChanged: controller.setSearch,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<BranchStatus?>(
                  value: controller.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
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
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => showBranchFormDialog(
                  context: context,
                  controller: controller,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (controller.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                controller.error!,
                style: TextStyle(color: context.colors.error),
              ),
            ),
          Expanded(
            child: controller.isLoading
                ? const LoadingView()
                : controller.branches.isEmpty
                    ? const EmptyStateView(
                        title: 'No branches',
                        subtitle:
                            'Create a branch and assign a supervisor to it.',
                      )
                    : Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          itemCount: controller.branches.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final branch = controller.branches[index];
                            final supervisor =
                                controller.supervisorFor(branch);
                            return ListTile(
                              onTap: () => showDetailsDialog(
                                context: context,
                                title: branch.name,
                                fields: [
                                  DetailField(label: 'Code', value: branch.code),
                                  DetailField(
                                    label: 'Supervisor',
                                    value: supervisor?.displayName ?? '',
                                  ),
                                  DetailField(
                                    label: 'Address',
                                    value: branch.address ?? '',
                                  ),
                                  DetailField(
                                    label: 'City',
                                    value: branch.city ?? '',
                                  ),
                                  DetailField(
                                    label: 'Phone',
                                    value: branch.phone ?? '',
                                  ),
                                  DetailField(
                                    label: 'Email',
                                    value: branch.email ?? '',
                                  ),
                                  DetailField(
                                    label: 'Location',
                                    value: branch.location == null
                                        ? ''
                                        : '${branch.location!.latitude.toStringAsFixed(5)}, ${branch.location!.longitude.toStringAsFixed(5)}',
                                  ),
                                  DetailField(
                                    label: 'Riders',
                                    value: '${branch.riderIds.length}',
                                  ),
                                  DetailField(
                                    label: 'Status',
                                    value: branch.status.name,
                                  ),
                                  DetailField(
                                    label: 'Notes',
                                    value: branch.notes ?? '',
                                  ),
                                ],
                                onEdit: () => showBranchFormDialog(
                                  context: context,
                                  controller: controller,
                                  branch: branch,
                                ),
                              ),
                              leading: CircleAvatar(
                                child: Icon(
                                  Icons.store,
                                  color: context.colors.onPrimaryContainer,
                                ),
                              ),
                              title: Text('${branch.name} (${branch.code})'),
                              subtitle: Text(
                                [
                                  if (supervisor != null)
                                    'Supervisor: ${supervisor.displayName}'
                                  else
                                    'No supervisor',
                                  if (branch.city != null) branch.city!,
                                  '${branch.riderIds.length} riders',
                                  branch.status.name,
                                ].join(' · '),
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
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
