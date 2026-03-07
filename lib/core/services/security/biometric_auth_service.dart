import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  static const _biometricEnabledKey = 'biometric_login_enabled';
  static const _biometricUserKey = 'biometric_login_user';
  static const _biometricEmailKey = 'biometric_login_email';
  static const _biometricPasswordKey = 'biometric_login_password';

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static int _activePromptCount = 0;
  static DateTime? _lastSuccessfulAuthAt;
  static DateTime? _lastPromptEndedAt;
  static DateTime? _appLockSuppressedUntil;

  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) {
        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return _localAuth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate({required String localizedReason}) async {
    if (_activePromptCount > 0) {
      return false;
    }

    // Biometric sheets can trigger noisy app lifecycle transitions.
    // Keep app-lock disabled briefly for the full prompt window.
    suppressAppLockFor(const Duration(seconds: 12));

    _activePromptCount += 1;
    try {
      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (result) {
        _lastSuccessfulAuthAt = DateTime.now();
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biometric authenticate error: $e');
      }
      return false;
    } finally {
      _activePromptCount = (_activePromptCount - 1).clamp(0, 9999);
      _lastPromptEndedAt = DateTime.now();
    }
  }

  bool get isAuthenticationInProgress => _activePromptCount > 0;

  bool wasAuthenticatedRecently(Duration within) {
    final last = _lastSuccessfulAuthAt;
    if (last == null) return false;
    return DateTime.now().difference(last) <= within;
  }

  bool wasPromptCompletedRecently(Duration within) {
    final last = _lastPromptEndedAt;
    if (last == null) return false;
    return DateTime.now().difference(last) <= within;
  }

  bool get isAppLockTemporarilySuppressed {
    final until = _appLockSuppressedUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  void suppressAppLockFor(Duration duration) {
    final candidate = DateTime.now().add(duration);
    final current = _appLockSuppressedUntil;
    if (current == null || candidate.isAfter(current)) {
      _appLockSuppressedUntil = candidate;
    }
  }

  Future<void> enableBiometricForUser(String email) async {
    await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
    await _secureStorage.write(key: _biometricUserKey, value: email);
  }

  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _biometricEmailKey, value: email);
    await _secureStorage.write(key: _biometricPasswordKey, value: password);
  }

  Future<({String email, String password})?> getBiometricCredentials() async {
    final email = await _secureStorage.read(key: _biometricEmailKey);
    final password = await _secureStorage.read(key: _biometricPasswordKey);

    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }

    return (email: email, password: password);
  }

  Future<void> disableBiometric() async {
    await cancelInProgressAuthentication();
    await _secureStorage.delete(key: _biometricEnabledKey);
    await _secureStorage.delete(key: _biometricUserKey);
    await _secureStorage.delete(key: _biometricEmailKey);
    await _secureStorage.delete(key: _biometricPasswordKey);
    _lastSuccessfulAuthAt = null;
  }

  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  Future<String?> getBiometricUser() {
    return _secureStorage.read(key: _biometricUserKey);
  }

  Future<bool> shouldRequestBiometricOnUnlock() async {
    return isBiometricEnabled();
  }

  Future<void> cancelInProgressAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (_) {
      // Best-effort only. Some platforms may throw when no auth prompt exists.
    } finally {
      _activePromptCount = 0;
      _lastPromptEndedAt = DateTime.now();
    }
  }
}
