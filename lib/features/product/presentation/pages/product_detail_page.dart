import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/view_model/cart_viewmodel.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';
import '../view_model/product_viewmodel.dart';

class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = productId.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Detail"),
      ),
      body: id.isEmpty || id.toLowerCase() == 'null'
          ? const Center(child: Text('Invalid product ID'))
          : ref.watch(productDetailProvider(id)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error.toString().replaceAll('Exception: ', ''),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => ref.invalidate(productDetailProvider(id)),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (product) {
                  final safeImages = product.images
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
                      .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: safeImages.isNotEmpty
                              ? PageView(
                                  children: safeImages
                                      .map((url) => Image.network(url, fit: BoxFit.cover))
                                      .toList(),
                                )
                              : Container(color: Colors.grey[200]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Rs ${product.price}'),
                        const SizedBox(height: 20),
                        Text(product.description),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final outcome = await ref
                                      .read(cartViewModelProvider.notifier)
                                      .addOrIncrement(product.id, quantity: 1);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        outcome == CartAddOutcome.failed
                                            ? (ref.read(cartViewModelProvider).errorMessage ?? 'Unable to add to cart')
                                            : 'Added to cart',
                                      ),
                                      backgroundColor: outcome == CartAddOutcome.failed ? Colors.red : null,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: const Text('Add to Cart'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CheckoutPage(product: product),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.flash_on),
                                label: const Text('Buy Now'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}