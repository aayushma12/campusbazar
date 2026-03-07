import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/providers/cart_state.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../chat/presentation/providers/chat_state.dart';
import '../../../payment/domain/entities/payment_entity.dart';
import '../../../payment/presentation/pages/payment_redirect_page.dart';
import '../../../payment/presentation/providers/payment_providers.dart';
import '../../../payment/presentation/providers/payment_state.dart';
import '../../../payment/presentation/widgets/payment_method_picker.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';
import '../../../wishlist/presentation/providers/wishlist_state.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../../../core/services/service_locator.dart';

import '../providers/product_state.dart';
import '../providers/products_providers.dart';
import 'product_form_page.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _cartQuantity = 1;
  bool _isCodSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsNotifierProvider.notifier).getDetail(widget.productId);
      ref.read(wishlistNotifierProvider.notifier).loadWishlist();
      ref.read(cartNotifierProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestedId = widget.productId.trim();
    if (requestedId.isEmpty || requestedId.toLowerCase() == 'null') {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Detail')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Invalid product id. Please go back and try again.'),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    ref.listen<ProductState>(productsNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(productsNotifierProvider.notifier).clearMessages();
      }
    });

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
        return;
      }
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(cartNotifierProvider.notifier).clearMessages();
      }
      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
        ref.read(cartNotifierProvider.notifier).clearMessages();
      }
    });

    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(paymentNotifierProvider.notifier).clearMessages();
      }
    });

    ref.listen<ChatState>(chatNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(chatNotifierProvider.notifier).clearError();
      }
    });

    final state = ref.watch(productsNotifierProvider);
    final product = state.selectedProduct;
    final wishlistState = ref.watch(wishlistNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final cartCount = cartState.summary.totalQuantity;
    final paymentState = ref.watch(paymentNotifierProvider);

    if ((state.status == ProductStatusState.initial || state.status == ProductStatusState.loading) && product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      final isError = state.status == ProductStatusState.error;
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isError ? 'Unable to load product details.' : 'Loading product...'),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => ref.read(productsNotifierProvider.notifier).getDetail(requestedId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final safeImages = product.images
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: wishlistState.isUpdating(widget.productId)
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    wishlistState.isInWishlist(widget.productId) ? Icons.favorite : Icons.favorite_border,
                    color: wishlistState.isInWishlist(widget.productId) ? Colors.red : null,
                  ),
            onPressed: wishlistState.isUpdating(widget.productId)
                ? null
                : () => ref.read(wishlistNotifierProvider.notifier).toggleWishlistOptimistic(product),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature can be integrated via share_plus package.')),
              );
            },
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: Badge.count(
              isLabelVisible: cartCount > 0,
              count: cartCount,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          SizedBox(
            height: 240,
            child: PageView(
              children: safeImages.isEmpty
                  ? [Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 52))]
                  : safeImages
                      .map(
                        (e) => ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            e,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Rs ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Colors.green)),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip('Condition: ${product.condition}'),
              const SizedBox(width: 8),
              _chip('Status: ${product.status}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(product.description, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront),
              title: Text(product.sellerName.isEmpty ? 'Seller' : product.sellerName),
              subtitle: Text(product.sellerEmail.isEmpty ? 'No email' : product.sellerEmail),
            ),
          ),
          if (!state.isOwner) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(44, 44),
                      maximumSize: const Size(44, 44),
                    ),
                    onPressed: _cartQuantity == 1
                        ? null
                        : () => setState(() {
                              _cartQuantity -= 1;
                            }),
                    child: const Icon(Icons.remove),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$_cartQuantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(44, 44),
                      maximumSize: const Size(44, 44),
                    ),
                    onPressed: () => setState(() {
                      _cartQuantity += 1;
                    }),
                    child: const Icon(Icons.add),
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: cartState.status == CartStatus.updating || product.status.toLowerCase() != 'available'
                      ? null
                      : () async {
                          final outcome = await ref
                              .read(cartNotifierProvider.notifier)
                              .addOrIncrement(product.id, quantity: _cartQuantity);

                          if (!context.mounted) return;

                          if (outcome == CartAddOutcome.failed) {
                            final error = ref.read(cartNotifierProvider).errorMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error?.isNotEmpty == true ? error! : 'Unable to add this product to cart.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: cartState.status == CartStatus.updating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.shopping_cart_outlined),
                  label: Text(product.status.toLowerCase() == 'available' ? 'Add to Cart' : 'Unavailable'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: paymentState.isBusy || _isCodSubmitting
                    ? null
                    : () async {
                        final method = await showPaymentMethodPicker(context);
                        if (!context.mounted || method == null) return;

                        if (method == AppPaymentMethod.cod) {
                          setState(() => _isCodSubmitting = true);
                          try {
                            final orderRepo = sl<OrderRepository>();
                            await orderRepo.createOrder(
                              productId: product.id,
                              price: product.price,
                              quantity: 1,
                              paymentMethod: 'COD',
                              paymentStatus: 'Pending',
                              orderStatus: 'pending',
                              sellerId: product.sellerId,
                              acknowledgedCollegeRule: true,
                            );

                            await ref.read(productsNotifierProvider.notifier).refresh();

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('COD order placed successfully.'), backgroundColor: Colors.green),
                            );
                            Navigator.pushNamed(context, '/orders');
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                            );
                          } finally {
                            if (mounted) setState(() => _isCodSubmitting = false);
                          }
                          return;
                        }

                        final payment = await ref.read(paymentNotifierProvider.notifier).initiateProductPayment(product.id);
                        if (!context.mounted || payment == null) return;
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PaymentRedirectPage(
                              args: PaymentRedirectPageArgs(
                                payment: payment,
                                flowType: PaymentFlowType.product,
                              ),
                            ),
                          ),
                        );
                      },
                icon: paymentState.isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _isCodSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.payment),
                label: Text(_isCodSubmitting ? 'Placing COD Order...' : 'Pay / COD'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/chatDetail',
                    arguments: {'productId': product.id},
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat with Seller'),
              ),
            ),
          ],
          if (state.isOwner) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => ProductFormPage(existingProduct: product),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        ref.read(productsNotifierProvider.notifier).getDetail(widget.productId);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final ok = await ref.read(productsNotifierProvider.notifier).deleteProduct(product.id);
                      if (ok && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(text),
    );
  }
}
