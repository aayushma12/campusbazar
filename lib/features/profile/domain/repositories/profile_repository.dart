import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

/// Domain contract for profile-related operations.
abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> updateProfile({
    required Map<String, dynamic> body,
    File? imageFile,
  });
}
