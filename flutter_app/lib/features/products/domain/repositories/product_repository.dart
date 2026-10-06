import '../entities/product.dart';

// Contrato de datos: declara operaciones sin decidir su implementación.
abstract interface class ProductRepository {
  // Future<List<Product>>: resultado futuro con una lista de productos.
  Future<List<Product>> getProducts({int limit = 20, int skip = 0});

  Future<List<Product>> searchProducts(String query);

  Future<Product> getProductById(int id);
}
