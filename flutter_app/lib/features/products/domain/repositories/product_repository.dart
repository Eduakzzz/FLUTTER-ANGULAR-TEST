import '../entities/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> getProducts({int limit = 20, int skip = 0});

  Future<Product> getProductById(int id);
}
