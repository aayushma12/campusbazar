import 'package:campus_bazar/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';


class RegisterParams {
  final String name;
  final String email;
  final String password;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

class RegisterUsecase {
  final IAuthRepository repository;

  RegisterUsecase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}
