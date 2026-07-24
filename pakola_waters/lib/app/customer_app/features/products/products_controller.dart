import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

class ProductsController extends ChangeNotifier {
  ProductsController(this._productRepository);

  final ProductRepository _productRepository;

  List<Product> _products = [];
  String _search = '';
  bool _isLoading = false;
  String? _error;

  List<Product> get products {
    final query = _search.trim().toLowerCase();
    final active = _products
        .where((product) => product.status == ProductStatus.active)
        .toList();
    if (query.isEmpty) return active;
    return active
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query) ||
              (product.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

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

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }
}
