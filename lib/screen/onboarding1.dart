import 'package:flutter/material.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

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
                child: Image.asset("assets/image/onboarding1.png", height: 250),
              ),
            ),

            // TITLE & SUBTITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: const [
                  Text(
                    "Find Everything You Need on Campus",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

            const Spacer(), // Pushes buttons to the bottom
            // BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // only NEXT button
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/onboarding2');
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
