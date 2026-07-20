import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'rider_form_dialog.dart';
import 'riders_controller.dart';

class RidersScreen extends StatefulWidget {
  const RidersScreen({super.key});

  @override
  State<RidersScreen> createState() => _RidersScreenState();
}

class _RidersScreenState extends State<RidersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RidersController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RidersController>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  labelText: 'Search riders',
                  prefix: const Icon(Icons.search),
                  onChanged: controller.setSearch,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 160,
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
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String?>(
                  value: controller.branchFilter,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...controller.branches.map(
                      (branch) => DropdownMenuItem(
                        value: branch.id,
                        child: Text(branch.name),
                      ),
                    ),
                  ],
                  onChanged: controller.setBranchFilter,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => showRiderFormDialog(
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
                : controller.riders.isEmpty
                    ? const EmptyStateView(
                        title: 'No riders',
                        subtitle: 'Create a rider to assign deliveries.',
                      )
                    : Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          itemCount: controller.riders.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final rider = controller.riders[index];
                            return ListTile(
                              onTap: () => showDetailsDialog(
                                context: context,
                                title: rider.displayName,
                                fields: [
                                  DetailField(
                                    label: 'Phone',
                                    value: rider.phone ?? '',
                                  ),
                                  DetailField(
                                    label: 'Email',
                                    value: rider.email,
                                  ),
                                  DetailField(
                                    label: 'Address',
                                    value: rider.address ?? '',
                                  ),
                                  DetailField(
                                    label: 'CNIC',
                                    value: rider.cnic ?? '',
                                  ),
                                  DetailField(
                                    label: 'Preferred branches',
                                    value: controller.branchNamesFor(rider),
                                  ),
                                  DetailField(
                                    label: 'Experience',
                                    value: rider.experience ?? '',
                                  ),
                                  DetailField(
                                    label: 'Vehicle plate',
                                    value: rider.vehiclePlate ?? '',
                                  ),
                                  DetailField(
                                    label: 'Status',
                                    value: rider.status.name,
                                  ),
                                  DetailField(
                                    label: 'Notes',
                                    value: rider.notes ?? '',
                                  ),
                                ],
                                onEdit: () => showRiderFormDialog(
                                  context: context,
                                  controller: controller,
                                  rider: rider,
                                ),
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  rider.displayName.isEmpty
                                      ? '?'
                                      : rider.displayName.characters.first
                                          .toUpperCase(),
                                ),
                              ),
                              title: Text(rider.displayName),
                              subtitle: Text(
                                [
                                  rider.phone ?? 'No phone',
                                  if (rider.cnic != null) 'CNIC ${rider.cnic}',
                                  controller.branchNamesFor(rider),
                                  rider.status.name,
                                ].join(' · '),
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () => showRiderFormDialog(
                                      context: context,
                                      controller: controller,
                                      rider: rider,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDelete(
                                      context,
                                      controller,
                                      rider,
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
    RidersController controller,
    AppUser rider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete rider?'),
        content: Text('Remove ${rider.displayName} from the system?'),
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

    final result = await controller.delete(rider.id);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Rider deleted');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }
}
