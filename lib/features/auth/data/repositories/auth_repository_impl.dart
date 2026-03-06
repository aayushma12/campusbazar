import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email: email, password: password);
      // Cache the result
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> register(
    String name,
    String email,
    String password, {
    String? university,
    String? campus,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        university: university,
        campus: campus,
      );
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      return Left(ServerFailure(message));
    }
  }
}
