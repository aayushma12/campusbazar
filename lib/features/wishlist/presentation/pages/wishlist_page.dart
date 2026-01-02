import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sprint 3: Responsive detection
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Wishlist", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isTablet 
          ? _buildGridWishlist() // Grid for Tablet
          : _buildListWishlist(), // List for Mobile
      ),
    );
  }

  // Mobile Layout: Standard List
  Widget _buildListWishlist() {
    return ListView.builder(
      itemCount: 3, // Placeholder count
      itemBuilder: (context, index) => _buildWishlistItem(),
    );
  }

  // Tablet Layout: Organized Grid
  Widget _buildGridWishlist() {
    return GridView.builder(
      itemCount: 4, // Placeholder count
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => _buildWishlistItem(),
    );
  }

  Widget _buildWishlistItem() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.favorite, color: Colors.green),
        ),
        title: const Text("Sample Item", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Rs 5,000"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {},
        ),
      ),
    );
  }
}