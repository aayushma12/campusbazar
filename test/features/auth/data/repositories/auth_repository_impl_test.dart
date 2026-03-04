import 'package:campus_bazar/core/error/failures.dart';
import 'package:campus_bazar/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:campus_bazar/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:campus_bazar/features/auth/data/models/auth_user_model.dart';
import 'package:campus_bazar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDatasource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(
      const AuthUserModel(
        id: 'fallback',
        email: 'fallback@test.com',
        name: 'Fallback',
        token: 'fallback-token',
      ),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDatasource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tAuthUserModel = AuthUserModel(
      id: '1',
      email: tEmail,
      name: 'Test User',
      token: 'fake_token',
    );

    test('should return AuthUser when login is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tAuthUserModel);
      when(() => mockLocalDataSource.cacheUser(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.login(tEmail, tPassword);

      // assert
      expect(result, equals(const Right(tAuthUserModel)));
      verify(() => mockRemoteDataSource.login(email: tEmail, password: tPassword))
          .called(1);
      verify(() => mockLocalDataSource.cacheUser(tAuthUserModel)).called(1);
    });

    test('should return ServerFailure when login fails', () async {
      // arrange
      const errorMessage = 'Invalid credentials';
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception(errorMessage));

      // act
      final result = await repository.login(tEmail, tPassword);

      // assert
      expect(result, equals(Left(ServerFailure(errorMessage))));
      verify(() => mockRemoteDataSource.login(email: tEmail, password: tPassword))
          .called(1);
      verifyNever(() => mockLocalDataSource.cacheUser(any()));
    });
  });

  group('register', () {
    const tName = 'Test User';
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tAuthUserModel = AuthUserModel(
      id: '1',
      email: tEmail,
      name: tName,
      token: 'fake_token',
    );

    test('should return AuthUser when registration is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tAuthUserModel);
      when(() => mockLocalDataSource.cacheUser(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.register(tName, tEmail, tPassword);

      // assert
      expect(result, equals(const Right(tAuthUserModel)));
      verify(() => mockRemoteDataSource.register(
            name: tName,
            email: tEmail,
            password: tPassword,
          )).called(1);
      verify(() => mockLocalDataSource.cacheUser(tAuthUserModel)).called(1);
    });

    test('should return ServerFailure when registration fails', () async {
      // arrange
      const errorMessage = 'Email already exists';
      when(() => mockRemoteDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception(errorMessage));

      // act
      final result = await repository.register(tName, tEmail, tPassword);

      // assert
      expect(result, equals(Left(ServerFailure(errorMessage))));
      verify(() => mockRemoteDataSource.register(
            name: tName,
            email: tEmail,
            password: tPassword,
          )).called(1);
      verifyNever(() => mockLocalDataSource.cacheUser(any()));
    });
  });
}
