import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/usecases/fetch_products_usecase.dart';
import '../view_model/product_viewmodel.dart';
import '../widgets/product_card.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  bool _initialFilterApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productViewModelProvider.notifier).fetchProducts();
      ref.read(cartNotifierProvider.notifier).loadCart();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialFilterApplied) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _initialFilterApplied = true;
      ref.read(productViewModelProvider.notifier).fetchProducts(
            params: FetchProductsParams(
              search: args['search'] as String?,
              category: args['category'] as String?,
              campus: args['campus'] as String?,
              condition: args['condition'] as String?,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final cartCount = cartState.summary.totalQuantity;

    if (state.isLoading && (state.products == null)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(productViewModelProvider.notifier).fetchProducts(),
        child: state.products == null || state.products!.isEmpty
            ? const Center(child: Text('No products yet'))
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.products!.length,
                itemBuilder: (context, index) {
                  final product = state.products![index];
                  return ProductCard(
                    product: product,
                    isAddingToCart: cartState.isUpdating(product.id),
                    onTap: () {
                      final productId = product.id.trim();
                      if (productId.isEmpty || productId.toLowerCase() == 'null') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to open product details.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        '/productDetail',
                        arguments: {'productId': productId},
                      );
                    },
                    onFavorite: () {
                      ref.read(productViewModelProvider.notifier).toggleFavorite(product.id);
                    },
                    onAddToCart: () async {
                      final outcome = await ref.read(cartNotifierProvider.notifier).addOrIncrement(product.id, quantity: 1);
                      if (!context.mounted) return;

                      if (outcome == CartAddOutcome.failed) {
                        final error = ref.read(cartNotifierProvider).errorMessage;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error?.isNotEmpty == true ? error! : 'Unable to add this product to cart.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final successText = outcome == CartAddOutcome.quantityUpdated
                          ? 'Cart quantity updated'
                          : 'Added to cart';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(successText), backgroundColor: Colors.green),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/product/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
