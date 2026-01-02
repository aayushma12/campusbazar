import 'package:flutter/material.dart';

class Onboarding3View extends StatelessWidget {
  const Onboarding3View({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect screen size for responsiveness
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // IMAGE - Scaled for Tablet
            Expanded(
              flex: 6,
              child: Center(
                child: Image.asset(
                  "assets/image/onboarding3.png",
                  height: isTablet ? 400 : 240,
                ),
              ),
            ),

            // TITLE & SUBTITLE - Constrained width
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.2 : 30,
              ),
              child: Column(
                children: const [
                  Text(
                    "Find Tutors & Improve Skills",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Request tutoring or find experienced students in your campus.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/onboarding2');
                    },
                    style: TextButton.styleFrom(
                      padding: isTablet 
                        ? const EdgeInsets.symmetric(horizontal: 30, vertical: 15) 
                        : null,
                    ),
                    child: const Text("BACK"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigating to the next feature (Auth or Welcome)
                      Navigator.pushReplacementNamed(context, '/welcome');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: isTablet 
                        ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20) 
                        : null,
                      backgroundColor: Colors.black, // Example of styling "Get Started"
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("GET STARTED"),
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