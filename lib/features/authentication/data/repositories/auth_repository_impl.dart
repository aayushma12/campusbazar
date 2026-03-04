import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(email: email, password: password);
      await localDataSource.cacheSession(
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Right(response.user);
    } catch (e) {
      return Left(ServerFailure(_asMessage(e, fallback: 'Login failed')));
    }
  }

  @override
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String password,
    required String university,
    required String campus,
  }) async {
    try {
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        university: university,
        campus: campus,
      );

      // Register endpoint returns only message (no token/user yet).
      return Right(response.message);
    } catch (e) {
      return Left(ServerFailure(_asMessage(e, fallback: 'Registration failed')));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> restoreSession() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token.isEmpty) {
        return const Left(CacheFailure('No local session found'));
      }

      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException {
      return const Left(CacheFailure('No local session found'));
    } catch (e) {
      return Left(CacheFailure(_asMessage(e, fallback: 'Could not restore session')));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(_asMessage(e, fallback: 'Logout failed')));
    }
  }

  String _asMessage(Object error, {required String fallback}) {
    final raw = error.toString();
    final cleaned = raw.replaceAll('Exception: ', '').trim();
    return cleaned.isEmpty ? fallback : cleaned;
  }
}
