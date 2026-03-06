import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final AuthRemoteDatasource _authRemoteDatasource;

  @override   
  AuthState build() {
    // Inject UseCases via Service Locator (GetIt)
    _loginUseCase = sl<LoginUseCase>();
    _registerUseCase = sl<RegisterUseCase>();
    _authRemoteDatasource = sl<AuthRemoteDatasource>();

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
    String? university,
    String? campus,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    final result = await _registerUseCase(
      RegisterParams(
        name: name,
        email: email,
        password: password,
        university: university,
        campus: campus,
      ),
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

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, isLoading: true, errorMessage: null);
    try {
      await _authRemoteDatasource.forgotPassword(email: email);
      state = state.copyWith(status: AuthStatus.initial, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> resetPassword({required String token, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, isLoading: true, errorMessage: null);
    try {
      await _authRemoteDatasource.resetPassword(token: token, password: password);
      state = state.copyWith(status: AuthStatus.initial, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}