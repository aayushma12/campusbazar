import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/dashboard_local_data_source.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../state/dashboard_state.dart';
import '../view_model/dashboard_notifier.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(apiClient: GetIt.instance<ApiClient>());
});

final dashboardLocalDataSourceProvider = Provider<DashboardLocalDataSource>((ref) {
  return DashboardLocalDataSourceImpl();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.read(dashboardRemoteDataSourceProvider),
    localDataSource: ref.read(dashboardLocalDataSourceProvider),
    networkInfo: NetworkInfoImpl(),
  );
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.read(dashboardRepositoryProvider));
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  return CreateProductUseCase(ref.read(dashboardRepositoryProvider));
});

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
