import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../routing/customer_routes.dart';
import 'order_location_picker.dart';
import 'orders_controller.dart';

Future<void> showPlaceOrderSheet({
  required BuildContext context,
  required Product product,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => PlaceOrderSheet(product: product),
  );
}

class PlaceOrderSheet extends StatefulWidget {
  const PlaceOrderSheet({super.key, required this.product});

  final Product product;

  @override
  State<PlaceOrderSheet> createState() => _PlaceOrderSheetState();
}

class _PlaceOrderSheetState extends State<PlaceOrderSheet> {
  final _noteController = TextEditingController();
  int _quantity = 1;
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  OrderType _orderType = OrderType.instant;
  DateTime? _scheduledFor;

  /// false = signup / profile location; true = one-off for this order.
  bool _useCustomLocation = false;

  String? _selectedBranchId;
  String? _nearestBranchId;

  late String _profileAddress;
  GeoLocation? _profileLocation;

  String? _customAddress;
  GeoLocation? _customLocation;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _profileAddress = user?.address?.trim() ?? '';
    _profileLocation = user?.location;
    _selectedBranchId = user?.primaryBranchId;
    _customLocation = user?.location;
    _customAddress = user?.address?.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<OrdersController>();
      if (controller.hasOpenInstantOrder && !controller.hasOpenScheduledOrder) {
        setState(() {
          _orderType = OrderType.scheduled;
          _scheduledFor ??= DateTime.now().add(const Duration(hours: 2));
        });
      }
      final location = _effectiveLocation;
      if (location != null) {
        _recommendNearest(
          location,
          selectRecommended: _selectedBranchId == null,
        );
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<Branch> get _activeBranches {
    return context
        .read<OrdersController>()
        .branches
        .where((b) => b.status == BranchStatus.active)
        .toList();
  }

  GeoLocation? get _effectiveLocation =>
      _useCustomLocation ? _customLocation : _profileLocation;

  String get _effectiveAddress {
    if (_useCustomLocation) {
      return _customAddress?.trim() ?? '';
    }
    return _profileAddress;
  }

  String _formatSchedule(DateTime value) {
    final local = value.toLocal();
    final date =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  void _recommendNearest(
    GeoLocation location, {
    bool selectRecommended = false,
  }) {
    final branches = _activeBranches;
    Branch? nearest;
    var nearestDistance = double.infinity;
    for (final branch in branches) {
      final branchLocation = branch.location;
      if (branchLocation == null) continue;
      final distance = haversineKm(
        lat1: location.latitude,
        lng1: location.longitude,
        lat2: branchLocation.latitude,
        lng2: branchLocation.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = branch;
      }
    }
    if (nearest == null) return;
    setState(() {
      _nearestBranchId = nearest!.id;
      if (selectRecommended || _selectedBranchId == null) {
        _selectedBranchId = nearest.id;
      }
    });
  }

  void _setUseCustomLocation(bool value) {
    setState(() {
      _useCustomLocation = value;
    });
    final location = value ? _customLocation : _profileLocation;
    if (location != null) {
      _recommendNearest(
        location,
        selectRecommended: value,
      );
    }
    if (!value) {
      final primary = context.read<AuthProvider>().user?.primaryBranchId;
      if (primary != null && primary.isNotEmpty) {
        setState(() => _selectedBranchId = primary);
      }
    }
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final initial = _scheduledFor ?? now.add(const Duration(hours: 2));
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!selected.isAfter(DateTime.now())) {
      AppSnackBar.warning(context, context.l10n.scheduledTimeMustBeFuture);
      return;
    }
    setState(() => _scheduledFor = selected);
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final address = _effectiveAddress;
    final location = _effectiveLocation;
    if (address.isEmpty) {
      AppSnackBar.warning(context, l10n.deliveryAddressRequired);
      return;
    }
    if (location == null) {
      AppSnackBar.warning(context, l10n.deliveryLocationRequired);
      return;
    }
    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      AppSnackBar.warning(context, l10n.selectABranch);
      return;
    }
    if (_orderType == OrderType.scheduled && _scheduledFor == null) {
      AppSnackBar.warning(context, l10n.selectScheduleDateTime);
      return;
    }

    final controller = context.read<OrdersController>();
    if (_orderType == OrderType.instant && controller.hasOpenInstantOrder) {
      AppSnackBar.warning(context, l10n.alreadyHaveInstantOrder);
      return;
    }
    if (_orderType == OrderType.scheduled && controller.hasOpenScheduledOrder) {
      AppSnackBar.warning(context, l10n.alreadyHaveScheduledOrder);
      return;
    }

    final result = await controller.placeOrder(
      product: widget.product,
      quantity: _quantity,
      paymentMethod: _paymentMethod,
      note: _noteController.text,
      branchId: _selectedBranchId!,
      deliveryAddress: address,
      deliveryLocation: location,
      isCustomDeliveryLocation: _useCustomLocation,
      orderType: _orderType,
      scheduledFor: _orderType == OrderType.scheduled ? _scheduledFor : null,
    );

    if (!mounted) return;
    switch (result) {
      case Success():
        Navigator.pop(context);
        AppSnackBar.success(
          context,
          _orderType == OrderType.scheduled
              ? 'Order scheduled'
              : 'Order placed',
        );
        context.go(CustomerRoutes.home);
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<OrdersController>();
    final product = widget.product;
    final total = product.effectivePrice * _quantity;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final branches = controller.branches
        .where((b) => b.status == BranchStatus.active)
        .toList();
    final location = _effectiveLocation;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              l10n.orderProductTitle(product.name),
              style: context.texts.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Rs ${product.effectivePrice.toStringAsFixed(0)} / ${product.unit}',
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.orderType,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            RadioListTile<OrderType>(
              value: OrderType.instant,
              groupValue: _orderType,
              onChanged: controller.hasOpenInstantOrder
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _orderType = value);
                      }
                    },
              title: Text(l10n.orderTypeInstant),
              subtitle: Text(
                controller.hasOpenInstantOrder
                    ? l10n.instantOrderOngoingHint
                    : l10n.instantOrderStartHint,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<OrderType>(
              value: OrderType.scheduled,
              groupValue: _orderType,
              onChanged: controller.hasOpenScheduledOrder
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _orderType = value;
                          _scheduledFor ??=
                              DateTime.now().add(const Duration(hours: 2));
                        });
                      }
                    },
              title: Text(l10n.orderTypeScheduled),
              subtitle: Text(
                controller.hasOpenScheduledOrder
                    ? l10n.scheduledOrderExistingHint
                    : l10n.scheduledOrderChooseHint,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (_orderType == OrderType.scheduled) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _pickSchedule,
                icon: const Icon(Icons.schedule),
                label: Text(
                  _scheduledFor == null
                      ? l10n.selectDateAndTime
                      : l10n.scheduledForLabel(_formatSchedule(_scheduledFor!)),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(l10n.quantity),
                const Spacer(),
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_quantity',
                  style: context.texts.titleMedium,
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.deliveryLocation,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioListTile<bool>(
              value: false,
              groupValue: _useCustomLocation,
              onChanged: (value) {
                if (value != null) _setUseCustomLocation(value);
              },
              title: Text(l10n.mySavedAddress),
              subtitle: Text(
                _profileAddress.isEmpty
                    ? l10n.noAddressOnProfile
                    : _profileAddress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<bool>(
              value: true,
              groupValue: _useCustomLocation,
              onChanged: (value) {
                if (value != null) _setUseCustomLocation(value);
              },
              title: Text(l10n.differentLocationForOrder),
              subtitle: Text(l10n.searchAndPinCustom),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_useCustomLocation) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: context.colors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.deliveringTo,
                          style: context.texts.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _profileAddress.isEmpty
                          ? l10n.noAddressOnYourProfile
                          : _profileAddress,
                      style: context.texts.bodyMedium,
                    ),
                    if (_profileLocation != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Lat ${_profileLocation!.latitude.toStringAsFixed(5)}, '
                        'Lng ${_profileLocation!.longitude.toStringAsFixed(5)}',
                        style: context.texts.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.sm),
              OrderLocationPicker(
                initial: _customLocation ?? _profileLocation,
                initialQuery: _customAddress,
                onChanged: (loc) {
                  setState(() => _customLocation = loc);
                  _recommendNearest(loc, selectRecommended: true);
                },
                onAddressSelected: (address) {
                  setState(() => _customAddress = address);
                },
              ),
              if (_customAddress != null && _customAddress!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.selectedCustomLocation(_customAddress!),
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.branch,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (branches.isEmpty)
              Text(
                l10n.noActiveBranches,
                style: TextStyle(color: context.colors.error),
              )
            else
              ...branches.map((branch) {
                final isNearest = branch.id == _nearestBranchId;
                final distance = location != null && branch.location != null
                    ? haversineKm(
                        lat1: location.latitude,
                        lng1: location.longitude,
                        lat2: branch.location!.latitude,
                        lng2: branch.location!.longitude,
                      )
                    : null;
                return RadioListTile<String>(
                  value: branch.id,
                  groupValue: _selectedBranchId,
                  onChanged: (value) =>
                      setState(() => _selectedBranchId = value),
                  title: Row(
                    children: [
                      Expanded(child: Text(branch.name)),
                      if (isNearest)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.recommended,
                            style: context.texts.labelSmall?.copyWith(
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    [
                      if (branch.address != null) branch.address!,
                      if (distance != null)
                        l10n.kmAway(distance.toStringAsFixed(1)),
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              }),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _noteController,
              labelText: l10n.extraNote,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Payment',
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.cod,
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) setState(() => _paymentMethod = value);
              },
              title: Text(PaymentMethod.cod.label),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.credit,
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) setState(() => _paymentMethod = value);
              },
              title: Text(PaymentMethod.credit.label),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Total: Rs ${total.toStringAsFixed(0)}',
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: controller.isSubmitting ? null : _submit,
              child: controller.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.placeOrder),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
