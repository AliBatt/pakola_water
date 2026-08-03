import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:shared_widgets/shared_widgets.dart';

import '../../../../shared/widgets/storage_network_image.dart';
import '../notifications/notifications_bell_button.dart';
import '../orders/orders_controller.dart';
import '../orders/place_order_sheet.dart';
import 'products_controller.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsController = context.watch<ProductsController>();
    final ordersController = context.watch<OrdersController>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProducts),
        actions: const [NotificationsBellButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            AppTextField(
              labelText: l10n.search,
              prefix: const Icon(Icons.search),
              onChanged: productsController.setSearch,
            ),
            const SizedBox(height: AppSpacing.md),
            if (productsController.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  productsController.error!,
                  style: TextStyle(color: context.colors.error),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: productsController.load,
                child: productsController.isLoading &&
                        productsController.products.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 240,
                            child: LoadingView(),
                          ),
                        ],
                      )
                    : productsController.products.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.45,
                                child: EmptyStateView(
                                  title: l10n.noProducts,
                                  subtitle: l10n.noProductsSubtitle,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: productsController.products.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final product =
                                productsController.products[index];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(
                                  AppSpacing.md,
                                ),
                                leading: product.photoUrls.isEmpty
                                    ? CircleAvatar(
                                        child: Icon(
                                          Icons.water_drop,
                                          color: context.colors.primary,
                                        ),
                                      )
                                    : StorageNetworkImage(
                                        url: product.photoUrls.first,
                                        width: 48,
                                        height: 48,
                                        borderRadius: BorderRadius.circular(8),
                                        error: CircleAvatar(
                                          child: Icon(
                                            Icons.water_drop,
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      ),
                                title: Text(product.name),
                                subtitle: Text(
                                  [
                                    if (product.hasOffer)
                                      'Offer Rs ${product.specialOfferPrice!.toStringAsFixed(0)}'
                                    else
                                      'Rs ${product.price.toStringAsFixed(0)}',
                                    product.unit,
                                    if (product.description != null)
                                      product.description!,
                                  ].join(' · '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: FilledButton(
                                  onPressed: () {
                                    if (!ordersController.canPlaceOrder) {
                                      AppSnackBar.warning(
                                        context,
                                        'You already have an instant and a scheduled order',
                                      );
                                      return;
                                    }
                                    showPlaceOrderSheet(
                                      context: context,
                                      product: product,
                                    );
                                  },
                                  child: Text(l10n.order),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
