import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/providers/cart_state.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';
import '../../../wishlist/presentation/providers/wishlist_state.dart';
import '../providers/product_filter_providers.dart';
import '../providers/product_filter_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

class ProductsDashboardPage extends ConsumerStatefulWidget {
  const ProductsDashboardPage({super.key});

  @override
  ConsumerState<ProductsDashboardPage> createState() => _ProductsDashboardPageState();
}

class _ProductsDashboardPageState extends ConsumerState<ProductsDashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productFilterNotifierProvider.notifier).loadInitial();
      ref.read(wishlistNotifierProvider.notifier).loadWishlist();
      ref.read(cartNotifierProvider.notifier).loadCart();
    });

    _scrollController.addListener(() {
      final notifier = ref.read(productFilterNotifierProvider.notifier);
      final state = ref.read(productFilterNotifierProvider);
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 280 && state.hasMore) {
        if (state.status == ProductFilterStatus.loaded || state.status == ProductFilterStatus.empty) {
          notifier.loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProductFilterState>(productFilterNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
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
      }
    });

    final state = ref.watch(productFilterNotifierProvider);
    final wishlistState = ref.watch(wishlistNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final cartCount = cartState.summary.totalQuantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/wishlist'),
            icon: const Icon(Icons.favorite_border),
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
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () => _openFilterSheet(context, state.filter),
                icon: const Icon(Icons.tune),
              ),
              if (state.activeFilterCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.activeFilterCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () => ref.read(productFilterNotifierProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productFilterNotifierProvider.notifier).refresh(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(productFilterNotifierProvider.notifier).searchByKeyword('');
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  setState(() {});
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 450), () {
                    ref.read(productFilterNotifierProvider.notifier).searchByKeyword(value);
                  });
                },
                onSubmitted: (value) {
                  ref.read(productFilterNotifierProvider.notifier).searchByKeyword(value);
                },
              ),
            ),
            if (state.activeFilterCount > 0) _activeFilterChips(state),
            Expanded(child: _buildBody(state, wishlistState, cartState)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const ProductFormPage()),
          );
          if (created == true) {
            await ref.read(productFilterNotifierProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Sell'),
      ),
    );
  }

  Widget _buildBody(ProductFilterState state, WishlistState wishlistState, CartState cartState) {
    if (state.status == ProductFilterStatus.loading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.products.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 110),
          const Center(
            child: Icon(Icons.search_off, size: 70, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('No products found', style: TextStyle(fontSize: 18))),
          const SizedBox(height: 6),
          const Center(child: Text('Try adjusting search or filters.')),
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton(
              onPressed: () => ref.read(productFilterNotifierProvider.notifier).clearAll(),
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      itemCount: state.products.length + (state.isFetchingMore ? 2 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index >= state.products.length) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }

        final product = state.products[index];
        final isAddingToCart = cartState.isUpdating(product.id);
        return ProductCard(
          product: product,
          isWishlisted: wishlistState.isInWishlist(product.id),
          isWishlistUpdating: wishlistState.isUpdating(product.id),
          isAddingToCart: isAddingToCart,
          onWishlistToggle: () {
            ref.read(wishlistNotifierProvider.notifier).toggleWishlistOptimistic(product);
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

            final successText = outcome == CartAddOutcome.quantityUpdated ? 'Cart quantity updated' : 'Added to cart';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(successText), backgroundColor: Colors.green),
            );
          },
          onTap: () {
            final productId = product.id.trim();
            if (productId.isEmpty || productId.toLowerCase() == 'null') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to open product details. Invalid product id.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailPage(productId: productId),
              ),
            );
          },
        );
      },
    );
  }

  Widget _activeFilterChips(ProductFilterState state) {
    final chips = <Widget>[];
    final filter = state.filter;

    void addChip(String label, String key) {
      chips.add(
        InputChip(
          label: Text(label),
          onDeleted: () => ref.read(productFilterNotifierProvider.notifier).removeSingleFilter(key),
        ),
      );
    }

    if (filter.keyword != null && filter.keyword!.isNotEmpty) addChip('Search: ${filter.keyword}', 'keyword');
    if (filter.campus != null && filter.campus!.isNotEmpty) addChip('Campus: ${filter.campus}', 'campus');
    if (filter.category != null && filter.category!.isNotEmpty) addChip('Category: ${filter.category}', 'category');
    if (filter.condition != null && filter.condition!.isNotEmpty) addChip('Condition: ${filter.condition}', 'condition');
    if (filter.minPrice != null) addChip('Min: ${filter.minPrice}', 'minPrice');
    if (filter.maxPrice != null) addChip('Max: ${filter.maxPrice}', 'maxPrice');
    if (filter.sortBy != null && filter.sortBy!.isNotEmpty) addChip('Sort: ${filter.sortBy}', 'sortBy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8, runSpacing: 6, children: chips),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => ref.read(productFilterNotifierProvider.notifier).clearAll(),
              child: const Text('Clear all'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context, ProductFilter current) async {
    final campusCtrl = TextEditingController(text: current.campus ?? '');
    final categoryCtrl = TextEditingController(text: current.category ?? '');
    String? selectedSort = current.sortBy;
    String? selectedCondition = current.condition;

    RangeValues range = RangeValues(
      current.minPrice ?? 0,
      (current.maxPrice ?? 3000).clamp(0, 5000),
    );
    if (range.start > range.end) {
      range = RangeValues(range.end, range.start);
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Filter & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: campusCtrl,
                      decoration: const InputDecoration(labelText: 'Campus', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryCtrl,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCondition,
                      decoration: const InputDecoration(labelText: 'Condition', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'new', child: Text('New')),
                        DropdownMenuItem(value: 'like_new', child: Text('Like New')),
                        DropdownMenuItem(value: 'good', child: Text('Good / Used')),
                        DropdownMenuItem(value: 'fair', child: Text('Fair / Used')),
                        DropdownMenuItem(value: 'poor', child: Text('Poor / Used')),
                      ],
                      onChanged: (v) => setModalState(() => selectedCondition = v),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedSort,
                      decoration: const InputDecoration(labelText: 'Sort By', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'newest', child: Text('Newest')),
                        DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                        DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                      ],
                      onChanged: (v) => setModalState(() => selectedSort = v),
                    ),
                    const SizedBox(height: 12),
                    Text('Price Range: ${range.start.round()} - ${range.end.round()}'),
                    RangeSlider(
                      values: range,
                      min: 0,
                      max: 5000,
                      divisions: 100,
                      labels: RangeLabels('${range.start.round()}', '${range.end.round()}'),
                      onChanged: (v) => setModalState(() => range = v),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await ref.read(productFilterNotifierProvider.notifier).clearAll();
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text('Clear All'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              await ref.read(productFilterNotifierProvider.notifier).applyFilter(
                                    campus: campusCtrl.text.trim(),
                                    category: categoryCtrl.text.trim(),
                                    condition: selectedCondition,
                                    sortBy: selectedSort,
                                    minPrice: range.start > 0 ? range.start : null,
                                    maxPrice: range.end < 5000 ? range.end : null,
                                  );
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
