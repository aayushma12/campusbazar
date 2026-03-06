import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Updates profile using backend PATCH /api/v1/users/me endpoint.
class UpdateProfileUseCase implements UseCase<Profile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(body: params.body, imageFile: params.imageFile);
  }
}

class UpdateProfileParams {
  final Map<String, dynamic> body;
  final File? imageFile;

  UpdateProfileParams({required this.body, this.imageFile});
}
