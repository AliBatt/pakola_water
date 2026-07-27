import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import 'supervisor_orders_controller.dart';

Future<void> showAssignOrderSheet({
  required BuildContext context,
  required DeliveryOrder order,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AssignOrderSheet(order: order),
  );
}

class AssignOrderSheet extends StatefulWidget {
  const AssignOrderSheet({super.key, required this.order});

  final DeliveryOrder order;

  @override
  State<AssignOrderSheet> createState() => _AssignOrderSheetState();
}

class _AssignOrderSheetState extends State<AssignOrderSheet> {
  bool _myBranch = true;
  AppUser? _selectedRider;
  DateTime _eta = DateTime.now().add(const Duration(minutes: 45));

  Future<void> _pickEta() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eta,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eta),
    );
    if (time == null || !mounted) return;

    setState(() {
      _eta = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _assign() async {
    final rider = _selectedRider;
    if (rider == null) {
      AppSnackBar.warning(context, 'Select a rider');
      return;
    }
    if (_eta.isBefore(DateTime.now())) {
      AppSnackBar.warning(context, 'ETA must be in the future');
      return;
    }

    final controller = context.read<SupervisorOrdersController>();
    final result = await controller.assignOrder(
      order: widget.order,
      rider: rider,
      estimatedArrivalAt: _eta,
    );
    if (!mounted) return;
    switch (result) {
      case Success():
        if (!context.mounted) return;
        Navigator.pop(context);
        AppSnackBar.success(
          context,
          'Assigned to ${rider.displayName}. Rider notified.',
        );
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupervisorOrdersController>();
    final order = widget.order;
    final riders = controller.ridersForBranch(myBranch: _myBranch);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final etaLabel = DateTimeFormatter.formatDateTime(_eta);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Assign order',
            style: context.texts.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${order.productName} · Qty ${order.quantity} · Rs ${order.lineTotal.toStringAsFixed(0)}',
          ),
          Text('Customer: ${order.customerName}'),
          if (order.note != null && order.note!.isNotEmpty)
            Text('Note: ${order.note}'),
          const SizedBox(height: AppSpacing.md),
          DeliveryContactSection(order: order),
          const Divider(height: AppSpacing.xl),
          Text(
            'Select rider',
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('My branch')),
              ButtonSegment(value: false, label: Text('Other branches')),
            ],
            selected: {_myBranch},
            onSelectionChanged: (value) {
              setState(() {
                _myBranch = value.first;
                _selectedRider = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: riders.isEmpty
                ? Text(
                    'No riders in this group',
                    style: context.texts.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: riders.length,
                    itemBuilder: (context, index) {
                      final rider = riders[index];
                      return RadioListTile<String>(
                        value: rider.id,
                        groupValue: _selectedRider?.id,
                        onChanged: (_) =>
                            setState(() => _selectedRider = rider),
                        title: Text(rider.displayName),
                        subtitle: Text(
                          [
                            rider.phone,
                            if (rider.vehiclePlate != null)
                              rider.vehiclePlate!,
                          ].whereType<String>().join(' · '),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Estimated arrival'),
            subtitle: Text(etaLabel),
            trailing: IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: _pickEta,
            ),
            onTap: _pickEta,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: controller.isAssigning ? null : _assign,
            child: controller.isAssigning
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Assign & notify rider'),
          ),
        ],
      ),
    );
  }
}
