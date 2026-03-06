import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession({
    required AuthUserModel user,
    required String accessToken,
    required String refreshToken,
  });

  Future<AuthUserModel> getCachedUser();
  Future<String> getAccessToken();
  Future<String> getRefreshToken();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _boxName = 'authenticationBox';
  static const _userKey = 'AUTH_USER';
  static const _tokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';

  // Secure storage mirrors token data for improved security.
  static const _secureTokenKey = 'secure_access_token';
  static const _secureRefreshTokenKey = 'secure_refresh_token';

  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return Hive.openBox(_boxName);
  }

  @override
  Future<void> cacheSession({
    required AuthUserModel user,
    required String accessToken,
    required String refreshToken,
  }) async {
    final box = await _openBox();
    await box.put(_userKey, user);
    await box.put(_tokenKey, accessToken);
    await box.put(_refreshTokenKey, refreshToken);

    await secureStorage.write(key: _secureTokenKey, value: accessToken);
    await secureStorage.write(key: _secureRefreshTokenKey, value: refreshToken);
  }

  @override
  Future<AuthUserModel> getCachedUser() async {
    final box = await _openBox();
    final user = box.get(_userKey);

    if (user is AuthUserModel) {
      return user;
    }

    if (user is Map<dynamic, dynamic>) {
      return AuthUserModel.fromMap(user);
    }

    throw CacheException();
  }

  @override
  Future<String> getAccessToken() async {
    final secureToken = await secureStorage.read(key: _secureTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    final box = await _openBox();
    final token = box.get(_tokenKey)?.toString();
    if (token == null || token.isEmpty) {
      throw CacheException();
    }
    return token;
  }

  @override
  Future<String> getRefreshToken() async {
    final secureToken = await secureStorage.read(key: _secureRefreshTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    final box = await _openBox();
    final token = box.get(_refreshTokenKey)?.toString();
    if (token == null || token.isEmpty) {
      throw CacheException();
    }
    return token;
  }

  @override
  Future<void> clearSession() async {
    final box = await _openBox();
    await box.delete(_userKey);
    await box.delete(_tokenKey);
    await box.delete(_refreshTokenKey);

    await secureStorage.delete(key: _secureTokenKey);
    await secureStorage.delete(key: _secureRefreshTokenKey);
  }
}
