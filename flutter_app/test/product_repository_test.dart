import 'dart:convert';
import 'package:flutter_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const productJson = <String, Object?>{
  'id': 1,
  'title': 'Producto',
  'description': 'Descripción',
  'category': 'beauty',
  'price': 12,
  'rating': 4.5,
  'thumbnail': 'https://example.com/product.png',
};

void main() {
  test(
    'listado envía paginación y mapea números y listas inmutables',
    () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/products');
        expect(request.url.queryParameters, {'limit': '20', 'skip': '0'});
        return http.Response(
          jsonEncode({
            'products': [productJson],
          }),
          200,
        );
      });
      addTearDown(client.close);
      final repository = ProductRepositoryImpl(ProductRemoteDataSource(client));
      final products = await repository.getProducts();
      expect(products.single.price, 12.0);
      expect(products.single.rating, 4.5);
      expect(() => products.clear(), throwsUnsupportedError);
    },
  );

  test('búsqueda codifica texto en q', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/products/search');
      expect(request.url.queryParameters['q'], 'phone & case');
      return http.Response('{"products":[]}', 200);
    });
    addTearDown(client.close);
    final repository = ProductRepositoryImpl(ProductRemoteDataSource(client));
    expect(await repository.searchProducts('phone & case'), isEmpty);
  });

  test('detalle consulta el ID y mapea el producto', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/products/1');
      return http.Response(jsonEncode(productJson), 200);
    });
    addTearDown(client.close);
    final repository = ProductRepositoryImpl(ProductRemoteDataSource(client));
    expect((await repository.getProductById(1)).title, 'Producto');
  });

  test('HTTP fallido propaga error al consumidor', () async {
    final client = MockClient((request) async => http.Response('{}', 503));
    addTearDown(client.close);
    final repository = ProductRepositoryImpl(ProductRemoteDataSource(client));
    await expectLater(
      repository.getProducts(),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('respuesta con estructura incorrecta falla explícitamente', () async {
    final client = MockClient(
      (request) async => http.Response('{"products":{}}', 200),
    );
    addTearDown(client.close);
    final repository = ProductRepositoryImpl(ProductRemoteDataSource(client));
    await expectLater(repository.getProducts(), throwsFormatException);
  });
}
