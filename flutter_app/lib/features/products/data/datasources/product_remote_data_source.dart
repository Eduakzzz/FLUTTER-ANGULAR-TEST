import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/product.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._client);

  static const _apiHost = 'dummyjson.com';

  final http.Client _client;

  Future<List<Product>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    final uri = Uri.https(_apiHost, '/products', {
      'limit': '$limit',
      'skip': '$skip',
    });
    final response = await _client.get(uri);
    _ensureSuccessfulResponse(response);

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Expected a products response object.');
    }

    final productsJson = decoded['products'];
    if (productsJson is! List<Object?>) {
      throw const FormatException('Expected a products list in the response.');
    }

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
