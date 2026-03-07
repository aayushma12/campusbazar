import 'package:flutter/material.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../services/security/biometric_auth_service.dart';
import '../services/service_locator.dart';

class AppLockGuard extends StatefulWidget {
  final Widget child;

  const AppLockGuard({super.key, required this.child});

  @override
  State<AppLockGuard> createState() => _AppLockGuardState();
}

class _AppLockGuardState extends State<AppLockGuard>
    with WidgetsBindingObserver {
  bool _didEnterBackground = false;
  bool _isAuthenticating = false;
  bool _resumeCheckQueued = false;
  DateTime? _lastSuccessfulUnlockAt;

  // Prevent immediate re-prompts caused by transient lifecycle churn
  // around biometric sheets/dialogs.
  static const Duration _unlockCooldown = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final biometricService = sl<BiometricAuthService>();

    if (biometricService.isAppLockTemporarilySuppressed) {
      return;
    }

    // Treat only true background transitions as lock-worthy.
    // `inactive` can fire during system overlays/biometric sheet and
    // should not arm another lock cycle.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Ignore lifecycle churn caused by biometric prompts.
      if (biometricService.isAuthenticationInProgress) {
        return;
      }
      _didEnterBackground = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _didEnterBackground) {
      _didEnterBackground = false;
      if (_resumeCheckQueued) return;
      _resumeCheckQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resumeCheckQueued = false;
        if (!mounted) return;
        _lockOnResumeIfNeeded();
      });
    }
  }

  Future<void> _lockOnResumeIfNeeded() async {
    if (_isAuthenticating || !mounted) return;

    final biometricService = sl<BiometricAuthService>();

    if (biometricService.isAppLockTemporarilySuppressed) return;

    // If another app flow (e.g., Settings fingerprint enablement) is currently
    // prompting biometrics, never trigger lock auth in parallel.
    if (biometricService.isAuthenticationInProgress) return;

    // Android/iOS biometric sheets can emit rapid paused/resumed transitions.
    // Suppress lock flow immediately after any biometric prompt closes.
    if (biometricService.wasPromptCompletedRecently(
      const Duration(seconds: 5),
    )) {
      return;
    }

    // Skip immediate re-prompt when biometric auth just succeeded elsewhere.
    if (biometricService.wasAuthenticatedRecently(_unlockCooldown)) return;

    final now = DateTime.now();
    if (_lastSuccessfulUnlockAt != null &&
        now.difference(_lastSuccessfulUnlockAt!) < _unlockCooldown) {
      return;
    }

    final authLocal = sl<AuthLocalDataSource>();
    final token = await authLocal.getToken();
    if (token == null || token.isEmpty) return;

    final shouldRequest = await biometricService
        .shouldRequestBiometricOnUnlock();
    final available = await biometricService.isBiometricAvailable();

    if (!shouldRequest || !available) return;

    _isAuthenticating = true;
    bool success = false;
    try {
      success = await biometricService.authenticate(
        localizedReason: 'Authenticate to unlock CampusBazar',
      );
    } finally {
      _isAuthenticating = false;
    }

    if (success) {
      _lastSuccessfulUnlockAt = DateTime.now();
    }

    if (!mounted || success) return;

    // Do not force navigation from a lifecycle callback on biometric cancel/fail.
    // This path can race with system biometric overlays and trigger key collisions
    // in the root navigator tree. We'll simply require auth again on next
    // background->resume transition.
    return;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
