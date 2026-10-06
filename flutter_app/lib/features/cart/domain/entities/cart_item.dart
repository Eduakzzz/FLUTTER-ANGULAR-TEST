import '../../../products/domain/entities/product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity});
  final Product product;
  final int quantity;
  double get subtotal => product.price * quantity;

  // copyWith crea otra instancia; ?? conserva la cantidad si llega null.
  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}
