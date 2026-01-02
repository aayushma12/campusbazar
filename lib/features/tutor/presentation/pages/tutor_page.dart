import 'package:flutter/material.dart';

class TutorPage extends StatelessWidget {
  const TutorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sprint 3: Responsive detection
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Find a Tutor", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search/Filter Bar for Tutors
            TextField(
              decoration: InputDecoration(
                hintText: "Search by subject (Math, Physics...)",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Responsive Content
            Expanded(
              child: isTablet 
                ? _buildTutorGrid() // Grid for Tablet
                : _buildTutorList(), // List for Mobile
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => _buildTutorCard(),
    );
  }

  Widget _buildTutorGrid() {
    return GridView.builder(
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _buildTutorCard(),
    );
  }

  Widget _buildTutorCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: const Text("Experienced Tutor", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Mathematics • Rs 500/hr"),
        trailing: const Icon(Icons.message_outlined, color: Colors.green),
        onTap: () {},
      ),
    );
  }
}