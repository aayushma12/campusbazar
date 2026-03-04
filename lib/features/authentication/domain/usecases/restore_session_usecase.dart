import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository repository;

  RestoreSessionUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call() {
    return repository.restoreSession();
  }
}
