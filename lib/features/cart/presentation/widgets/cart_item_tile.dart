import 'package:flutter/material.dart';

import '../../domain/entities/cart_item_entity.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isUpdating;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback onRemove;
  final VoidCallback? onPayNow;
  final bool isPaying;

  const CartItemTile({
    super.key,
    required this.item,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.onPayNow,
    this.isPaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.productImage.isNotEmpty
                  ? Image.network(
                      item.productImage,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(),
                    )
                  : _fallbackImage(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.productPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _stepperButton(
                        icon: Icons.remove,
                        onTap: isUpdating ? null : onDecrement,
                      ),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      _stepperButton(
                        icon: Icons.add,
                        onTap: isUpdating ? null : onIncrement,
                      ),
                      const Spacer(),
                      if (isUpdating)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          onPressed: onRemove,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isPaying ? null : onPayNow,
                      icon: isPaying
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.payment),
                      label: const Text('Pay Now'),
                    ),
                  ),
                  if (!item.isAvailable)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Currently unavailable',
                        style: TextStyle(color: Colors.red, fontSize: 12),
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

  Widget _stepperButton({required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade200 : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: onTap == null ? Colors.grey : Colors.black87),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 74,
      height: 74,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
