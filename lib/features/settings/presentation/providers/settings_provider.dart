import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/datasources/settings_remote_data_source.dart';

class SettingsState {
  final bool isLoading;
  final bool isSaving;
  final bool pushNotificationsEnabled;
  final String? successMessage;
  final String? errorMessage;

  const SettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.pushNotificationsEnabled = true,
    this.successMessage,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? pushNotificationsEnabled,
    String? successMessage,
    String? errorMessage,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final settingsDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSourceImpl(sl<ApiClient>());
});

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  late final SettingsRemoteDataSource _dataSource;

  @override
  SettingsState build() {
    _dataSource = ref.read(settingsDataSourceProvider);
    return const SettingsState();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      final data = await _dataSource.getSettings();
      state = state.copyWith(
        isLoading: false,
        pushNotificationsEnabled: data.pushNotificationsEnabled,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> setPushNotificationsEnabled(bool enabled, {String? fcmToken}) async {
    final previous = state.pushNotificationsEnabled;
    state = state.copyWith(
      isSaving: true,
      pushNotificationsEnabled: enabled,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final data = await _dataSource.updatePushNotifications(enabled, fcmToken: fcmToken);
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
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Password changed successfully. Please sign in again on other devices.',
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
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

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

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
