import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
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
    if (widget.order.status.isScheduledHold) {
      AppSnackBar.warning(
        context,
        'Wait until the scheduled time before assigning a rider',
      );
      return;
    }
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
    final l10n = context.l10n;
    final controller = context.watch<SupervisorOrdersController>();
    final order = widget.order;
    final isScheduledHold = order.status.isScheduledHold;
    final riders = controller.ridersForBranch(myBranch: _myBranch);
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final etaLabel = DateTimeFormatter.formatDateTime(_eta);
    final maxHeight = media.size.height * 0.92;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isScheduledHold
                            ? l10n.scheduledOrderTitle
                            : l10n.assignOrder,
                        style: context.texts.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${order.productName} · ${l10n.qtyWithValue(order.quantity)} · '
                        'Rs ${order.lineTotal.toStringAsFixed(0)}',
                      ),
                      Text(l10n.customerWithName(order.customerName)),
                      if (order.scheduledFor != null)
                        Text(
                          l10n.scheduledForLabel(
                            DateTimeFormatter.formatLong(order.scheduledFor),
                          ),
                          style: context.texts.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (order.note != null && order.note!.isNotEmpty)
                        Text(l10n.noteWithText(order.note!)),
                      if (isScheduledHold) ...[
                        const SizedBox(height: AppSpacing.md),
                        Card(
                          color: context.colors.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              l10n.scheduledAssignLockedHint,
                              style: context.texts.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      DeliveryContactSection(order: order),
                      if (!isScheduledHold) ...[
                        const Divider(height: AppSpacing.xl),
                        Text(
                          l10n.selectRider,
                          style: context.texts.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: true,
                              label: Text(l10n.myBranch),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text(l10n.otherBranches),
                            ),
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
                        if (riders.isEmpty)
                          Text(
                            l10n.noRidersInGroup,
                            style: context.texts.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          )
                        else
                          ...riders.map((rider) {
                            return RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
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
                          }),
                        const SizedBox(height: AppSpacing.md),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.estimatedArrival),
                          subtitle: Text(etaLabel),
                          trailing: IconButton(
                            icon: const Icon(Icons.schedule),
                            onPressed: _pickEta,
                          ),
                          onTap: _pickEta,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: isScheduledHold
                    ? OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.close),
                      )
                    : FilledButton(
                        onPressed: controller.isAssigning ? null : _assign,
                        child: controller.isAssigning
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.assignAndNotifyRider),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
