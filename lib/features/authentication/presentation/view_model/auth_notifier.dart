import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../state/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  bool _sessionChecked = false;

  @override
  AuthState build() {
    if (!_sessionChecked) {
      _sessionChecked = true;
      Future.microtask(restoreSession);
    }
    return const AuthState();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearSuccess: true,
    );

    final result = await ref.read(restoreSessionUseCaseProvider).call();

    result.fold(
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
          clearSuccess: true,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
          clearSuccess: true,
        );
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearSuccess: true,
    );

    final result = await ref.read(loginUseCaseProvider).call(
          email: email,
          password: password,
        );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          clearSuccess: true,
          clearUser: true,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          successMessage: 'Login successful',
          clearError: true,
        );
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String university,
    required String campus,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearSuccess: true,
    );

    final result = await ref.read(registerUseCaseProvider).call(
          name: name,
          email: email,
          password: password,
          university: university,
          campus: campus,
        );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          clearSuccess: true,
        );
      },
      (message) {
        // Backend register endpoint returns only confirmation message.
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          successMessage: message,
          clearError: true,
          clearUser: true,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearSuccess: true,
    );

    final result = await ref.read(logoutUseCaseProvider).call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          clearSuccess: true,
        );
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
          successMessage: 'Logged out successfully',
        );
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
