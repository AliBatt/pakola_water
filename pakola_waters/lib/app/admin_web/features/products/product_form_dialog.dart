import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:uuid/uuid.dart';

import 'product_image_uploader.dart';
import 'products_controller.dart';

Future<void> showProductFormDialog({
  required BuildContext context,
  required ProductsController controller,
  Product? product,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProductFormDialog(
      controller: controller,
      product: product,
    ),
  );
}

class _PhotoSlot {
  const _PhotoSlot({this.url, this.bytes});

  final String? url;
  final Uint8List? bytes;

  bool get isEmpty => url == null && bytes == null;
}

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    super.key,
    required this.controller,
    this.product,
  });

  final ProductsController controller;
  final Product? product;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerController = TextEditingController();
  final _unitController = TextEditingController(text: 'gallon');
  final _notesController = TextEditingController();
  final _uploader = ProductImageUploader();

  ProductCategory _category = ProductCategory.water;
  ProductStatus _status = ProductStatus.active;
  final List<_PhotoSlot> _photos = [];
  final List<String> _removedUrls = [];
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _skuController.text = product.sku;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toStringAsFixed(0);
      _offerController.text = product.specialOfferPrice?.toStringAsFixed(0) ?? '';
      _unitController.text = product.unit;
      _notesController.text = product.notes ?? '';
      _category = product.category;
      _status = product.status;
      for (final url in product.photoUrls.take(ProductImageUploader.maxPhotos)) {
        _photos.add(_PhotoSlot(url: url));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _offerController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= ProductImageUploader.maxPhotos) {
      AppSnackBar.warning(context, 'Maximum 2 photos allowed');
      return;
    }
    final file = await _uploader.pickImage();
    if (file == null) return;
    final bytes = await _uploader.compress(file);
    setState(() => _photos.add(_PhotoSlot(bytes: bytes)));
  }

  void _removePhoto(int index) {
    final slot = _photos[index];
    if (slot.url != null) {
      _removedUrls.add(slot.url!);
    }
    setState(() => _photos.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      AppSnackBar.error(context, 'Enter a valid price');
      return;
    }

    final offerText = _offerController.text.trim();
    double? offer;
    if (offerText.isNotEmpty) {
      offer = double.tryParse(offerText);
      if (offer == null || offer <= 0) {
        AppSnackBar.error(context, 'Enter a valid special offer price');
        return;
      }
      if (offer >= price) {
        AppSnackBar.error(
          context,
          'Special offer must be lower than regular price',
        );
        return;
      }
    }

    setState(() => _saving = true);

    try {
      final productKey = widget.product?.id ?? const Uuid().v4();
      final urls = <String>[];

      for (final photo in _photos) {
        if (photo.url != null) {
          urls.add(photo.url!);
        } else if (photo.bytes != null) {
          final uploaded = await _uploader.upload(
            productKey: productKey,
            bytes: photo.bytes!,
          );
          urls.add(uploaded);
        }
      }

      final draft = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        sku: _skuController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        specialOfferPrice: offer,
        photoUrls: urls,
        category: _category,
        status: _status,
        unit: _unitController.text.trim().isEmpty
            ? 'gallon'
            : _unitController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final result = _isEditing
          ? await widget.controller.update(draft)
          : await widget.controller.create(draft);

      if (_removedUrls.isNotEmpty) {
        await _uploader.deleteUrls(_removedUrls);
      }

      if (!mounted) return;
      setState(() => _saving = false);

      switch (result) {
        case Success():
          Navigator.of(context).pop();
          AppSnackBar.success(
            context,
            _isEditing ? 'Product updated' : 'Product created',
          );
        case FailureResult(:final failure):
          AppSnackBar.error(context, failure.message);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 820),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit product' : 'Create product',
                        style: context.texts.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          labelText: 'Product name *',
                          prefix: const Icon(Icons.water_drop_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Product name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _skuController,
                          labelText: 'SKU *',
                          prefix: const Icon(Icons.qr_code_2),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'SKU is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          maxLines: 3,
                          prefix: const Icon(Icons.description_outlined),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _priceController,
                                labelText: 'Price *',
                                keyboardType: TextInputType.number,
                                prefix: const Icon(Icons.payments_outlined),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Price is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppTextField(
                                controller: _offerController,
                                labelText: 'Special offer price',
                                keyboardType: TextInputType.number,
                                prefix: const Icon(Icons.local_offer_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<ProductCategory>(
                          value: _category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: ProductCategory.values
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _category = value);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _unitController,
                          labelText: 'Unit',
                          hintText: 'gallon, bottle, piece',
                          prefix: const Icon(Icons.straighten),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<ProductStatus>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
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
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Photos (max 2, compressed)',
                          style: context.texts.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ...List.generate(_photos.length, (index) {
                              final photo = _photos[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                    child: SizedBox(
                                      width: 96,
                                      height: 96,
                                      child: photo.bytes != null
                                          ? Image.memory(
                                              photo.bytes!,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              photo.url!,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Material(
                                      color: Colors.black54,
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => _removePhoto(index),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            if (_photos.length < ProductImageUploader.maxPhotos)
                              OutlinedButton(
                                onPressed: _saving ? null : _addPhoto,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(96, 96),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined),
                                    SizedBox(height: 4),
                                    Text('Add'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _notesController,
                          labelText: 'Notes',
                          maxLines: 2,
                          prefix: const Icon(Icons.notes_outlined),
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
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isEditing ? 'Save' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
