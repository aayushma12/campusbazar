import 'dart:io';
import 'package:campus_bazar/core/api/api_client.dart';
import 'package:campus_bazar/core/api/api_endpoints.dart';
import 'package:campus_bazar/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:campus_bazar/features/profile/data/models/profile_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockFile extends Mock implements File {}

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProfileRemoteDataSourceImpl(mockApiClient);
  });

  group('getProfile', () {
    final tProfileModel = ProfileModel(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      profilePicture: 'https://example.com/image.jpg',
    );

    final tSuccessResponse = {
      'data': {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'profilePicture': 'https://example.com/image.jpg',
      },
    };

    test('should return ProfileModel when getProfile is successful', () async {
      // arrange
      when(() => mockApiClient.get(ApiEndpoints.profile))
          .thenAnswer((_) async => Response(
                data: tSuccessResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiEndpoints.profile),
              ));

      // act
      final result = await dataSource.getProfile();

      // assert
      expect(result, isA<ProfileModel>());
      expect(result.name, tProfileModel.name);
      expect(result.email, tProfileModel.email);
      verify(() => mockApiClient.get(ApiEndpoints.profile)).called(1);
    });

    test('should throw Exception when getProfile fails with DioException', () async {
      // arrange
      when(() => mockApiClient.get(ApiEndpoints.profile))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.profile),
        response: Response(
          data: {'message': 'Failed to load profile'},
          statusCode: 404,
          requestOptions: RequestOptions(path: ApiEndpoints.profile),
        ),
      ));

      // act & assert
      expect(
        () => dataSource.getProfile(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateProfile', () {
    final tProfileModel = ProfileModel(
      id: '1',
      name: 'Updated User',
      email: 'test@example.com',
      profilePicture: 'https://example.com/new-image.jpg',
    );

    final tUpdateData = {
      'name': 'Updated User',
    };

    final tSuccessResponse = {
      'data': {
        'id': '1',
        'name': 'Updated User',
        'email': 'test@example.com',
        'profilePicture': 'https://example.com/new-image.jpg',
      },
    };

    test('should return ProfileModel when updateProfile is successful without image', () async {
      // arrange
      when(() => mockApiClient.patch(
            ApiEndpoints.profile,
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: tSuccessResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.profile),
          ));

      // act
      final result = await dataSource.updateProfile(tUpdateData, null);

      // assert
      expect(result, isA<ProfileModel>());
      expect(result.name, tProfileModel.name);
      verify(() => mockApiClient.patch(
            ApiEndpoints.profile,
            data: any(named: 'data'),
          )).called(1);
    });

    test('should throw Exception when updateProfile fails', () async {
      // arrange
      when(() => mockApiClient.patch(
            ApiEndpoints.profile,
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.profile),
        response: Response(
          data: {'message': 'Failed to update profile'},
          statusCode: 400,
          requestOptions: RequestOptions(path: ApiEndpoints.profile),
        ),
      ));

      // act & assert
      expect(
        () => dataSource.updateProfile(tUpdateData, null),
        throwsA(isA<Exception>()),
      );
    });
  });
}
