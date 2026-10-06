import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

// Controlador y estado; se conserva durante la navegación.
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  // @override reemplaza un método heredado; => devuelve la expresión.
  @override
  List<CartItem> build() => const [];

  void add(Product product) {
    final exists = state.any((item) => item.product.id == product.id);
    // Lista nueva y copyWith: mantiene intacto el estado anterior.
    state = List.unmodifiable([
      for (final item in state)
        if (item.product.id == product.id)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
      if (!exists) CartItem(product: product, quantity: 1),
    ]);
  }

  void remove(int productId) {
    state = List.unmodifiable(
      state.where((item) => item.product.id != productId),
    );
  }

  void updateQuantity(int productId, int quantity) {
    // Cantidad mínima uno; quitar utiliza una acción separada.
    if (quantity < 1) return;
    state = List.unmodifiable([
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ]);
  }
}

// fold acumula cantidades; el badge cuenta unidades.
final cartCountProvider = Provider<int>(
  (ref) =>
      ref.watch(cartProvider).fold(0, (count, item) => count + item.quantity),
);

// Valor derivado: suma precio por cantidad de cada fila.
final cartTotalProvider = Provider<double>(
  (ref) =>
      ref.watch(cartProvider).fold(0, (total, item) => total + item.subtotal),
);
