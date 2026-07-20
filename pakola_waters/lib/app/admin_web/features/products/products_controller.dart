import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

class ProductsController extends ChangeNotifier {
  ProductsController({required ProductRepository productRepository})
      : _productRepository = productRepository;

  final ProductRepository _productRepository;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _search = '';
  ProductStatus? _statusFilter;
  ProductCategory? _categoryFilter;
  double? _minPrice;
  double? _maxPrice;

  List<Product> get products {
    return _products.where((product) {
      final query = _search.toLowerCase();
      final matchesSearch = _search.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          (product.description ?? '').toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == null || product.status == _statusFilter;
      final matchesCategory =
          _categoryFilter == null || product.category == _categoryFilter;
      final price = product.effectivePrice;
      final matchesMin = _minPrice == null || price >= _minPrice!;
      final matchesMax = _maxPrice == null || price <= _maxPrice!;
      return matchesSearch &&
          matchesStatus &&
          matchesCategory &&
          matchesMin &&
          matchesMax;
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  ProductStatus? get statusFilter => _statusFilter;
  ProductCategory? get categoryFilter => _categoryFilter;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setStatusFilter(ProductStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(ProductCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setMinPrice(double? value) {
    _minPrice = value;
    notifyListeners();
  }

  void setMaxPrice(double? value) {
    _maxPrice = value;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _productRepository.listProducts();
    switch (result) {
      case Success<List<Product>>(:final value):
        _products = value;
      case FailureResult<List<Product>>(:final failure):
        _error = failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Result<Product>> create(Product product) async {
    final result = await _productRepository.createProduct(product);
    if (result case Success()) {
      await load();
    }
    return result;
  }

  Future<Result<Product>> update(Product product) async {
    final result = await _productRepository.updateProduct(product);
    if (result case Success()) {
      await load();
    }
    return result;
  }

  Future<Result<void>> delete(String productId) async {
    final result = await _productRepository.deleteProduct(productId);
    if (result case Success()) {
      await load();
    }
    return result;
  }
}
