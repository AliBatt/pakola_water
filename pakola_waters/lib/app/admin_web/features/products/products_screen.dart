import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import 'product_form_dialog.dart';
import 'product_image_uploader.dart';
import 'products_controller.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsController>().load();
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductsController>();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  labelText: 'Search products',
                  prefix: const Icon(Icons.search),
                  onChanged: controller.setSearch,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<ProductStatus?>(
                  value: controller.statusFilter,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(
                      value: ProductStatus.active,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: ProductStatus.inactive,
                      child: Text('Inactive'),
                    ),
                    DropdownMenuItem(
                      value: ProductStatus.discontinued,
                      child: Text('Discontinued'),
                    ),
                  ],
                  onChanged: controller.setStatusFilter,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<ProductCategory?>(
                  value: controller.categoryFilter,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...ProductCategory.values.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    ),
                  ],
                  onChanged: controller.setCategoryFilter,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 110,
                child: AppTextField(
                  controller: _minPriceController,
                  labelText: 'Min price',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    controller.setMinPrice(double.tryParse(value));
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 110,
                child: AppTextField(
                  controller: _maxPriceController,
                  labelText: 'Max price',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    controller.setMaxPrice(double.tryParse(value));
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => showProductFormDialog(
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
                : controller.products.isEmpty
                    ? const EmptyStateView(
                        title: 'No products',
                        subtitle: 'Create a product to sell to customers.',
                      )
                    : Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          itemCount: controller.products.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final product = controller.products[index];
                            return ListTile(
                              onTap: () => _showDetails(
                                context,
                                controller,
                                product,
                              ),
                              leading: _ProductThumb(product: product),
                              title: Text(product.name),
                              subtitle: Text(
                                [
                                  product.sku,
                                  product.category.label,
                                  if (product.hasOffer)
                                    'Offer Rs ${product.specialOfferPrice!.toStringAsFixed(0)}'
                                  else
                                    'Rs ${product.price.toStringAsFixed(0)}',
                                  product.status.name,
                                ].join(' · '),
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () => showProductFormDialog(
                                      context: context,
                                      controller: controller,
                                      product: product,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDelete(
                                      context,
                                      controller,
                                      product,
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

  Future<void> _showDetails(
    BuildContext context,
    ProductsController controller,
    Product product,
  ) {
    return showDetailsDialog(
      context: context,
      title: product.name,
      header: product.photoUrls.isEmpty
          ? null
          : SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: product.photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Image.network(
                      product.photoUrls[index],
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
      fields: [
        DetailField(label: 'SKU', value: product.sku),
        DetailField(label: 'Description', value: product.description ?? ''),
        DetailField(
          label: 'Price',
          value: 'Rs ${product.price.toStringAsFixed(0)}',
        ),
        DetailField(
          label: 'Special offer price',
          value: product.specialOfferPrice == null
              ? ''
              : 'Rs ${product.specialOfferPrice!.toStringAsFixed(0)}',
        ),
        DetailField(label: 'Category', value: product.category.label),
        DetailField(label: 'Unit', value: product.unit),
        DetailField(label: 'Status', value: product.status.name),
        DetailField(label: 'Notes', value: product.notes ?? ''),
      ],
      onEdit: () => showProductFormDialog(
        context: context,
        controller: controller,
        product: product,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductsController controller,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove ${product.name}?'),
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

    final uploader = ProductImageUploader();
    await uploader.deleteUrls(product.photoUrls);

    final result = await controller.delete(product.id);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        AppSnackBar.success(context, 'Product deleted');
      case FailureResult(:final failure):
        AppSnackBar.error(context, failure.message);
    }
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.photoUrls.isEmpty) {
      return CircleAvatar(
        child: Icon(Icons.water_drop, color: context.colors.primary),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.network(
        product.photoUrls.first,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }
}
