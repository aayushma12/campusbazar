import 'package:campus_bazar/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> logout();
}
