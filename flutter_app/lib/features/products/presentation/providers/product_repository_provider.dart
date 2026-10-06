import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http; // as define el alias http.

import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';

// Provider<ProductRepository> expone una dependencia de ese tipo.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = http.Client();
  // onDispose libera el recurso al desechar este provider.
  ref.onDispose(client.close);

  return ProductRepositoryImpl(ProductRemoteDataSource(client));
});
