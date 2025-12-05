import 'package:flutter/material.dart';
import 'package:campus_bazar/screen/onboarding1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to first onboarding screen after 1.2 seconds
    Future.delayed(const Duration(milliseconds: 1200), () {
      Navigator.pushNamed(context, '/onboarding1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/logo.png",
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}
