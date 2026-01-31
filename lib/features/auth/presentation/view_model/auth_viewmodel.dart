import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_locator.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;

  @override
  AuthState build() {
    // Inject UseCases via Service Locator (GetIt)
    _loginUseCase = sl<LoginUseCase>();
    _registerUseCase = sl<RegisterUseCase>();

    return const AuthState();
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    final result = await _loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
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

    final result = await _registerUseCase(
      RegisterParams(name: name, email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
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