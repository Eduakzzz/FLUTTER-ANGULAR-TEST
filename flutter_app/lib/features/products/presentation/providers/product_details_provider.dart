import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import 'product_repository_provider.dart';

// family separa consultas por ID: devuelve Product y recibe int.
final productDetailsProvider = FutureProvider.autoDispose.family<Product, int>(
  (ref, id) => ref.watch(productRepositoryProvider).getProductById(id),
  retry: (retryCount, error) => null,
);
