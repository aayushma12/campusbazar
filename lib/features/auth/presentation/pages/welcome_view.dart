import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect screen size for responsiveness
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center( // Wrap in Center for Tablet alignment
          child: SizedBox(
            // Constraint width on tablet so buttons aren't too wide
            width: isTablet ? 400 : double.infinity, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LOGO SECTION
                Column(
                  children: [
                    SizedBox(height: isTablet ? 80 : 40),
                    Image.asset(
                      "assets/image/logo.png",
                      height: isTablet ? 200 : 120, // Scaled logo
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome to CampusBazar",
                      style: TextStyle(
                        fontSize: 24, // Slightly larger
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                // BUTTONS SECTION
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : 14, // Thicker buttons on tablet
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : 14,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                             "Sign Up",
                            style: TextStyle(fontSize: 18, color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}