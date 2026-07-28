import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../../../shared/widgets/storage_network_image.dart';
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

  void _showDetails(
    BuildContext context,
    ProductsController controller,
    Product product,
  ) {
    showDetailsDialog(
      context: context,
      title: product.name,
      subtitle: product.sku,
      header: product.photoUrls.isEmpty
          ? null
          : SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: product.photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return StorageNetworkImage(
                    url: product.photoUrls[index],
                    width: 148,
                    height: 148,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  );
                },
              ),
            ),
      fields: [
        DetailField(
          label: 'SKU',
          value: product.sku,
          copyable: true,
          monospace: true,
          icon: Icons.qr_code_2,
        ),
        DetailField(
          label: 'Description',
          value: product.description ?? '',
          icon: Icons.description_outlined,
        ),
        DetailField(
          label: 'Price',
          value: 'Rs ${product.price.toStringAsFixed(0)}',
          copyable: true,
          icon: Icons.payments_outlined,
        ),
        DetailField(
          label: 'Special offer price',
          value: product.specialOfferPrice == null
              ? ''
              : 'Rs ${product.specialOfferPrice!.toStringAsFixed(0)}',
          copyable: product.hasOffer,
          icon: Icons.local_offer_outlined,
        ),
        DetailField(
          label: 'Category',
          value: product.category.label,
          icon: Icons.category_outlined,
        ),
        DetailField(
          label: 'Unit',
          value: product.unit,
          icon: Icons.straighten,
        ),
        DetailField(
          label: 'Status',
          value: product.status.name,
          icon: Icons.flag_outlined,
        ),
        DetailField(
          label: 'Product ID',
          value: product.id,
          copyable: true,
          monospace: true,
          icon: Icons.fingerprint,
        ),
        DetailField(
          label: 'Notes',
          value: product.notes ?? '',
          icon: Icons.notes_outlined,
        ),
      ],
      onEdit: () => showProductFormDialog(
        context: context,
        controller: controller,
        product: product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductsController>();
    final products = controller.products;
    final activeCount =
        products.where((p) => p.status == ProductStatus.active).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;

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
                          'Products',
                          style: context.texts.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Manage catalog items, pricing, offers, and photos.',
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
                    onPressed: () => showProductFormDialog(
                      context: context,
                      controller: controller,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(compact ? 'Create' : 'Create product'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(label: Text('Showing: ${products.length}')),
                  Chip(
                    backgroundColor: AppColors.success.withValues(alpha: 0.12),
                    label: Text('Active: $activeCount'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (compact) ...[
                AppTextField(
                  labelText: 'Search name, SKU, description…',
                  prefix: const Icon(Icons.search),
                  onChanged: controller.setSearch,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ProductStatus?>(
                        value: controller.statusFilter,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All statuses'),
                          ),
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
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: DropdownButtonFormField<ProductCategory?>(
                        value: controller.categoryFilter,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All categories'),
                          ),
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
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
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
                    Expanded(
                      child: AppTextField(
                        controller: _maxPriceController,
                        labelText: 'Max price',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          controller.setMaxPrice(double.tryParse(value));
                        },
                      ),
                    ),
                  ],
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        labelText: 'Search name, SKU, description…',
                        prefix: const Icon(Icons.search),
                        onChanged: controller.setSearch,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<ProductStatus?>(
                        value: controller.statusFilter,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All statuses'),
                          ),
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
                      width: 170,
                      child: DropdownButtonFormField<ProductCategory?>(
                        value: controller.categoryFilter,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All categories'),
                          ),
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
                    ? const LoadingView(message: 'Loading products...')
                    : products.isEmpty
                        ? const EmptyStateView(
                            title: 'No products found',
                            subtitle: 'Create a product to sell to customers.',
                            icon: Icons.inventory_2_outlined,
                          )
                        : Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                              itemCount: products.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  onTap: () => _showDetails(
                                    context,
                                    controller,
                                    product,
                                  ),
                                  leading: _ProductThumb(product: product),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(
                                        status: product.status.name,
                                      ),
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
                                            product.sku,
                                            product.category.label,
                                            product.unit,
                                          ].join(' · '),
                                        ),
                                        Text(
                                          product.hasOffer
                                              ? 'Offer Rs ${product.specialOfferPrice!.toStringAsFixed(0)}  (was Rs ${product.price.toStringAsFixed(0)})'
                                              : 'Rs ${product.price.toStringAsFixed(0)}',
                                          style: context.texts.bodySmall
                                              ?.copyWith(
                                            color: product.hasOffer
                                                ? AppColors.success
                                                : context
                                                    .colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  isThreeLine: true,
                                  trailing: Wrap(
                                    spacing: 0,
                                    children: [
                                      CopyValueButton(
                                        value: product.sku,
                                        label: 'SKU',
                                        icon: Icons.qr_code_2,
                                      ),
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
      },
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
        backgroundColor: context.colors.primaryContainer,
        child: Icon(
          Icons.water_drop,
          color: context.colors.onPrimaryContainer,
        ),
      );
    }
    return StorageNetworkImage(
      url: product.photoUrls.first,
      width: 52,
      height: 52,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      error: ColoredBox(
        color: context.colors.surfaceContainerHighest,
        child: Icon(
          Icons.water_drop,
          color: context.colors.primary,
        ),
      ),
    );
  }
}
