import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

/// Domain contract for user-only authentication.
abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String password,
    required String university,
    required String campus,
  });

  Future<Either<Failure, AuthUser>> restoreSession();

  Future<Either<Failure, void>> logout();
}
