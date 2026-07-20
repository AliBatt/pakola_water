import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> listProducts();
  Future<Result<Product>> createProduct(Product product);
  Future<Result<Product>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String productId);
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._productService);

  final ProductService _productService;

  @override
  Future<Result<List<Product>>> listProducts() =>
      _productService.listProducts();

  @override
  Future<Result<Product>> createProduct(Product product) =>
      _productService.createProduct(product);

  @override
  Future<Result<Product>> updateProduct(Product product) =>
      _productService.updateProduct(product);

  @override
  Future<Result<void>> deleteProduct(String productId) =>
      _productService.deleteProduct(productId);
}
