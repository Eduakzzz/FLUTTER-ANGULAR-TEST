import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_button.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa lista y total; las reglas permanecen en el notifier.
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi carrito'),
        actions: const [CartButton()],
      ),
      body: items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Precio: \$${item.product.price.toStringAsFixed(2)} · Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip:
                                        'Reducir cantidad de ${item.product.title}',
                                    // Deshabilita disminuir cuando la cantidad es uno.
                                    onPressed: item.quantity > 1
                                        ? () => ref
                                              .read(cartProvider.notifier)
                                              .updateQuantity(
                                                item.product.id,
                                                item.quantity - 1,
                                              )
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    semanticsLabel:
                                        'Cantidad: ${item.quantity}',
                                  ),
                                  IconButton(
                                    tooltip:
                                        'Aumentar cantidad de ${item.product.title}',
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          item.product.id,
                                          item.quantity + 1,
                                        ),
                                    icon: const Icon(Icons.add),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Quitar ${item.product.title}',
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .remove(item.product.id),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
