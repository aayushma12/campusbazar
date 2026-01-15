import 'package:campus_bazar/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUsecase {
  final IAuthRepository repository;

  LoginUsecase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}
