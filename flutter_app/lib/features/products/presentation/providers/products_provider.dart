import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import 'product_repository_provider.dart';

final productsProvider = FutureProvider.autoDispose<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).getProducts(),
  retry: (retryCount, error) => null,
);
