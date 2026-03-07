import 'package:campus_bazar/core/services/security/biometric_auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockLocalAuthentication localAuth;
  late MockFlutterSecureStorage secureStorage;
  late BiometricAuthService service;

  setUp(() {
    localAuth = MockLocalAuthentication();
    secureStorage = MockFlutterSecureStorage();

    service = BiometricAuthService(
      localAuth: localAuth,
      secureStorage: secureStorage,
    );
  });

  group('isBiometricAvailable', () {
    test('returns false when no biometrics are enrolled', () async {
      when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => localAuth.getAvailableBiometrics()).thenAnswer((_) async => <BiometricType>[]);

      final result = await service.isBiometricAvailable();

      expect(result, isFalse);
    });

    test('returns true when device supports and has enrolled biometrics', () async {
      when(() => localAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => localAuth.getAvailableBiometrics()).thenAnswer((_) async => <BiometricType>[BiometricType.weak]);

      final result = await service.isBiometricAvailable();

      expect(result, isTrue);
    });
  });

  group('disableBiometric', () {
    test('clears biometric keys and cancels active auth safely', () async {
      when(() => localAuth.stopAuthentication()).thenAnswer((_) async => true);
      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

      await service.disableBiometric();

      verify(() => localAuth.stopAuthentication()).called(1);
      verify(() => secureStorage.delete(key: 'biometric_login_enabled')).called(1);
      verify(() => secureStorage.delete(key: 'biometric_login_user')).called(1);
      verify(() => secureStorage.delete(key: 'biometric_login_email')).called(1);
      verify(() => secureStorage.delete(key: 'biometric_login_password')).called(1);
    });
  });
}
