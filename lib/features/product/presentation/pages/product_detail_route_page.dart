import 'package:flutter/material.dart';

import 'product_detail_page.dart';

class ProductDetailRoutePage extends StatelessWidget {
  const ProductDetailRoutePage({super.key});

  String? _extractProductId(dynamic args) {
    if (args == null) return null;

    if (args is String) {
      final id = args.trim();
      return id.isEmpty ? null : id;
    }

    if (args is Map<String, dynamic>) {
      final id = (args['productId'] ?? args['id'] ?? args['_id'])?.toString().trim();
      return (id == null || id.isEmpty) ? null : id;
    }

    if (args is Map) {
      final id = (args['productId'] ?? args['id'] ?? args['_id'])?.toString().trim();
      return (id == null || id.isEmpty) ? null : id;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final productId = _extractProductId(args);

    if (productId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Detail')),
        body: const Center(child: Text('Invalid product ID')),
      );
    }

    return ProductDetailPage(productId: productId);
  }
}
