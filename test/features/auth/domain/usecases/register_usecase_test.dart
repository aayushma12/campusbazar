import 'package:campus_bazar/core/error/failures.dart';
import 'package:campus_bazar/features/auth/domain/entities/auth_user.dart';
import 'package:campus_bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_bazar/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  const tName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthUser = AuthUser(
    id: '1',
    email: tEmail,
    name: tName,
    token: 'fake_token',
  );

  test('should get AuthUser from the repository when registration succeeds', () async {
    // arrange
    when(() => mockRepository.register(any(), any(), any()))
        .thenAnswer((_) async => const Right(tAuthUser));

    // act
    final result = await useCase(
      RegisterParams(name: tName, email: tEmail, password: tPassword),
    );

    // assert
    expect(result, equals(const Right(tAuthUser)));
    verify(() => mockRepository.register(tName, tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    // arrange
    const tFailure = ServerFailure('Email already exists');
    when(() => mockRepository.register(any(), any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(
      RegisterParams(name: tName, email: tEmail, password: tPassword),
    );

    // assert
    expect(result, equals(const Left(tFailure)));
    verify(() => mockRepository.register(tName, tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
