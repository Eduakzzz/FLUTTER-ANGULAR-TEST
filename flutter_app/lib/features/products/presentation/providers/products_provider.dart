import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import 'product_repository_provider.dart';
import 'search_query_provider.dart';

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  return query.isEmpty
      ? repository.getProducts()
      : repository.searchProducts(query);
}, retry: (retryCount, error) => null);
