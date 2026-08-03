import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _submit() async {
    final address = _effectiveAddress;
    final location = _effectiveLocation;
    if (address.isEmpty) {
      AppSnackBar.warning(context, 'Delivery address is required');
      return;
    }
    if (location == null) {
      AppSnackBar.warning(context, 'Delivery location is required');
      return;
    }
    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      AppSnackBar.warning(context, 'Select a branch');
      return;
    }

    final controller = context.read<OrdersController>();
    final result = await controller.placeOrder(
      product: widget.product,
      quantity: _quantity,
      paymentMethod: _paymentMethod,
      note: _noteController.text,
      branchId: _selectedBranchId!,
      deliveryAddress: address,
      deliveryLocation: location,
      isCustomDeliveryLocation: _useCustomLocation,
    );

    if (!mounted) return;
    switch (result) {
      case Success():
        Navigator.pop(context);
        AppSnackBar.success(context, 'Order placed');
        context.go(CustomerRoutes.home);
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Order ${product.name}',
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
            Row(
              children: [
                const Text('Quantity'),
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
              'Delivery location',
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
              title: const Text('My saved address'),
              subtitle: Text(
                _profileAddress.isEmpty
                    ? 'No address on profile'
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
              title: const Text('Different location for this order'),
              subtitle: const Text(
                'Search and pin a custom delivery point',
              ),
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
                          'Delivering to',
                          style: context.texts.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _profileAddress.isEmpty
                          ? 'No address on your profile'
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
                  'Selected: $_customAddress (custom location)',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Branch',
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (branches.isEmpty)
              Text(
                'No active branches available',
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
                            'Recommended',
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
                        '${distance.toStringAsFixed(1)} km away',
                    ].where((e) => e.isNotEmpty).join(' · '),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              }),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _noteController,
              labelText: 'Extra note (optional)',
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
                  : const Text('Place order'),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
