import 'package:campus_bazar/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  // 2. ADD THE USER VARIABLE
  final UserModel? user;

  // 3. UPDATE THE CONSTRUCTOR TO REQUIRE THE USER
  const ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: isTablet ? 500 : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // PROFILE HEADER
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 15),
                
                // 4. USE REAL DATA FROM THE USER MODEL
                Text(
                  user?.fullName ?? "Guest Student", // Shows real name
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? "no-email@campus.edu", // Shows real email
                  style: const TextStyle(color: Colors.grey),
                ),
                
                const SizedBox(height: 30),
                
                // PROFILE OPTIONS
                _buildProfileOption(Icons.shopping_bag_outlined, "My Listings"),
                _buildProfileOption(Icons.history, "Purchase History"),
                _buildProfileOption(Icons.favorite_outline, "Wishlist"),
                _buildProfileOption(Icons.help_outline, "Help & Support"),
                
                const Divider(height: 40),
                
                // LOGOUT BUTTON
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    // 5. IMPROVED NAVIGATION FOR LOGOUT
                    // This clears the history so the user can't "back" into the profile
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}