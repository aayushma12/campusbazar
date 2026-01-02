import 'package:campus_bazar/core/database/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();

  Future<void> registerUser(String email, String password, String? name);
  Future<UserModel?> validateLogin(String email, String password);
  Future<bool> isEmailRegistered(String email);
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const String _registeredUsersBox = 'registered_users';

  Future<Box<UserModel>> _getRegisteredUsersBox() async {
    if (!Hive.isBoxOpen(_registeredUsersBox)) {
      return await Hive.openBox<UserModel>(_registeredUsersBox);
    }
    return Hive.box<UserModel>(_registeredUsersBox);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final box = await HiveService.openUserBox(); // Box<UserModel>
    return box.get('user');
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final box = await HiveService.openUserBox();
    await box.put('user', user);
  }

  @override
  Future<void> clearUser() async {
    final box = await HiveService.openUserBox();
    await box.delete('user');
  }

  @override
  Future<void> registerUser(String email, String password, String? name) async {
    final box = await _getRegisteredUsersBox();
    final normalizedEmail = email.toLowerCase().trim();

    final user = UserModel(
      userId: normalizedEmail.hashCode.toString(),
      fullName: name ?? '',
      email: normalizedEmail,
      password: password,
    );

    await box.put(normalizedEmail, user);
  }

  @override
  Future<UserModel?> validateLogin(String email, String password) async {
    final box = await _getRegisteredUsersBox();
    final normalizedEmail = email.toLowerCase().trim();
    final user = box.get(normalizedEmail);

    if (user == null) return null;
    if (user.password != password) return null;

    // Return a copy with a new token (token can be generated in the repository)
    return UserModel(
      userId: user.userId,
      fullName: user.fullName,
      email: user.email,
      password: user.password,
    );
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    final box = await _getRegisteredUsersBox();
    final normalizedEmail = email.toLowerCase().trim();
    return box.containsKey(normalizedEmail);
  }
}
