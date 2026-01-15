import 'package:campus_bazar/core/error/failures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dartz/dartz.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDatasource = ref.read(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remoteDatasource: remoteDatasource);
});

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepositoryImpl({required AuthRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, AuthEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // normalize email
      final cleanedEmail = email.trim().toLowerCase();

      // send plain password to backend (backend hashes it)
      final AuthResponseModel response = await _remoteDatasource.register(
        name: name,
        email: cleanedEmail,
        password: password,
      );

      // store token securely
      await _secureStorage.write(key: 'token', value: response.token);

      return Right(AuthEntity(
     userId: response.userId,
     name: response.name,
     email: response.email,
     token: response.token,

      ));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // normalize email
      final cleanedEmail = email.trim().toLowerCase();

      // send plain password to backend
      final AuthResponseModel response = await _remoteDatasource.login(
        email: cleanedEmail,
        password: password,
      );

      // store token securely
      await _secureStorage.write(key: 'token', value: response.token);

      return Right(AuthEntity(
       userId: response.userId,
       name: response.name,
       email: response.email,
       token: response.token,

      ));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _remoteDatasource.logout();
      // remove token from storage on logout
      await _secureStorage.delete(key: 'token');
      return Right(result);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
