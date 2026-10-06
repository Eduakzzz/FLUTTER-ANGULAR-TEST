import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/search_query_provider.dart';
import '../widgets/product_tile.dart';
import 'product_details_page.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Mini Catálogo')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar productos',
              hintText: 'Nombre o descripción',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: ref.read(searchQueryProvider.notifier).updateQuery,
          ),
        ),
        Expanded(
          child: ref
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
                        itemBuilder: (context, index) => ProductTile(
                          product: products[index],
                          onTap: () => Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                productId: products[index].id,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
        ),
      ],
    ),
  );
}
