import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String name,
    required String email,
    required String password,
    required String university,
    required String campus,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      university: university,
      campus: campus,
    );
  }
}
