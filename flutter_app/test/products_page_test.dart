import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/presentation/pages/products_page.dart';
import 'package:flutter_app/features/products/presentation/providers/product_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_product_repository.dart';

void main() {
  Future<void> mount(WidgetTester tester, FakeProductRepository repository) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [productRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: ProductsPage()),
        ),
      );

  testWidgets('muestra carga y después productos', (tester) async {
    final repository = FakeProductRepository();
    await mount(tester, repository);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(sampleProduct.title), findsOneWidget);
    expect(find.textContaining('12.50'), findsOneWidget);
    expect(repository.listCalls, 1);
  });

  testWidgets('muestra vacío', (tester) async {
    await mount(tester, FakeProductRepository()..products = []);
    await tester.pumpAndSettle();
    expect(find.text('No hay productos disponibles.'), findsOneWidget);
  });

  testWidgets('desmontar cancela el debounce pendiente', (tester) async {
    final repository = FakeProductRepository();
    await mount(tester, repository);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'phone');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 400));
    expect(repository.searchQueries, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('una respuesta vieja no reemplaza la búsqueda actual', (
    tester,
  ) async {
    final repository = ControlledSearchRepository();
    await mount(tester, repository);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'old');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'new');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    repository.pending['new']!.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('No hay productos disponibles.'), findsOneWidget);
    repository.pending['old']!.complete([sampleProduct]);
    await tester.pumpAndSettle();
    expect(find.text(sampleProduct.title), findsNothing);
    expect(find.text('No hay productos disponibles.'), findsOneWidget);
  });

  testWidgets('carrito conserva cantidades y contador entre pantallas', (
    tester,
  ) async {
    await mount(tester, FakeProductRepository());
    await tester.pumpAndSettle();
    await tester.tap(find.text(sampleProduct.title));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Agregar al carrito'));
    await tester.tap(find.text('Agregar al carrito'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Carrito: 1 unidades'), findsOneWidget);
    await tester.tap(find.byTooltip('Carrito: 1 unidades'));
    await tester.pumpAndSettle();
    expect(find.text('Total: \$12.50'), findsOneWidget);
    await tester.tap(find.byTooltip('Aumentar cantidad de Producto de prueba'));
    await tester.pumpAndSettle();
    expect(find.text('Total: \$25.00'), findsOneWidget);
    expect(find.byTooltip('Carrito: 2 unidades'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Carrito: 2 unidades'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Carrito: 2 unidades'), findsOneWidget);
    await tester.tap(find.byTooltip('Carrito: 2 unidades'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quitar Producto de prueba'));
    await tester.pumpAndSettle();
    expect(find.text('Tu carrito está vacío.'), findsOneWidget);
    expect(find.byTooltip('Carrito: 0 unidades'), findsOneWidget);
  });

  testWidgets('abre detalle usando el ID del producto', (tester) async {
    final repository = FakeProductRepository();
    await mount(tester, repository);
    await tester.pumpAndSettle();
    await tester.tap(find.text(sampleProduct.title));
    await tester.pumpAndSettle();
    expect(find.text('Detalle del producto'), findsOneWidget);
    expect(find.text(sampleProduct.description), findsOneWidget);
    expect(repository.detailIds, [sampleProduct.id]);
  });

  testWidgets('busca una vez después de 400 ms y limpia la búsqueda', (
    tester,
  ) async {
    final repository = FakeProductRepository();
    await mount(tester, repository);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ph');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField), 'phone');
    await tester.pump(const Duration(milliseconds: 399));
    expect(repository.searchQueries, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(repository.searchQueries, ['phone']);
    expect(repository.listCalls, 1);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(repository.listCalls, 2);
  });

  testWidgets('permite reintentar después de un error', (tester) async {
    final repository = FakeProductRepository()..error = Exception('Sin red');
    await mount(tester, repository);
    await tester.pumpAndSettle();
    expect(find.text('No se pudieron cargar los productos.'), findsOneWidget);
    repository.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text(sampleProduct.title), findsOneWidget);
    expect(repository.listCalls, 2);
  });
}

class ControlledSearchRepository extends FakeProductRepository {
  final pending = <String, Completer<List<Product>>>{};

  @override
  Future<List<Product>> searchProducts(String query) {
    final completer = Completer<List<Product>>();
    pending[query] = completer;
    return completer.future;
  }
}
