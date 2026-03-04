import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getProfile();
        await localDataSource.cacheProfile(remoteProfile);
        return Right(remoteProfile);
      } catch (e) {
        // Fallback to cache when remote fails.
        try {
          final localProfile = await localDataSource.getLastProfile();
          return Right(localProfile);
        } catch (_) {
          final message = e.toString().replaceAll('Exception: ', '').trim();
          return Left(ServerFailure(message.isEmpty ? 'Failed to load profile' : message));
        }
      }
    } else {
      try {
        final localProfile = await localDataSource.getLastProfile();
        return Right(localProfile);
      } catch (e) {
        return const Left(CacheFailure('No cached profile found'));
      }
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({
    required Map<String, dynamic> body,
    File? imageFile,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.updateProfile(body, imageFile);
        await localDataSource.cacheProfile(remoteProfile);
        return Right(remoteProfile);
      } catch (e) {
        final message = e.toString().replaceAll('Exception: ', '').trim();
        return Left(ServerFailure(message.isEmpty ? 'Failed to update profile' : message));
      }
    } else {
      return const Left(ServerFailure('No internet connection. Please try again.'));
    }
  }
}
