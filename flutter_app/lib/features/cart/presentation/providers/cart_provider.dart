import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  void add(Product product) {
    final exists = state.any((item) => item.product.id == product.id);
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

final cartCountProvider = Provider<int>(
  (ref) =>
      ref.watch(cartProvider).fold(0, (count, item) => count + item.quantity),
);

final cartTotalProvider = Provider<double>(
  (ref) =>
      ref.watch(cartProvider).fold(0, (total, item) => total + item.subtotal),
);
