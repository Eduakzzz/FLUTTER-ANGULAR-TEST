import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/product.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._client);

  static const _apiHost = 'dummyjson.com';

  // Cliente inyectado; el prefijo _ lo hace privado a esta biblioteca.
  final http.Client _client;

  Future<List<Product>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    final uri = Uri.https(_apiHost, '/products', {
      'limit': '$limit',
      'skip': '$skip',
    });
    return _fetchProducts(uri);
  }

  Future<List<Product>> searchProducts(String query) =>
      _fetchProducts(Uri.https(_apiHost, '/products/search', {'q': query}));

  Future<List<Product>> _fetchProducts(Uri uri) async {
    // await espera HTTP sin bloquear la interfaz.
    final response = await _client.get(uri);
    _ensureSuccessfulResponse(response);

    // Decodifica JSON y comprueba su estructura antes de mapearlo.
    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Expected a products response object.');
    }

    final productsJson = decoded['products'];
    if (productsJson is! List<Object?>) {
      throw const FormatException('Expected a products list in the response.');
    }

    // Publica productos en una lista que no admite mutaciones.
    return List<Product>.unmodifiable(
      productsJson.map((productJson) {
        if (productJson is! Map<String, Object?>) {
          throw const FormatException('Expected each product to be an object.');
        }

        return Product.fromJson(productJson);
      }),
    );
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.https(_apiHost, '/products/$id');
    final response = await _client.get(uri);
    _ensureSuccessfulResponse(response);

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Expected a product response object.');
    }

    return Product.fromJson(decoded);
  }

  void _ensureSuccessfulResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'Request failed with HTTP ${response.statusCode}.',
        response.request?.url,
      );
    }
  }
}
