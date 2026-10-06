import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/presentation/providers/product_details_provider.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_app/features/products/presentation/providers/products_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_product_repository.dart';

void main() {
  ProviderContainer containerFor(FakeProductRepository repository) =>
      ProviderContainer.test(
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
      );

  test('listado obtiene datos del repositorio sobrescrito', () async {
    final repository = FakeProductRepository();
    final container = containerFor(repository);
    container.listen(productsProvider, (previous, next) {});
    expect(await container.read(productsProvider.future), repository.products);
    expect(repository.listCalls, 1);
  });

  test('family mantiene resultados independientes según el ID', () async {
    const other = Product(
      id: 2,
      title: 'Otro',
      description: 'Descripción',
      category: 'beauty',
      price: 7,
      rating: 4,
      thumbnail: 'https://example.com/other.png',
    );
    final repository = FakeProductRepository()
      ..products = [sampleProduct, other];
    final container = containerFor(repository);
    container.listen(productDetailsProvider(1), (previous, next) {});
    container.listen(productDetailsProvider(2), (previous, next) {});
    expect(
      await container.read(productDetailsProvider(1).future),
      same(sampleProduct),
    );
    expect(await container.read(productDetailsProvider(2).future), same(other));
    expect(repository.detailIds, [1, 2]);
    expect(
      await container.read(productDetailsProvider(1).future),
      same(sampleProduct),
    );
    expect(repository.detailIds, [1, 2]);
  });

  test('error se expone en AsyncValue y el reintento es explícito', () async {
    final failure = Exception('Sin red');
    final repository = FakeProductRepository()..error = failure;
    final container = containerFor(repository);
    container.listen(productsProvider, (previous, next) {});
    await expectLater(
      container.read(productsProvider.future),
      throwsA(same(failure)),
    );
    expect(container.read(productsProvider).hasError, isTrue);
    expect(repository.listCalls, 1);
    repository.error = null;
    container.invalidate(productsProvider);
    expect(await container.read(productsProvider.future), repository.products);
    expect(repository.listCalls, 2);
  });
}
