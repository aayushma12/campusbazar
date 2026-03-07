import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/services/security/biometric_auth_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/settings_remote_data_source.dart';

class SettingsState {
  final bool isLoading;
  final bool isSaving;
  final bool isSecuritySaving;
  final bool pushNotificationsEnabled;
  final bool biometricEnabled;
  final bool biometricAvailable;
  final String? successMessage;
  final String? errorMessage;

  const SettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSecuritySaving = false,
    this.pushNotificationsEnabled = true,
    this.biometricEnabled = false,
    this.biometricAvailable = false,
    this.successMessage,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSecuritySaving,
    bool? pushNotificationsEnabled,
    bool? biometricEnabled,
    bool? biometricAvailable,
    String? successMessage,
    String? errorMessage,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSecuritySaving: isSecuritySaving ?? this.isSecuritySaving,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final settingsDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSourceImpl(sl<ApiClient>());
});

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  late final SettingsRemoteDataSource _dataSource;
  late final BiometricAuthService _biometricAuthService;
  late final AuthLocalDataSource _authLocalDataSource;
  late final AuthRemoteDatasource _authRemoteDataSource;

  @override
  SettingsState build() {
    _dataSource = ref.read(settingsDataSourceProvider);
    _biometricAuthService = sl<BiometricAuthService>();
    _authLocalDataSource = sl<AuthLocalDataSource>();
    _authRemoteDataSource = sl<AuthRemoteDatasource>();
    return const SettingsState();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final data = await _dataSource.getSettings();
      final biometricEnabled = await _biometricAuthService.isBiometricEnabled();
      final biometricAvailable = await _biometricAuthService
          .isBiometricAvailable();

      state = state.copyWith(
        isLoading: false,
        pushNotificationsEnabled: data.pushNotificationsEnabled,
        biometricEnabled: biometricEnabled,
        biometricAvailable: biometricAvailable,
      );
    } catch (e) {
      final biometricEnabled = await _biometricAuthService.isBiometricEnabled();
      final biometricAvailable = await _biometricAuthService
          .isBiometricAvailable();
      state = state.copyWith(
        isLoading: false,
        biometricEnabled: biometricEnabled,
        biometricAvailable: biometricAvailable,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> setPushNotificationsEnabled(
    bool enabled, {
    String? fcmToken,
  }) async {
    final previous = state.pushNotificationsEnabled;
    state = state.copyWith(
      isSaving: true,
      pushNotificationsEnabled: enabled,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final data = await _dataSource.updatePushNotifications(
        enabled,
        fcmToken: fcmToken,
      );
      state = state.copyWith(
        isSaving: false,
        pushNotificationsEnabled: data.pushNotificationsEnabled,
        successMessage: data.pushNotificationsEnabled
            ? 'Push notifications enabled'
            : 'Push notifications disabled',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        pushNotificationsEnabled: previous,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = state.copyWith(
        isSaving: false,
        successMessage:
            'Password changed successfully. Please sign in again on other devices.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _dataSource.deleteAccount(password: password);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Account deleted successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> refreshBiometricStatus() async {
    final biometricEnabled = await _biometricAuthService.isBiometricEnabled();
    final biometricAvailable = await _biometricAuthService
        .isBiometricAvailable();
    state = state.copyWith(
      biometricEnabled: biometricEnabled,
      biometricAvailable: biometricAvailable,
    );
  }

  Future<bool> setBiometricEnabled({
    required bool enabled,
    String? accountPassword,
  }) async {
    state = state.copyWith(
      isSecuritySaving: true,
      clearError: true,
      clearSuccess: true,
    );

    // Prevent app-lock lifecycle hooks from racing while user is enrolling
    // biometrics in Settings.
    _biometricAuthService.suppressAppLockFor(const Duration(seconds: 15));

    try {
      if (!enabled) {
        await _biometricAuthService.disableBiometric();
        state = state.copyWith(
          isSecuritySaving: false,
          biometricEnabled: false,
          biometricAvailable: await _biometricAuthService
              .isBiometricAvailable(),
          successMessage: 'Fingerprint login disabled',
        );
        return true;
      }

      final available = await _biometricAuthService.isBiometricAvailable();
      if (!available) {
        state = state.copyWith(
          isSecuritySaving: false,
          biometricAvailable: false,
          biometricEnabled: false,
          errorMessage:
              'Biometric authentication is not available on this device.',
        );
        return false;
      }

      final user = await _authLocalDataSource.getCachedUser();
      if (user == null || user.email.isEmpty) {
        state = state.copyWith(
          isSecuritySaving: false,
          errorMessage:
              'Unable to identify current user for fingerprint setup.',
        );
        return false;
      }

      final password = accountPassword?.trim() ?? '';
      if (password.isEmpty) {
        state = state.copyWith(
          isSecuritySaving: false,
          errorMessage:
              'Account password is required to enable fingerprint login.',
        );
        return false;
      }

      // Ensure old biometric state is fully reset before fresh enrollment.
      await _biometricAuthService.disableBiometric();

      // Validate credentials before storing for biometric login fallback.
      await _authRemoteDataSource.login(email: user.email, password: password);

      final authenticated = await _biometricAuthService.authenticate(
        localizedReason: 'Verify fingerprint to enable login for CampusBazar',
      );

      if (!authenticated) {
        state = state.copyWith(
          isSecuritySaving: false,
          errorMessage: 'Fingerprint verification cancelled or failed.',
        );
        return false;
      }

      await _biometricAuthService.enableBiometricForUser(user.email);
      await _biometricAuthService.saveBiometricCredentials(
        email: user.email,
        password: password,
      );

      state = state.copyWith(
        isSecuritySaving: false,
        biometricEnabled: true,
        biometricAvailable: true,
        successMessage: 'Fingerprint login enabled successfully',
      );
      return true;
    } catch (e) {
      // Keep local biometric storage in a safe disabled state after any failure.
      await _biometricAuthService.disableBiometric();
      state = state.copyWith(
        isSecuritySaving: false,
        biometricEnabled: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
