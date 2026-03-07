import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/usecases/fetch_products_usecase.dart';
import '../view_model/product_viewmodel.dart';
import '../widgets/product_card.dart';

class SearchProductsPage extends ConsumerStatefulWidget {

  const SearchProductsPage({super.key});
  @override
  ConsumerState<SearchProductsPage> createState() => _SearchProductsPageState();
}

class _SearchProductsPageState extends ConsumerState<SearchProductsPage> {
  final _searchController = TextEditingController();
  String? _condition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productViewModelProvider.notifier).fetchProducts();
      ref.read(cartNotifierProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final products = state.products ?? [];
    final cartCount = cartState.summary.totalQuantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Listings', style: TextStyle(color: Colors.black)),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search title/description',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _condition,
                  hint: const Text('Condition'),
                  items: const [
                    DropdownMenuItem(value: 'new', child: Text('New')),
                    DropdownMenuItem(value: 'like_new', child: Text('Like new')),
                    DropdownMenuItem(value: 'good', child: Text('Good')),
                    DropdownMenuItem(value: 'fair', child: Text('Fair')),
                    DropdownMenuItem(value: 'poor', child: Text('Poor')),
                  ],
                  onChanged: (value) {
                    setState(() => _condition = value);
                    _performSearch();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(productViewModelProvider.notifier).fetchProducts(
                    params: FetchProductsParams(
                      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
                      condition: _condition,
                    ),
                  ),
              child: state.isLoading && products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? const Center(child: Text('No matching listings found'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return ProductCard(
                              product: p,
                              isAddingToCart: cartState.isUpdating(p.id),
                              onTap: () {
                                final productId = p.id.trim();
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
                              onFavorite: () => ref.read(productViewModelProvider.notifier).toggleFavorite(p.id),
                              onAddToCart: () async {
                                final outcome = await ref.read(cartNotifierProvider.notifier).addOrIncrement(p.id, quantity: 1);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _performSearch,
        icon: const Icon(Icons.search),
        label: const Text('Search'),
      ),
    );
  }

  void _performSearch() {
    ref.read(productViewModelProvider.notifier).fetchProducts(
          params: FetchProductsParams(
            search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
            condition: _condition,
          ),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
