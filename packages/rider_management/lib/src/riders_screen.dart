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
    final riders = controller.riders;
    final activeCount =
        riders.where((r) => r.status == UserStatus.active).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final padding = compact ? AppSpacing.md : AppSpacing.lg;

        return Padding(
          padding: EdgeInsets.all(padding),
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
                          'Riders',
                          style: context.texts.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Manage delivery riders, preferred branches, and contact info.',
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
                    onPressed: () => showRiderFormDialog(
                      context: context,
                      controller: controller,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(compact ? 'Create' : 'Create rider'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(label: Text('Showing: ${riders.length}')),
                  Chip(
                    backgroundColor: AppColors.success.withValues(alpha: 0.12),
                    label: Text('Active: $activeCount'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (compact)
                _CompactFilters(controller: controller)
              else
                _WideFilters(controller: controller),
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
                    ? const LoadingView(message: 'Loading riders...')
                    : riders.isEmpty
                        ? const EmptyStateView(
                            title: 'No riders found',
                            subtitle: 'Create a rider to assign deliveries.',
                            icon: Icons.two_wheeler_outlined,
                          )
                        : Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                              itemCount: riders.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final rider = riders[index];
                                return _RiderTile(
                                  rider: rider,
                                  controller: controller,
                                  compact: compact,
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
}

class _WideFilters extends StatelessWidget {
  const _WideFilters({required this.controller});

  final RidersController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            labelText: 'Search name, phone, CNIC, plate…',
            prefix: const Icon(Icons.search),
            onChanged: controller.setSearch,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<UserStatus?>(
            value: controller.statusFilter,
            decoration: const InputDecoration(labelText: 'Status'),
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
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String?>(
            value: controller.branchFilter,
            decoration: const InputDecoration(labelText: 'Branch'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All branches')),
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
      ],
    );
  }
}

class _CompactFilters extends StatelessWidget {
  const _CompactFilters({required this.controller});

  final RidersController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          labelText: 'Search name, phone, CNIC, plate…',
          prefix: const Icon(Icons.search),
          onChanged: controller.setSearch,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<UserStatus?>(
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
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: DropdownButtonFormField<String?>(
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RiderTile extends StatelessWidget {
  const _RiderTile({
    required this.rider,
    required this.controller,
    required this.compact,
  });

  final AppUser rider;
  final RidersController controller;
  final bool compact;

  void _showDetails(BuildContext context) {
    showDetailsDialog(
      context: context,
      title: rider.displayName,
      subtitle: 'Rider details',
      fields: [
        DetailField(
          label: 'Phone',
          value: rider.phone ?? '',
          copyable: true,
          icon: Icons.call_outlined,
        ),
        DetailField(
          label: 'Email',
          value: rider.email,
          copyable: true,
          icon: Icons.email_outlined,
        ),
        DetailField(
          label: 'Address',
          value: rider.address ?? '',
          copyable: true,
          icon: Icons.place_outlined,
        ),
        DetailField(
          label: 'CNIC',
          value: rider.cnic ?? '',
          copyable: true,
          monospace: true,
          icon: Icons.badge_outlined,
        ),
        DetailField(
          label: 'Preferred branches',
          value: controller.branchNamesFor(rider),
          copyable: true,
          icon: Icons.storefront_outlined,
        ),
        DetailField(
          label: 'Experience',
          value: rider.experience ?? '',
          icon: Icons.timeline,
        ),
        DetailField(
          label: 'Vehicle plate',
          value: rider.vehiclePlate ?? '',
          copyable: true,
          monospace: true,
          icon: Icons.directions_car_outlined,
        ),
        DetailField(
          label: 'Status',
          value: rider.status.name,
          icon: Icons.flag_outlined,
        ),
        DetailField(
          label: 'User ID',
          value: rider.id,
          copyable: true,
          monospace: true,
          icon: Icons.fingerprint,
        ),
        DetailField(
          label: 'Notes',
          value: rider.notes ?? '',
          icon: Icons.notes_outlined,
        ),
      ],
      onEdit: () => showRiderFormDialog(
        context: context,
        controller: controller,
        rider: rider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      onTap: () => _showDetails(context),
      leading: CircleAvatar(
        backgroundColor: context.colors.tertiaryContainer,
        child: Text(
          rider.displayName.isEmpty
              ? '?'
              : rider.displayName.characters.first.toUpperCase(),
          style: TextStyle(
            color: context.colors.onTertiaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              rider.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          StatusBadge(status: rider.status.name),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                rider.phone ?? 'No phone',
                if (rider.vehiclePlate != null &&
                    rider.vehiclePlate!.isNotEmpty)
                  rider.vehiclePlate!,
                controller.branchNamesFor(rider),
              ].where((part) => part.trim().isNotEmpty).join(' · '),
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (rider.cnic != null && rider.cnic!.isNotEmpty)
              Text(
                'CNIC ${rider.cnic}',
                style: context.texts.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      isThreeLine: true,
      trailing: compact
          ? PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'copy_phone':
                    if (rider.phone != null) {
                      await CopyValueButton.copy(
                        context,
                        value: rider.phone!,
                        label: 'phone',
                      );
                    }
                  case 'copy_email':
                    await CopyValueButton.copy(
                      context,
                      value: rider.email,
                      label: 'email',
                    );
                  case 'copy_cnic':
                    if (rider.cnic != null) {
                      await CopyValueButton.copy(
                        context,
                        value: rider.cnic!,
                        label: 'CNIC',
                      );
                    }
                  case 'edit':
                    await showRiderFormDialog(
                      context: context,
                      controller: controller,
                      rider: rider,
                    );
                  case 'delete':
                    await _confirmDelete(context, controller, rider);
                }
              },
              itemBuilder: (context) => [
                if (rider.phone != null && rider.phone!.isNotEmpty)
                  const PopupMenuItem(
                    value: 'copy_phone',
                    child: ListTile(
                      leading: Icon(Icons.call_outlined),
                      title: Text('Copy phone'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                if (rider.email.isNotEmpty)
                  const PopupMenuItem(
                    value: 'copy_email',
                    child: ListTile(
                      leading: Icon(Icons.email_outlined),
                      title: Text('Copy email'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                if (rider.cnic != null && rider.cnic!.isNotEmpty)
                  const PopupMenuItem(
                    value: 'copy_cnic',
                    child: ListTile(
                      leading: Icon(Icons.badge_outlined),
                      title: Text('Copy CNIC'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: context.colors.error,
                    ),
                    title: Text(
                      'Delete',
                      style: TextStyle(color: context.colors.error),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            )
          : Wrap(
              spacing: 0,
              children: [
                if (rider.phone != null)
                  CopyValueButton(
                    value: rider.phone!,
                    label: 'phone',
                    icon: Icons.call_outlined,
                  ),
                CopyValueButton(
                  value: rider.email,
                  label: 'email',
                  icon: Icons.email_outlined,
                ),
                if (rider.cnic != null)
                  CopyValueButton(
                    value: rider.cnic!,
                    label: 'CNIC',
                    icon: Icons.badge_outlined,
                  ),
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
                  onPressed: () => _confirmDelete(context, controller, rider),
                  icon: Icon(
                    Icons.delete_outline,
                    color: context.colors.error,
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
