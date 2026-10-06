import 'package:flutter_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_product_repository.dart';

const secondProduct = Product(
  id: 2,
  title: 'Otro producto de prueba',
  description: 'Descripción de prueba',
  category: 'beauty',
  price: 7.25,
  rating: 4,
  thumbnail: 'https://example.com/second-product.png',
);

void main() {
  test('agrega un producto y actualiza cantidad y total derivados', () {
    final container = ProviderContainer.test();
    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartCountProvider), 0);
    expect(container.read(cartTotalProvider), 0);

    container.read(cartProvider.notifier).add(sampleProduct);

    final items = container.read(cartProvider);
    expect(items, hasLength(1));
    expect(items.single.product, same(sampleProduct));
    expect(items.single.quantity, 1);
    expect(container.read(cartCountProvider), 1);
    expect(container.read(cartTotalProvider), 12.5);
  });

  test('agregar el mismo producto incrementa sin duplicar la fila', () {
    final container = ProviderContainer.test();
    final cart = container.read(cartProvider.notifier);

    cart.add(sampleProduct);
    cart.add(sampleProduct);

    expect(container.read(cartProvider), hasLength(1));
    expect(container.read(cartProvider).single.quantity, 2);
    expect(container.read(cartCountProvider), 2);
    expect(container.read(cartTotalProvider), 25);
  });

  test('actualiza cantidad y calcula el total de productos distintos', () {
    final container = ProviderContainer.test();
    final cart = container.read(cartProvider.notifier);
    cart.add(sampleProduct);
    cart.add(secondProduct);
    expect(container.read(cartCountProvider), 2);
    expect(container.read(cartTotalProvider), 19.75);

    cart.updateQuantity(sampleProduct.id, 3);

    final items = container.read(cartProvider);
    expect(items, hasLength(2));
    expect(items.first.quantity, 3);
    expect(items.first.subtotal, 37.5);
    expect(items.last.quantity, 1);
    expect(container.read(cartCountProvider), 4);
    expect(container.read(cartTotalProvider), 44.75);
  });

  test('ignora cantidades inferiores a uno', () {
    final container = ProviderContainer.test();
    final cart = container.read(cartProvider.notifier);
    cart.add(sampleProduct);
    final snapshot = container.read(cartProvider);

    cart.updateQuantity(sampleProduct.id, 0);
    cart.updateQuantity(sampleProduct.id, -1);

    expect(container.read(cartProvider), same(snapshot));
    expect(container.read(cartProvider).single.quantity, 1);
    expect(container.read(cartCountProvider), 1);
    expect(container.read(cartTotalProvider), 12.5);
  });

  test('elimina solo el producto solicitado y permite vaciar el carrito', () {
    final container = ProviderContainer.test();
    final cart = container.read(cartProvider.notifier);
    cart.add(sampleProduct);
    cart.add(secondProduct);
    cart.add(secondProduct);

    cart.remove(sampleProduct.id);

    expect(container.read(cartProvider), hasLength(1));
    expect(container.read(cartProvider).single.product.id, secondProduct.id);
    expect(container.read(cartCountProvider), 2);
    expect(container.read(cartTotalProvider), 14.5);

    cart.remove(secondProduct.id);

    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartCountProvider), 0);
    expect(container.read(cartTotalProvider), 0);
  });

  test('las actualizaciones conservan los snapshots anteriores inmutables', () {
    final container = ProviderContainer.test();
    final cart = container.read(cartProvider.notifier);
    cart.add(sampleProduct);
    final firstSnapshot = container.read(cartProvider);
    final originalItem = firstSnapshot.single;

    cart.add(sampleProduct);
    final secondSnapshot = container.read(cartProvider);

    expect(secondSnapshot, isNot(same(firstSnapshot)));
    expect(firstSnapshot.single, same(originalItem));
    expect(firstSnapshot.single.quantity, 1);
    expect(secondSnapshot.single.quantity, 2);
    expect(secondSnapshot.single, isNot(same(originalItem)));
    expect(() => firstSnapshot.clear(), throwsUnsupportedError);
    expect(() => secondSnapshot.add(originalItem), throwsUnsupportedError);

    cart.updateQuantity(sampleProduct.id, 4);
    cart.remove(sampleProduct.id);

    expect(firstSnapshot.single.quantity, 1);
    expect(secondSnapshot.single.quantity, 2);
    expect(container.read(cartProvider), isEmpty);
  });
}
