import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../widgets/product_tile.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Mini Catálogo')),
    body: ref
        .watch(productsProvider)
        .when(
          skipLoadingOnRefresh: false,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar los productos.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(productsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (products) => products.isEmpty
              ? const Center(child: Text('No hay productos disponibles.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      ProductTile(product: products[index]),
                ),
        ),
  );
}
