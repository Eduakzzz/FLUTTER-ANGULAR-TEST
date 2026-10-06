import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({required this.product, this.onTap, super.key});
  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Image.network(
        product.thumbnail,
        width: 64,
        height: 64,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          width: 64,
          height: 64,
          child: Icon(Icons.image_not_supported_outlined),
        ),
      ),
      title: Text(product.title),
      subtitle: Text(
        '\$${product.price.toStringAsFixed(2)} · ★ ${product.rating.toStringAsFixed(1)}',
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
