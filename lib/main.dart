
import 'package:campus_bazar/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 1. Add this import

// Import your Models
import 'features/auth/data/models/auth_user_model.dart';
import 'features/profile/data/models/profile_model.dart';

// Import service locator
import 'core/services/service_locator.dart';


// Import your other refactored pages

import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/welcome_view.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/onboarding/presentation/pages/onboarding1_view.dart';
import 'features/onboarding/presentation/pages/onboarding2_view.dart';
import 'features/onboarding/presentation/pages/onboarding3_view.dart';
import 'features/splash/presentation/pages/splash_view.dart';

// 2. Change main to async
void main() async {
  // 3. Ensure Flutter framework is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Initialize Hive
  await Hive.initFlutter();

  // 5. Register the Adapters
  Hive.registerAdapter(AuthUserModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());

  // 6. Setup Dependency Injection (GetIt)
  await setupLocator();
  
  runApp(const CampusBazarApp());
}

class CampusBazarApp extends StatelessWidget {
  const CampusBazarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "CampusBazar",
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashView(),
          '/onboarding1': (_) => const Onboarding1View(),
          '/onboarding2': (_) => const Onboarding2View(),
          '/onboarding3': (_) => const Onboarding3View(),
          '/welcome': (_) => const WelcomeView(),
          '/login': (_) => const LoginPage(),
          '/register': (_) => const SignupPage(),
          '/signup': (_) => const SignupPage(),
          '/forgot': (_) => const ForgotPasswordPage(),
          '/dashboard': (_) => const DashboardPage()
        },
      ),
    );
  }
}