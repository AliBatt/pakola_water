import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:utilities/utilities.dart';

import 'admin_orders_controller.dart';

Future<void> showAdminCreateManualOrderDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AdminCreateManualOrderDialog(),
  );
}

class AdminCreateManualOrderDialog extends StatefulWidget {
  const AdminCreateManualOrderDialog({super.key});

  @override
  State<AdminCreateManualOrderDialog> createState() =>
      _AdminCreateManualOrderDialogState();
}

class _AdminCreateManualOrderDialogState
    extends State<AdminCreateManualOrderDialog> {
  final _noteController = TextEditingController();
  final _addressController = TextEditingController();
  final _customerSearchController = TextEditingController();

  AppUser? _customer;
  Product? _product;
  Branch? _branch;
  AppUser? _supervisor;
  AppUser? _rider;
  int _quantity = 1;
  PaymentMethod _paymentMethod = PaymentMethod.cod;
  DateTime _eta = DateTime.now().add(const Duration(minutes: 45));
  String _customerQuery = '';
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  void _onCustomerSelected(AppUser customer, AdminOrdersController controller) {
    setState(() {
      _customer = customer;
      _customerQuery = customer.displayName;
      _customerSearchController.text = customer.displayName;
      _addressController.text = customer.address ?? '';
      final preferred = customer.primaryBranchId ??
          (customer.branchIds.isNotEmpty ? customer.branchIds.first : null);
      _branch = controller.branchById(preferred) ??
          (controller.branches.isNotEmpty ? controller.branches.first : null);
      _supervisor = null;
      _rider = null;
    });
  }

  Future<void> _pickEta() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eta,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
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

  Future<void> _submit(AdminOrdersController controller) async {
    final admin = context.read<AuthProvider>().user;
    if (admin == null) {
      AppSnackBar.error(context, 'Not signed in');
      return;
    }
    if (_customer == null) {
      AppSnackBar.warning(context, 'Select a customer');
      return;
    }
    if (_product == null) {
      AppSnackBar.warning(context, 'Select a product');
      return;
    }
    if (_branch == null) {
      AppSnackBar.warning(context, 'Select a branch');
      return;
    }
    if (_supervisor == null) {
      AppSnackBar.warning(context, 'Select a supervisor');
      return;
    }
    if (_rider == null) {
      AppSnackBar.warning(context, 'Select a rider');
      return;
    }

    setState(() => _submitting = true);
    final result = await controller.createManualOrder(
      admin: admin,
      customer: _customer!,
      product: _product!,
      branch: _branch!,
      supervisor: _supervisor!,
      rider: _rider!,
      quantity: _quantity,
      paymentMethod: _paymentMethod,
      estimatedArrivalAt: _eta,
      note: _noteController.text,
      deliveryAddress: _addressController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    switch (result) {
      case Success():
        Navigator.pop(context);
        AppSnackBar.success(
          context,
          'Manual order created and assigned to ${_rider!.displayName}',
        );
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }

  List<AppUser> _filteredCustomers(AdminOrdersController controller) {
    final query = _customerQuery.trim().toLowerCase();
    final all = controller.customers;
    if (query.isEmpty) return all.take(40).toList();
    return all
        .where((user) {
          final haystack = [
            user.displayName,
            user.email,
            user.phone ?? '',
            user.id,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .take(40)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminOrdersController>();
    final supervisors = controller.supervisorsForBranch(_branch?.id);
    final riders = controller.ridersForBranch(_branch?.id);
    final total = (_product?.effectivePrice ?? 0) * _quantity;
    final busy = _submitting || controller.isActing;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 860),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                          'Create manual order',
                          style: context.texts.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'For customers who ordered outside the app',
                          style: context.texts.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: busy ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Customer',
                        style: context.texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        controller: _customerSearchController,
                        labelText: 'Search customer by name, phone, email…',
                        prefix: const Icon(Icons.search),
                        onChanged: (value) {
                          setState(() {
                            _customerQuery = value;
                            if (_customer != null &&
                                value.trim() != _customer!.displayName) {
                              _customer = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: Material(
                          color: context.colors.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _filteredCustomers(controller).length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final customer =
                                  _filteredCustomers(controller)[index];
                              final selected = _customer?.id == customer.id;
                              return ListTile(
                                dense: true,
                                selected: selected,
                                leading: Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.person_outline,
                                ),
                                title: Text(customer.displayName),
                                subtitle: Text(
                                  [
                                    customer.phone ?? customer.email,
                                    if (customer.address != null)
                                      customer.address!,
                                  ].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () =>
                                    _onCustomerSelected(customer, controller),
                              );
                            },
                          ),
                        ),
                      ),
                      if (_customer != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Selected: ${_customer!.displayName}'
                          '${_customer!.phone != null ? ' · ${_customer!.phone}' : ''}',
                          style: context.texts.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Order details',
                        style: context.texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _product?.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Product *',
                        ),
                        items: controller.products
                            .map(
                              (product) => DropdownMenuItem(
                                value: product.id,
                                child: Text(
                                  '${product.name} · Rs ${product.effectivePrice.toStringAsFixed(0)}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _product = controller.products
                                .where((p) => p.id == id)
                                .firstOrNull;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
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
                      Text(
                        'Total: Rs ${total.toStringAsFixed(0)}',
                        style: context.texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<PaymentMethod>(
                        value: _paymentMethod,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Payment method *',
                        ),
                        items: PaymentMethod.values
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _paymentMethod = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _branch?.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Branch *',
                        ),
                        items: controller.branches
                            .map(
                              (branch) => DropdownMenuItem(
                                value: branch.id,
                                child: Text(branch.name),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _branch = controller.branchById(id);
                            _supervisor = null;
                            _rider = null;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _addressController,
                        labelText: 'Delivery address',
                        maxLines: 2,
                        prefix: const Icon(Icons.place_outlined),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _noteController,
                        labelText: 'Extra note (optional)',
                        maxLines: 2,
                        prefix: const Icon(Icons.notes_outlined),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Assignment',
                        style: context.texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _supervisor != null &&
                                supervisors.any((s) => s.id == _supervisor!.id)
                            ? _supervisor!.id
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Supervisor *',
                        ),
                        items: supervisors
                            .map(
                              (user) => DropdownMenuItem(
                                value: user.id,
                                child: Text(user.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _supervisor = supervisors
                                .where((s) => s.id == id)
                                .firstOrNull;
                          });
                        },
                      ),
                      if (supervisors.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'No active supervisors for this branch',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _rider != null &&
                                riders.any((r) => r.id == _rider!.id)
                            ? _rider!.id
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Rider / driver *',
                        ),
                        items: riders
                            .map(
                              (user) => DropdownMenuItem(
                                value: user.id,
                                child: Text(
                                  [
                                    user.displayName,
                                    if (user.phone != null) user.phone!,
                                  ].join(' · '),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _rider =
                                riders.where((r) => r.id == id).firstOrNull;
                          });
                        },
                      ),
                      if (riders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'No active riders for this branch',
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Estimated arrival'),
                        subtitle: Text(
                          DateTimeFormatter.formatDateTime(_eta),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.schedule),
                          onPressed: _pickEta,
                        ),
                        onTap: _pickEta,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: busy ? null : () => _submit(controller),
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_shopping_cart),
                      label: Text(busy ? 'Creating…' : 'Create & assign'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
