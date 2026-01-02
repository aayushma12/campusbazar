import 'package:flutter/material.dart';

class Onboarding1View extends StatelessWidget {
  const Onboarding1View({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen size detection
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // IMAGE - Adjusted for Tablet
            Expanded(
              flex: 6,
              child: Center(
                child: Image.asset(
                  "assets/image/onboarding1.png", 
                  height: isTablet ? 400 : 250, // Larger image for tablets
                ),
              ),
            ),

            // TITLE & SUBTITLE - Constrained width for tablets
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.2 : 30, // More padding on tablets
              ),
              child: Column(
                children: const [
                  Text(
                    "Find Everything You Need on Campus",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24, // Slightly larger text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Browse everything posted by fellow students. Save time and money while staying connected with your campus community.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const Spacer(), 
            
            // BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/onboarding2');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: isTablet 
                        ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20) 
                        : null, // Bigger button on tablets
                    ),
                    child: const Text("NEXT"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}