import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // IMAGE
            Expanded(
              flex: 6,
              child: Center(
                child: Image.asset(
                  "assets/onboarding2.png",
                  height: 250,
                ),
              ),
            ),

            // TITLE & SUBTITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: const [
                  Text(
                    "Sell Your Stuff Easily",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
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

            const Spacer(), // Pushes buttons to the bottom

            // BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/onboarding1'); // BACK to previous screen
                    },
                    child: const Text("BACK"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/onboarding3'); // NEXT
                    },
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
