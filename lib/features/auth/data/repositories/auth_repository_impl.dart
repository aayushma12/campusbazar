import 'package:dartz/dartz.dart';
import 'package:campus_bazar/core/error/failures.dart';
import 'package:campus_bazar/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:campus_bazar/features/auth/data/models/user_model.dart';
import 'package:campus_bazar/features/auth/domain/entities/user.dart';
import 'package:campus_bazar/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await localDatasource.validateLogin(email, password);

      if (user == null) {
        final isRegistered = await localDatasource.isEmailRegistered(email);
        if (!isRegistered) {
          return Left(AuthFailure('Email not registered. Please sign up first.'));
        }
        return Left(AuthFailure('Invalid password. Please try again.'));
      }

      await localDatasource.cacheUser(user);
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signup(String email, String password, {String? name}) async {
    try {
      final isRegistered = await localDatasource.isEmailRegistered(email);
      if (isRegistered) {
        return Left(AuthFailure('Email already registered. Please login instead.'));
      }

      await localDatasource.registerUser(email, password, name);

      final user = UserModel(
        userId: email.hashCode.toString(),
        fullName: name ?? '',
        email: email.toLowerCase().trim(),
        password: password,
      );

      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthFailure('Signup failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final user = await localDatasource.getCachedUser();
      return Right(user?.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDatasource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Logout failed: ${e.toString()}'));
    }
  }
}
