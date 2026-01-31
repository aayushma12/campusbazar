import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../api/api_client.dart';
import '../network/network_info.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl(instanceName: 'authBox')),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sl(instanceName: 'profileBox')),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ApiClient(dio: sl(), authLocalDataSource: sl()));

  // External
  sl.registerLazySingleton(() => Dio());
  // sl.registerLazySingleton(() => InternetConnectionChecker());
  
  // Hive Boxes
  final authBox = await Hive.openBox('authBox');
  final profileBox = await Hive.openBox('profileBox');
  sl.registerLazySingleton<Box>(() => authBox, instanceName: 'authBox');
  sl.registerLazySingleton<Box>(() => profileBox, instanceName: 'profileBox');

  // Note: ApiClient needs Dio and AuthLocalDataSource. 
  // ApiClient modifies the injected Dio instance. 
  // However, AuthRemoteDataSource also needs Dio.
  // We should pass the Dio instance from ApiClient or ensure ApiClient setup is done.
  // Actually, ApiClient constructor modifies the passed Dio.
  // So we should instantiate ApiClient once so the interceptors are added.
  // Or simpler: pass ApiClient to RemoteDataSources? 
  // The guide has AuthRemoteDataSource taking Dio.
  // Let's manually trigger ApiClient init or just resolve it.
  sl<ApiClient>(); // Force init
}
