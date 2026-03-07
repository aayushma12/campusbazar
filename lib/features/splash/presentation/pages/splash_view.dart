import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/security/biometric_auth_service.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _timer;
  bool _navigated = false;

  static const Duration _splashDelay = Duration(milliseconds: 1800);
  static const Duration _startupTimeout = Duration(seconds: 8);

  Future<void> _navigateTo(String routeName) async {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.pushReplacementNamed(context, routeName);
  }

  Future<void> _resolveInitialRoute() async {
    try {
      final authLocal = sl<AuthLocalDataSource>();

      // Never let secure storage / plugin calls block startup forever.
      final token = await authLocal.getToken().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        await _navigateTo('/onboarding1');
        return;
      }

      final rememberMe = await authLocal.isRememberMeEnabled().timeout(
        const Duration(seconds: 2),
        onTimeout: () => true,
      );

      if (!mounted) return;

      if (!rememberMe) {
        // Best-effort cleanup only. Do not block route transition.
        try {
          await authLocal.clearCache().timeout(const Duration(seconds: 2));
          await sl<BiometricAuthService>()
              .disableBiometric()
              .timeout(const Duration(seconds: 2));
        } catch (_) {
          // Ignore cleanup failures and continue to login.
        }
        await _navigateTo('/login');
        return;
      }

      // Avoid blocking splash on biometric prompt/plugin behavior.
      // App lock can still enforce biometrics after dashboard appears.
      await _navigateTo('/dashboard');
    } catch (_) {
      // Guaranteed fallback so splash cannot get stuck.
      await _navigateTo('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(_splashDelay, () {
      _resolveInitialRoute().timeout(
        _startupTimeout,
        onTimeout: () async {
          await _navigateTo('/login');
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-load the image into the system cache to prevent lag during build
    precacheImage(const AssetImage("assets/image/logo.png"), context);
  }

  @override
  void dispose() {
    // Crucial: Cancel the timer if the user closes the app before it fires
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sprint 3 Requirement: Mobile & Tablet Responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Logic: If width > 600 (Tablet), make the logo larger
    final double logoSize = screenWidth > 600 ? 300 : 180;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeInImage(
          // Placeholder can be a simple transparent box or a loading spinner
          placeholder: const AssetImage("assets/image/logo.png"), 
          image: const AssetImage("assets/image/logo.png"),
          fadeOutDuration: const Duration(milliseconds: 300),
          fadeInDuration: const Duration(milliseconds: 300),
          width: logoSize,
          height: logoSize,
          // Optimization: Forces the engine to decode only at the size needed
          imageErrorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, size: 50, color: Colors.red);
          },
        ),
      ),
    );
  }
}