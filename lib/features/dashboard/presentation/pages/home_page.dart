import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/pages/product_detail_page.dart';
import '../providers/dashboard_providers.dart';
import '../state/dashboard_state.dart';
import 'create_product_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DashboardState>(dashboardNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(dashboardNotifierProvider.notifier).clearMessages();
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
        ref.read(dashboardNotifierProvider.notifier).clearMessages();
      }
    });

    final state = ref.watch(dashboardNotifierProvider);
    final products = state.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusBazar', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardNotifierProvider.notifier).loadProducts(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome to CampusBazar 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Buy, sell, find tutors, and connect with students near you.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/searchProducts'),
                          icon: const Icon(Icons.search),
                          label: const Text('Search Items'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push<bool>(
                              MaterialPageRoute<bool>(
                                builder: (_) => const DashboardCreateProductPage(),
                              ),
                            );
                            if (result == true) {
                              ref.read(dashboardNotifierProvider.notifier).loadProducts();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Sell Item'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Recent Listings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (state.isLoading && products.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text('No listings yet. Be the first to post one!'),
              )
            else
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: products.length > 6 ? 6 : products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final item = products[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        final productId = item.id.trim();
                        if (productId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Unable to open product details right now.'),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey.shade100,
                              child: item.images.isNotEmpty
                                  ? Image.network(
                                      item.images.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image, size: 42, color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs ${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              child: const Text('View all products'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => const DashboardCreateProductPage(),
            ),
          );
          if (result == true) {
            ref.read(dashboardNotifierProvider.notifier).loadProducts();
          }
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }
}
