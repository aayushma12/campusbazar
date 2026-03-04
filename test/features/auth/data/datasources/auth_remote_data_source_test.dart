import 'package:campus_bazar/core/api/api_client.dart';
import 'package:campus_bazar/core/api/api_endpoints.dart';
import 'package:campus_bazar/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:campus_bazar/features/auth/data/models/auth_user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthRemoteDatasource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDatasource(apiClient: mockApiClient);
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    final tSuccessResponse = {
      'user': {
        'id': '1',
        'email': tEmail,
        'name': 'Test User',
      },
      'accessToken': 'fake_token',
    };

    test('should return AuthUserModel when login is successful', () async {
      // arrange
      when(() => mockApiClient.post(
            ApiEndpoints.login,
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: tSuccessResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.login),
          ));

      // act
      final result = await dataSource.login(email: tEmail, password: tPassword);

      // assert
      expect(result, isA<AuthUserModel>());
      expect(result.email, tEmail);
      expect(result.token, 'fake_token');
      verify(() => mockApiClient.post(ApiEndpoints.login, data: any(named: 'data'))).called(1);
    });

    test('should throw an Exception when login fails with DioException', () async {
      // arrange
      when(() => mockApiClient.post(
            ApiEndpoints.login,
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        response: Response(
          data: {'message': 'Invalid credentials'},
          statusCode: 401,
          requestOptions: RequestOptions(path: ApiEndpoints.login),
        ),
      ));

      // act & assert
      expect(
        () => dataSource.login(email: tEmail, password: tPassword),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('register', () {
    const tName = 'Test User';
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('should return AuthUserModel when registration is successful', () async {
      // arrange
      when(() => mockApiClient.post(
            ApiEndpoints.register,
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: {
              'user': {'id': '1', 'email': tEmail, 'name': tName},
              'accessToken': 'fake_token'
            },
            statusCode: 201,
            requestOptions: RequestOptions(path: ApiEndpoints.register),
          ));

      // act
      final result = await dataSource.register(name: tName, email: tEmail, password: tPassword);

      // assert
      expect(result, isA<AuthUserModel>());
      expect(result.name, tName);
      verify(() => mockApiClient.post(ApiEndpoints.register, data: any(named: 'data'))).called(1);
    });
  });
}
