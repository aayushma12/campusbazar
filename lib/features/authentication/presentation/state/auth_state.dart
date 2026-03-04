import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  error,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? successMessage,
    bool clearUser = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : errorMessage,
      successMessage: clearSuccess ? null : successMessage,
    );
  }
}
