import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../routing/customer_routes.dart';
import '../orders/orders_controller.dart';

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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = context.read<OrdersController>();
    final result = await controller.placeOrder(
      product: widget.product,
      quantity: _quantity,
      paymentMethod: _paymentMethod,
      note: _noteController.text,
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
    );
  }
}
