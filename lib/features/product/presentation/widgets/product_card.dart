import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToCart;
  final bool isAddingToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.onAddToCart,
    this.isAddingToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image thumbnail
            AspectRatio(
              aspectRatio: 1.5,
              child: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(color: Colors.grey[200]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text("Rs ${product.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.green)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: isAddingToCart || product.status.toLowerCase() != 'available' ? null : onAddToCart,
                          icon: isAddingToCart
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.shopping_cart_outlined, size: 16),
                          label: Text(product.status.toLowerCase() == 'available' ? 'Add' : 'Unavailable'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.red),
                        onPressed: onFavorite,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
