import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'supervisor_form_dialog.dart';
import 'supervisors_controller.dart';

class SupervisorsScreen extends StatefulWidget {
  const SupervisorsScreen({super.key});

  @override
  State<SupervisorsScreen> createState() => _SupervisorsScreenState();
}

class _SupervisorsScreenState extends State<SupervisorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupervisorsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupervisorsController>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  labelText: 'Search supervisors',
                  prefix: const Icon(Icons.search),
                  onChanged: controller.setSearch,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<UserStatus?>(
                  value: controller.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(
                      value: UserStatus.active,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: UserStatus.inactive,
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: controller.setStatusFilter,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => showSupervisorFormDialog(
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
                    : controller.supervisors.isEmpty
                    ? const EmptyStateView(
                        title: 'No supervisors',
                        subtitle: 'Create a supervisor to get started.',
                      )
                    : Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          itemCount: controller.supervisors.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = controller.supervisors[index];
                            final branch = controller.branchFor(user);
                            return ListTile(
                              onTap: () => showDetailsDialog(
                                context: context,
                                title: user.displayName,
                                fields: [
                                  DetailField(
                                    label: 'Phone',
                                    value: user.phone ?? '',
                                  ),
                                  DetailField(label: 'Email', value: user.email),
                                  DetailField(
                                    label: 'Branch',
                                    value: branch?.name ?? '',
                                  ),
                                  DetailField(
                                    label: 'Address',
                                    value: user.address ?? '',
                                  ),
                                  DetailField(
                                    label: 'Status',
                                    value: user.status.name,
                                  ),
                                  DetailField(
                                    label: 'Notes',
                                    value: user.notes ?? '',
                                  ),
                                ],
                                onEdit: () => showSupervisorFormDialog(
                                  context: context,
                                  controller: controller,
                                  supervisor: user,
                                ),
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  user.displayName.isEmpty
                                      ? '?'
                                      : user.displayName.characters.first
                                          .toUpperCase(),
                                ),
                              ),
                              title: Text(user.displayName),
                              subtitle: Text(
                                [
                                  user.phone ?? 'No phone',
                                  if (user.email.isNotEmpty) user.email,
                                  if (branch != null) branch.name,
                                  user.status.name,
                                ].join(' · '),
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () => showSupervisorFormDialog(
                                      context: context,
                                      controller: controller,
                                      supervisor: user,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDelete(
                                      context,
                                      controller,
                                      user,
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
    SupervisorsController controller,
    AppUser user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete supervisor?'),
        content: Text('Remove ${user.displayName} from the system?'),
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

    final result = await controller.delete(user.id);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Supervisor deleted');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }
}
