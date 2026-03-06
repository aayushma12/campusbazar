import 'package:flutter/material.dart';

import 'product_detail_page.dart';

/// Route wrapper for named navigation compatibility.
/// Expects a String product id in route arguments.
class ProductDetailRoutePage extends StatelessWidget {
  const ProductDetailRoutePage({super.key});

  static final RegExp _objectIdRegex = RegExp(r'[a-fA-F0-9]{24}');

  String? _resolveProductId(dynamic args) {
    if (args == null) return null;

    if (args is String) {
      final trimmed = args.trim();
      if (trimmed.isNotEmpty) return trimmed;
      return null;
    }

    if (args is Map<String, dynamic>) {
      return (args['productId'] ?? args['id'] ?? args['_id'])?.toString().trim();
    }

    if (args is Map) {
      return (args['productId'] ?? args['id'] ?? args['_id'])?.toString().trim();
    }

    try {
      final dynamic dyn = args;
      final id = dyn.id?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    } catch (_) {}

    final text = args.toString();
    final match = _objectIdRegex.firstMatch(text);
    return match?.group(0)?.trim();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final productId = _resolveProductId(args);

    if (productId == null || productId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Product id is missing.')),
      );
    }

    return ProductDetailPage(productId: productId);
  }
}
