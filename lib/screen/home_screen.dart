import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar (Logo + Name + Notification)
            Row(
              children: [
                Image.asset(
                  'assets/image/logo.png',
                  height: 32,
                ),
                const SizedBox(width: 8),
                const Text(
                  "CampusBazar",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                // 🔔 Notification Popup (No notifications)
                PopupMenuButton<int>(
                  icon: const Icon(Icons.notifications_none),
                  offset: const Offset(0, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      enabled: false,
                      child: SizedBox(
                        width: 200,
                        child: Center(
                          child: Text(
                            "No new notifications",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Categories",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "See All",
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryItem(icon: Icons.book, label: "Books"),
                  CategoryItem(icon: Icons.laptop, label: "Electronics"),
                  CategoryItem(icon: Icons.chair, label: "Furniture"),
                  CategoryItem(icon: Icons.directions_bike, label: "Vehicles"),
                  CategoryItem(icon: Icons.checkroom, label: "Clothing"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Recent Listings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const ListingTile(
              title: "Mountain Bike",
              price: "Rs 12000",
            ),
            const ListingTile(
              title: "Study Desk & Chair",
              price: "Rs 8000",
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryItem({
    required this.icon,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green.shade50,
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}

class ListingTile extends StatelessWidget {
  final String title;
  final String price;

  const ListingTile({
    required this.title,
    required this.price,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.image),
        title: Text(title),
        subtitle: Text(price),
        trailing: const Icon(Icons.favorite_border),
      ),
    );
  }
}
