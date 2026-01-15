import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final LoginUsecase _loginUsecase;
  late final RegisterUsecase _registerUsecase;

  @override
  AuthState build() {
    final repository = ref.read(authRepositoryProvider);

    _loginUsecase = LoginUsecase(repository: repository);
    _registerUsecase = RegisterUsecase(repository: repository);

    return const AuthState();
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    final result = await _loginUsecase(LoginParams(email: email, password: password));

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message ?? 'Something went wrong',
        isLoading: false,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      ),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    final result = await _registerUsecase(
      RegisterParams(name: name, email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message ?? 'Something went wrong',
        isLoading: false,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.registered,
        user: user,
        isLoading: false,
      ),
    );
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
