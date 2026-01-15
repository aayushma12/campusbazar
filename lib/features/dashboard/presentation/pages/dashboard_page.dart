import 'package:campus_bazar/features/auth/data/models/user_model.dart';
import 'package:campus_bazar/features/profile/presentation/pages/profile_page.dart';
import 'package:campus_bazar/features/tutor/presentation/pages/tutor_page.dart';
import 'package:campus_bazar/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  // Pass the user model here to display personalized data in the Profile tab
  final UserModel? user;
  const DashboardPage({super.key, this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List of actual pages instead of placeholders
    final List<Widget> pages = [
      const Center(child: Text("Home Page Content")), // You can update this later
      const TutorPage(),
      const Center(child: Text("Add Product Page")), // You can update this later
      const WishlistPage(),
      ProfilePage(user: widget.user), // Passing the real user data
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
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.school), label: Text('Tutor')),
                NavigationRailDestination(icon: Icon(Icons.add_circle), label: Text('Add')),
                NavigationRailDestination(icon: Icon(Icons.favorite_border), label: Text('Wishlist')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('Profile')),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
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
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Tutor'),
                BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 30), label: 'Add'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
    );
  }
}