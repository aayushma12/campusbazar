import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<AuthUser, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(RegisterParams params) async {
    return await repository.register(
      params.name,
      params.email,
      params.password,
      university: params.university,
      campus: params.campus,
    );
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String? university;
  final String? campus;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.university,
    this.campus,
  });
}
