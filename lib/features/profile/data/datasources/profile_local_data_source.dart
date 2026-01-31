import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheProfile(ProfileModel profile);
  Future<ProfileModel> getLastProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Box box;

  ProfileLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    await box.put('CACHED_PROFILE', profile);
  }

  @override
  Future<ProfileModel> getLastProfile() async {
    final profile = box.get('CACHED_PROFILE');
    if (profile != null) return profile;
    throw CacheException();
  }
}
