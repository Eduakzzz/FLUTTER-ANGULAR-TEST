import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class CartButton extends ConsumerWidget {
  const CartButton({this.onPressed, super.key});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch mantiene el badge sincronizado con las cantidades.
    final count = ref.watch(cartCountProvider);
    return IconButton(
      tooltip: 'Carrito: $count unidades',
      onPressed: onPressed,
      icon: Badge(
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
