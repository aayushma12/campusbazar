// lib/features/auth/presentation/providers/auth_notifier.dart

import 'package:campus_bazar/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/signup.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/logout.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Auth state holds current user, loading, and error info
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier manages auth state using Riverpod
class AuthNotifier extends StateNotifier<AuthState> {
  final Login _login;
  final Signup _signup;
  final GetCachedUser _getCachedUser;
  final Logout _logout;

  AuthNotifier({
    required Login login,
    required Signup signup,
    required GetCachedUser getCachedUser,
    required Logout logout,
  })  : _login = login,
        _signup = signup,
        _getCachedUser = getCachedUser,
        _logout = logout,
        super(const AuthState(isLoading: true)) {
    _init();
  }

  /// Check for cached user on startup
  Future<void> _init() async {
    final result = await _getCachedUser();
    result.fold(
      (failure) => state = const AuthState(),
      (user) => state = AuthState(user: user),
    );
  }

  /// Login user
  Future<Either<Failure, User>> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _login(email, password);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return Left(failure);
      },
      (user) {
        state = AuthState(user: user);
        return Right(user);
      },
    );
  }

  /// Signup user
  Future<Either<Failure, User>> signup(String email, String password, {String? name}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _signup(email, password, name: name);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return Left(failure);
      },
      (user) {
        // Don't auto-login, user must login manually
        state = state.copyWith(isLoading: false, clearError: true);
        return Right(user);
      },
    );
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _logout();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = const AuthState(),
    );
  }
}

// ============================================================================
// RIVERPOD PROVIDERS
// ============================================================================

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDatasource = AuthLocalDatasourceImpl();
  return AuthRepositoryImpl(localDatasource: localDatasource);
});

/// Use case providers  
final loginUseCaseProvider = Provider<Login>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return Login(repo);
});

final signupUseCaseProvider = Provider<Signup>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return Signup(repo);
});

final getCachedUserUseCaseProvider = Provider<GetCachedUser>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return GetCachedUser(repo);
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return Logout(repo);
});

/// Main auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    login: ref.read(loginUseCaseProvider),
    signup: ref.read(signupUseCaseProvider),
    getCachedUser: ref.read(getCachedUserUseCaseProvider),
    logout: ref.read(logoutUseCaseProvider),
  );
});
