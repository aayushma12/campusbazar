import 'package:campus_bazar/screen/forgot_password.dart';
import 'package:campus_bazar/screen/login.dart';
import 'package:campus_bazar/screen/onboarding1.dart';
import 'package:campus_bazar/screen/onboarding2.dart';
import 'package:campus_bazar/screen/onboarding3.dart';
import 'package:campus_bazar/screen/signup.dart';
import 'package:campus_bazar/screen/splash.dart';
import 'package:campus_bazar/screen/welcome.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const CampusBazarApp());
}

class CampusBazarApp extends StatelessWidget {
  const CampusBazarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CampusBazar",
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding1': (_) => const Onboarding1(),
        '/onboarding2': (_) => const Onboarding2(),
        '/onboarding3': (_) => const Onboarding3(),
        '/login': (_) => const LoginScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/signup': (_) => const SignupScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
      },
    );
  }
}
