import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(AuthUserModel user);
  Future<String?> getToken();
  Future<AuthUserModel?> getCachedUser();
  Future<void> setRememberMe(bool enabled);
  Future<bool> isRememberMeEnabled();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box box;
  final FlutterSecureStorage secureStorage;
  static const _rememberMeKey = 'auth_remember_me';
  
  AuthLocalDataSourceImpl(this.box, {FlutterSecureStorage? secureStorage})
      : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> cacheUser(AuthUserModel user) async {
    await box.put('CACHED_USER', user);
    await box.put('CACHED_TOKEN', user.token);
  }

  @override
  Future<String?> getToken() async {
    final token = box.get('CACHED_TOKEN')?.toString();
    if (token != null && token.isNotEmpty) {
      return token;
    }

    // Recovery fallback: if token key is missing but user is cached, restore token.
    final user = await getCachedUser();
    if (user?.token.isNotEmpty == true) {
      await box.put('CACHED_TOKEN', user!.token);
      return user.token;
    }

    return null;
  }

  @override
  Future<AuthUserModel?> getCachedUser() async {
    final cached = box.get('CACHED_USER');
    if (cached is AuthUserModel) {
      return cached;
    }
    return null;
  }

  @override
  Future<void> setRememberMe(bool enabled) async {
    await secureStorage.write(key: _rememberMeKey, value: enabled ? 'true' : 'false');
  }

  @override
  Future<bool> isRememberMeEnabled() async {
    final value = await secureStorage.read(key: _rememberMeKey);
    return value == 'true';
  }

  @override
  Future<void> clearCache() async {
    await box.delete('CACHED_USER');
    await box.delete('CACHED_TOKEN');
    await secureStorage.delete(key: _rememberMeKey);
  }
}
