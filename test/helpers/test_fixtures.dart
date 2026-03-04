import 'package:campus_bazar/features/auth/data/models/auth_user_model.dart';
import 'package:campus_bazar/features/profile/data/models/profile_model.dart';

/// Test fixtures for Auth feature
class AuthTestFixtures {
  static const tEmail = 'test@example.com';
  static const tPassword = 'password123';
  static const tName = 'Test User';
  static const tToken = 'fake_token_12345';
  static const tUserId = '1';

  static const tAuthUserModel = AuthUserModel(
    id: tUserId,
    email: tEmail,
    name: tName,
    token: tToken,
  );

  static Map<String, dynamic> get loginSuccessResponse => {
        'user': {
          'id': tUserId,
          'email': tEmail,
          'name': tName,
        },
        'accessToken': tToken,
      };

  static Map<String, dynamic> get registerSuccessResponse => {
        'user': {
          'id': tUserId,
          'email': tEmail,
          'name': tName,
        },
        'accessToken': tToken,
      };

  static Map<String, dynamic> get loginErrorResponse => {
        'message': 'Invalid credentials',
      };

  static Map<String, dynamic> get registerErrorResponse => {
        'message': 'Email already exists',
      };
}

/// Test fixtures for Profile feature
class ProfileTestFixtures {
  static const tUserId = '1';
  static const tName = 'Test User';
  static const tEmail = 'test@example.com';
  static const tProfilePicture = 'https://example.com/image.jpg';

  static ProfileModel get tProfileModel => ProfileModel(
        id: tUserId,
        name: tName,
        email: tEmail,
        profilePicture: tProfilePicture,
      );

  static Map<String, dynamic> get profileSuccessResponse => {
        'data': {
          'id': tUserId,
          'name': tName,
          'email': tEmail,
          'profilePicture': tProfilePicture,
        },
      };

  static Map<String, dynamic> get profileUpdateSuccessResponse => {
        'data': {
          'id': tUserId,
          'name': 'Updated User',
          'email': tEmail,
          'profilePicture': 'https://example.com/new-image.jpg',
        },
      };

  static Map<String, dynamic> get profileErrorResponse => {
        'message': 'Failed to load profile',
      };
}
