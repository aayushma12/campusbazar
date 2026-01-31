import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  registered,
  error,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;
  final AuthUser? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    AuthUser? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}
