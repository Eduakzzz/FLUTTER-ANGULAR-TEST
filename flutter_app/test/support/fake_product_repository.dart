import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';

const sampleProduct = Product(
  id: 1,
  title: 'Producto de prueba',
  description: 'Descripción de prueba',
  category: 'beauty',
  price: 12.5,
  rating: 4.2,
  thumbnail: 'https://example.com/product.png',
);

class FakeProductRepository implements ProductRepository {
  List<Product> products = [sampleProduct];
  Object? error;
  int listCalls = 0;
  final List<String> searchQueries = [];

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchQueries.add(query);
    if (error case final failure?) throw failure;
    return products;
  }

  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async {
    listCalls++;
    if (error case final failure?) throw failure;
    return products;
  }

  @override
  Future<Product> getProductById(int id) async {
    if (error case final failure?) throw failure;
    return products.firstWhere((product) => product.id == id);
  }
}
