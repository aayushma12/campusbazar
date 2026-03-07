import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/security/biometric_auth_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  LoginUseCase? _loginUseCase;
  RegisterUseCase? _registerUseCase;
  AuthRemoteDatasource? _authRemoteDatasource;
  AuthLocalDataSource? _authLocalDataSource;
  BiometricAuthService? _biometricAuthService;

  void _ensureDependencies() {
    if (_loginUseCase == null && sl.isRegistered<LoginUseCase>()) {
      _loginUseCase = sl<LoginUseCase>();
    }
    if (_registerUseCase == null && sl.isRegistered<RegisterUseCase>()) {
      _registerUseCase = sl<RegisterUseCase>();
    }
    if (_authRemoteDatasource == null && sl.isRegistered<AuthRemoteDatasource>()) {
      _authRemoteDatasource = sl<AuthRemoteDatasource>();
    }
    if (_authLocalDataSource == null && sl.isRegistered<AuthLocalDataSource>()) {
      _authLocalDataSource = sl<AuthLocalDataSource>();
    }
    if (_biometricAuthService == null && sl.isRegistered<BiometricAuthService>()) {
      _biometricAuthService = sl<BiometricAuthService>();
    }
  }

  @override
  AuthState build() {
    _ensureDependencies();

    return const AuthState();
  }

  Future<void> login({required String email, required String password, required bool rememberMe}) async {
    _ensureDependencies();
    if (_loginUseCase == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login service unavailable',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    final result = await _loginUseCase!(LoginParams(email: email, password: password));

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (user) async {
        if (_authLocalDataSource != null) {
          await _authLocalDataSource!.setRememberMe(rememberMe);
        }

        if (!rememberMe) {
          await _biometricAuthService?.disableBiometric();
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      },
    );
  }

  Future<bool> getRememberMePreference() async {
    _ensureDependencies();
    if (_authLocalDataSource == null) return false;
    return _authLocalDataSource!.isRememberMeEnabled();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? university,
    String? campus,
  }) async {
    _ensureDependencies();
    if (_registerUseCase == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration service unavailable',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, isLoading: true);

    final result = await _registerUseCase!(
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

  Future<void> logout() async {
    _ensureDependencies();
    await _authLocalDataSource?.clearCache();
    await _biometricAuthService?.disableBiometric();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<bool> forgotPassword(String email) async {
    _ensureDependencies();
    if (_authRemoteDatasource == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: 'Password reset service unavailable',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, isLoading: true, errorMessage: null);
    try {
      await _authRemoteDatasource!.forgotPassword(email: email);
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
    _ensureDependencies();
    if (_authRemoteDatasource == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: 'Password reset service unavailable',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, isLoading: true, errorMessage: null);
    try {
      await _authRemoteDatasource!.resetPassword(token: token, password: password);
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

  Future<bool> canOfferBiometricLogin() async {
    _ensureDependencies();
    if (_biometricAuthService == null) {
      return false;
    }

    final available = await _biometricAuthService!.isBiometricAvailable();
    if (!available) return false;

    final enabled = await _biometricAuthService!.isBiometricEnabled();
    return !enabled;
  }

  Future<bool> isBiometricLoginEnabled() {
    _ensureDependencies();
    if (_biometricAuthService == null) {
      return Future.value(false);
    }

    return _biometricAuthService!.isBiometricEnabled();
  }

  Future<bool> enableBiometricLoginForCurrentUser() async {
    _ensureDependencies();
    if (_biometricAuthService == null) {
      return false;
    }

    final email = state.user?.email;
    if (email == null || email.isEmpty) {
      return false;
    }

    final available = await _biometricAuthService!.isBiometricAvailable();
    if (!available) {
      return false;
    }

    final authenticated = await _biometricAuthService!.authenticate(
      localizedReason: 'Verify your identity to enable biometric login',
    );

    if (!authenticated) {
      return false;
    }

    await _biometricAuthService!.enableBiometricForUser(email);
    return true;
  }

  Future<bool> enableBiometricLoginWithCredentials({
    required String email,
    required String password,
  }) async {
    _ensureDependencies();
    if (_biometricAuthService == null) {
      return false;
    }

    if (email.trim().isEmpty || password.isEmpty) {
      return false;
    }

    final available = await _biometricAuthService!.isBiometricAvailable();
    if (!available) {
      return false;
    }

    final authenticated = await _biometricAuthService!.authenticate(
      localizedReason: 'Verify your identity to enable biometric login',
    );

    if (!authenticated) {
      return false;
    }

    await _biometricAuthService!.enableBiometricForUser(email.trim());
    await _biometricAuthService!.saveBiometricCredentials(
      email: email.trim(),
      password: password,
    );
    return true;
  }

  Future<bool> authenticateWithBiometrics() async {
    _ensureDependencies();
    if (_biometricAuthService == null || _authLocalDataSource == null) {
      return false;
    }

    final enabled = await _biometricAuthService!.isBiometricEnabled();
    if (!enabled) {
      return false;
    }

    final available = await _biometricAuthService!.isBiometricAvailable();
    if (!available) {
      return false;
    }

    final authenticated = await _biometricAuthService!.authenticate(
      localizedReason: 'Authenticate to login to CampusBazar',
    );

    if (!authenticated) {
      return false;
    }

    final cachedUser = await _authLocalDataSource!.getCachedUser();
    final token = await _authLocalDataSource!.getToken();

    final resolvedToken = token ?? cachedUser?.token;
    if (resolvedToken != null && resolvedToken.isNotEmpty) {
      // Ensure token key is restored in storage if it was missing but user had token.
      if ((token == null || token.isEmpty) && cachedUser != null && cachedUser.token.isNotEmpty) {
        await _authLocalDataSource!.cacheUser(cachedUser);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: cachedUser ?? state.user,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    }

    // If no cached session token is available, attempt credential-based login.
    if (_loginUseCase == null) {
      return false;
    }

    final creds = await _biometricAuthService!.getBiometricCredentials();
    if (creds == null) {
      await _biometricAuthService!.disableBiometric();
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, isLoading: true, errorMessage: null);
    final result = await _loginUseCase!(
      LoginParams(email: creds.email.trim(), password: creds.password),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      },
    );
  }
}