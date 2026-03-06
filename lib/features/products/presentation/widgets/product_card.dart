import 'package:flutter/material.dart';

import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final bool isWishlisted;
  final bool isWishlistUpdating;
  final VoidCallback? onWishlistToggle;
  final VoidCallback? onAddToCart;
  final bool isAddingToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isWishlisted = false,
    this.isWishlistUpdating = false,
    this.onWishlistToggle,
    this.onAddToCart,
    this.isAddingToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.grey.shade100),
                  product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 36),
                        )
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _badge(product.condition.toUpperCase(), Colors.blueGrey),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        _badge(product.status.toUpperCase(), _statusColor(product.status)),
                        const SizedBox(height: 6),
                        Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: isWishlistUpdating ? null : onWishlistToggle,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: isWishlistUpdating
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
                                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                                      color: isWishlisted ? Colors.red : Colors.grey.shade700,
                                      size: 18,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: isAddingToCart || product.status.toLowerCase() != 'available' ? null : onAddToCart,
                      icon: isAddingToCart
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: Text(product.status.toLowerCase() == 'available' ? 'Add' : 'Unavailable'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(10)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'available':
      default:
        return Colors.green;
    }
  }
}
