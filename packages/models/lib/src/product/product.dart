import '../enums/product_category.dart';
import '../enums/product_status.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.category,
    required this.status,
    this.description,
    this.specialOfferPrice,
    this.photoUrls = const [],
    this.unit = 'gallon',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ??
          (json['basePrice'] as num?)?.toDouble() ??
          0,
      specialOfferPrice: (json['specialOfferPrice'] as num?)?.toDouble(),
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['imageUrl'] != null
              ? [json['imageUrl'] as String]
              : const <String>[]),
      category: ProductCategory.fromString(
        json['category'] as String? ?? 'other',
      ),
      status: ProductStatus.fromString(json['status'] as String? ?? 'inactive'),
      unit: json['unit'] as String? ?? 'gallon',
      notes: json['notes'] as String?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  final String id;
  final String name;
  final String sku;
  final String? description;
  final double price;
  final double? specialOfferPrice;
  final List<String> photoUrls;
  final ProductCategory category;
  final ProductStatus status;
  final String unit;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  double get effectivePrice => specialOfferPrice ?? price;

  bool get hasOffer =>
      specialOfferPrice != null && specialOfferPrice! > 0 && specialOfferPrice! < price;

  Map<String, dynamic> toJson() => {
        'name': name,
        'sku': sku,
        'description': description,
        'price': price,
        'basePrice': price,
        'specialOfferPrice': specialOfferPrice,
        'photoUrls': photoUrls,
        'imageUrl': photoUrls.isNotEmpty ? photoUrls.first : null,
        'category': category.name,
        'status': status.name,
        'unit': unit,
        'notes': notes,
      };

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? description,
    double? price,
    double? specialOfferPrice,
    List<String>? photoUrls,
    ProductCategory? category,
    ProductStatus? status,
    String? unit,
    String? notes,
    bool clearSpecialOffer = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      price: price ?? this.price,
      specialOfferPrice: clearSpecialOffer
          ? null
          : (specialOfferPrice ?? this.specialOfferPrice),
      photoUrls: photoUrls ?? this.photoUrls,
      category: category ?? this.category,
      status: status ?? this.status,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
