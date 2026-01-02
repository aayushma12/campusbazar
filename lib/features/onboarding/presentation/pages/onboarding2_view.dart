import 'package:flutter/material.dart';

class Onboarding2View extends StatelessWidget {
  const Onboarding2View({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect screen size for Sprint 3 responsiveness
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // IMAGE - Responsive sizing
            Expanded(
              flex: 6,
              child: Center(
                child: Image.asset(
                  "assets/image/onboarding2.png",
                  height: isTablet ? 400 : 250, // Larger for tablets
                ),
              ),
            ),

            // TITLE & SUBTITLE - Controlled width for readability
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.2 : 30,
              ),
              child: Column(
                children: const [
                  Text(
                    "Sell Your Stuff Easily",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24, // Slightly larger for better hierarchy
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "List your items for sale in just a few taps. Reach a wide audience of students looking for great deals on campus.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BUTTONS - Layout remains the same but with larger tap targets for tablets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/onboarding1');
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
                      Navigator.pushReplacementNamed(context, '/onboarding3');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: isTablet 
                        ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20) 
                        : null,
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