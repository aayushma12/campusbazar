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
    return await repository.register(params.name, params.email, params.password);
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;

  RegisterParams({required this.name, required this.email, required this.password});
}
