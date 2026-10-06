import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) {
    return _remoteDataSource.fetchProducts(limit: limit, skip: skip);
  }

  @override
  Future<Product> getProductById(int id) {
    return _remoteDataSource.fetchProductById(id);
  }
}
