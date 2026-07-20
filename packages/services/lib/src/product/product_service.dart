import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

abstract class ProductService {
  Future<Result<List<Product>>> listProducts();
  Future<Result<Product>> createProduct(Product product);
  Future<Result<Product>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String productId);
}

class ProductServiceImpl implements ProductService {
  ProductServiceImpl(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<Result<List<Product>>> listProducts() async {
    try {
      final snapshot =
          await _firestoreService.collection(CollectionPaths.products).get();
      final products = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return Success(products);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<Product>> createProduct(Product product) async {
    try {
      final docRef =
          _firestoreService.collection(CollectionPaths.products).doc();
      final data = product.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
      return Success(product.copyWith(id: docRef.id));
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<Product>> updateProduct(Product product) async {
    try {
      final data = product.toJson()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await _firestoreService.setDoc(
        CollectionPaths.products,
        product.id,
        data,
        merge: true,
      );
      return Success(product);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String productId) async {
    try {
      await _firestoreService.deleteDoc(CollectionPaths.products, productId);
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }
}
