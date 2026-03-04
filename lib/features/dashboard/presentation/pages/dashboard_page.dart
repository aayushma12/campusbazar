import 'package:campus_bazar/features/profile/presentation/pages/profile_page.dart';
import 'package:campus_bazar/features/products/presentation/pages/products_dashboard_page.dart';
import 'package:campus_bazar/features/product/presentation/pages/search_products_page.dart';
import 'package:campus_bazar/features/tutor/presentation/pages/tutor_page.dart';
import 'package:campus_bazar/features/cart/presentation/pages/cart_page.dart';
import 'package:campus_bazar/features/cart/presentation/providers/cart_providers.dart';
import 'package:campus_bazar/features/chat/presentation/pages/conversations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartNotifierProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget Function()> pageBuilders = [
      () => const ProductsDashboardPage(),
      () => const SearchProductsPage(),
      () => const TutorPage(),
      () => const CartPage(),
      () => const ConversationsPage(),
      () => const ProfilePage(),
    ];

    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      body: Row(
        children: [
          if (isTablet)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Colors.green),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              destinations: [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
                NavigationRailDestination(icon: Icon(Icons.school_outlined), label: Text('Tutor')),
                NavigationRailDestination(icon: _cartIconWithBadge(), label: Text('Cart')),
                NavigationRailDestination(icon: Icon(Icons.chat_bubble_outline), label: Text('Chat')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('Profile')),
              ],
            ),
          Expanded(
            child: pageBuilders[_currentIndex](),
          ),
        ],
      ),
      bottomNavigationBar: isTablet
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Tutor'),
                BottomNavigationBarItem(icon: _cartIconWithBadge(), label: 'Cart'),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
    );
  }

  Widget _cartIconWithBadge() {
    final cartCount = ref.watch(cartNotifierProvider).summary.totalQuantity;
    return Badge.count(
      isLabelVisible: cartCount > 0,
      count: cartCount,
      child: const Icon(Icons.shopping_cart),
    );
  }
}