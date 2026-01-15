import '../../domain/entities/auth_entity.dart';

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
  final AuthEntity? user;

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
    AuthEntity? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}
