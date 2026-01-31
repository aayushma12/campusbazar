import 'package:hive/hive.dart';
import '../models/auth_user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(AuthUserModel user);
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box box;
  
  AuthLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheUser(AuthUserModel user) async {
    await box.put('CACHED_USER', user);
    await box.put('CACHED_TOKEN', user.token);
  }

  @override
  Future<String?> getToken() async {
    return box.get('CACHED_TOKEN');
  }
}
