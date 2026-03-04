import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/providers/cart_state.dart';
import '../providers/wishlist_providers.dart';
import '../providers/wishlist_state.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistNotifierProvider.notifier).loadWishlist();
      ref.read(cartNotifierProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WishlistState>(wishlistNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(wishlistNotifierProvider.notifier).clearError();
      }
    });

    ref.listen<CartState>(cartNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });

    final state = ref.watch(wishlistNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final cartCount = cartState.summary.totalQuantity;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
            }
          },
        ),
        title: const Text("My Wishlist", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          _cartActionButton(cartCount),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(wishlistNotifierProvider.notifier).loadWishlist();
          await ref.read(cartNotifierProvider.notifier).loadCart();
        },
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(WishlistState state) {
    if (state.status == WishlistStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.favorite_border, size: 84, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Center(
            child: Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 6),
          const Center(child: Text('Save products you like to find them quickly.')),
          const SizedBox(height: 18),
          Center(
            child: FilledButton.tonal(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              child: const Text('Browse Products'),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        final updating = state.isUpdating(item.productId);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/productDetail',
                arguments: {'productId': item.productId},
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.productImage.isNotEmpty
                            ? Image.network(
                                item.productImage,
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
                              )
                            : _fallbackIcon(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              '\$${item.productPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (updating)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: updating
                              ? null
                              : () async {
                                  final shouldRemove = await _confirmRemove(item.productTitle);
                                  if (!mounted || shouldRemove != true) return;
                                  await ref.read(wishlistNotifierProvider.notifier).removeByProductIdOptimistic(item.productId);
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: updating
                              ? null
                              : () async {
                                  final removeAfterAdd = await _chooseWishlistCartAction(item.productTitle);
                                  if (!context.mounted || removeAfterAdd == null) return;

                                  final notifier = ref.read(wishlistNotifierProvider.notifier);
                                  final bool success;
                                  final String? message;

                                  if (removeAfterAdd) {
                                    final result = await notifier.moveToCartAndRemoveFromWishlist(item.productId, quantity: 1);
                                    success = result.success;
                                    message = result.message;
                                  } else {
                                    final result = await notifier.addToCartFromWishlist(item.productId, quantity: 1);
                                    success = result.success;
                                    message = result.message;
                                  }
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        message ??
                                            (success
                                                ? (removeAfterAdd
                                                    ? 'Added to cart and removed from wishlist.'
                                                    : 'Added to cart.')
                                                : 'Unable to move item to cart.'),
                                      ),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cartActionButton(int count) {
    return IconButton(
      tooltip: 'Cart',
      onPressed: () => Navigator.pushNamed(context, '/cart'),
      icon: Badge.count(
        isLabelVisible: count > 0,
        count: count,
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
      ),
    );
  }

  Future<bool?> _confirmRemove(String title) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from wishlist?'),
        content: Text('Remove "$title" from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _chooseWishlistCartAction(String title) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add to cart'),
        content: Text('Do you also want to remove "$title" from wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep in wishlist'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Move to cart'),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 54,
      height: 54,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}