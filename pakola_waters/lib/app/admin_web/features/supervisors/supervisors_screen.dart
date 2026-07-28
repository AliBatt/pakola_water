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

  void _showSupervisorDetails(
    BuildContext context,
    SupervisorsController controller,
    AppUser user,
  ) {
    final branch = controller.branchFor(user);

    showDetailsDialog(
      context: context,
      title: user.displayName,
      subtitle: 'Supervisor details',
      fields: [
        DetailField(
          label: 'Phone',
          value: user.phone ?? '',
          copyable: true,
          icon: Icons.call_outlined,
        ),
        DetailField(
          label: 'Email',
          value: user.email,
          copyable: true,
          icon: Icons.email_outlined,
        ),
        DetailField(
          label: 'Branch',
          value: branch?.name ?? '',
          copyable: branch != null,
          icon: Icons.storefront_outlined,
        ),
        DetailField(
          label: 'Address',
          value: user.address ?? '',
          copyable: true,
          icon: Icons.place_outlined,
        ),
        DetailField(
          label: 'Status',
          value: user.status.name,
          icon: Icons.flag_outlined,
        ),
        DetailField(
          label: 'User ID',
          value: user.id,
          copyable: true,
          monospace: true,
          icon: Icons.fingerprint,
        ),
        DetailField(
          label: 'Notes',
          value: user.notes ?? '',
          icon: Icons.notes_outlined,
        ),
      ],
      onEdit: () => showSupervisorFormDialog(
        context: context,
        controller: controller,
        supervisor: user,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupervisorsController>();
    final supervisors = controller.supervisors;
    final activeCount =
        supervisors.where((u) => u.status == UserStatus.active).length;

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
                          'Supervisors',
                          style: context.texts.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Search staff, copy contact details, and manage branch assignments.',
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
                    onPressed: () => showSupervisorFormDialog(
                      context: context,
                      controller: controller,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(compact ? 'Create' : 'Create supervisor'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(label: Text('Showing: ${supervisors.length}')),
                  Chip(
                    backgroundColor: AppColors.success.withValues(alpha: 0.12),
                    label: Text('Active: $activeCount'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (compact) ...[
                AppTextField(
                  labelText: 'Search name, phone, email…',
                  prefix: const Icon(Icons.search),
                  onChanged: controller.setSearch,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<UserStatus?>(
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
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        labelText: 'Search name, phone, email…',
                        prefix: const Icon(Icons.search),
                        onChanged: controller.setSearch,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<UserStatus?>(
                        value: controller.statusFilter,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All statuses'),
                          ),
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
                    ? const LoadingView(message: 'Loading supervisors...')
                    : supervisors.isEmpty
                        ? const EmptyStateView(
                            title: 'No supervisors found',
                            subtitle: 'Create a supervisor to get started.',
                            icon: Icons.supervisor_account_outlined,
                          )
                        : Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                              itemCount: supervisors.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final user = supervisors[index];
                                final branch = controller.branchFor(user);
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  onTap: () => _showSupervisorDetails(
                                    context,
                                    controller,
                                    user,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        context.colors.secondaryContainer,
                                    child: Text(
                                      user.displayName.isEmpty
                                          ? '?'
                                          : user.displayName.characters.first
                                              .toUpperCase(),
                                      style: TextStyle(
                                        color: context
                                            .colors.onSecondaryContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(status: user.status.name),
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
                                            user.phone ?? 'No phone',
                                            if (branch != null) branch.name,
                                          ].join(' · '),
                                        ),
                                        if (user.email.isNotEmpty)
                                          Text(
                                            user.email,
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
                                      if (user.phone != null)
                                        CopyValueButton(
                                          value: user.phone!,
                                          label: 'phone',
                                          icon: Icons.call_outlined,
                                        ),
                                      CopyValueButton(
                                        value: user.email,
                                        label: 'email',
                                        icon: Icons.email_outlined,
                                      ),
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () =>
                                            showSupervisorFormDialog(
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
      },
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
