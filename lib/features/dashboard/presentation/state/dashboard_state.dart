import '../../domain/entities/dashboard_product_entity.dart';

enum DashboardStatus {
  initial,
  loading,
  loaded,
  creating,
  success,
  error,
}

class DashboardState {
  final DashboardStatus status;
  final List<DashboardProduct> products;
  final String? errorMessage;
  final String? successMessage;
  final bool unauthorized;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.products = const [],
    this.errorMessage,
    this.successMessage,
    this.unauthorized = false,
  });

  bool get isLoading => status == DashboardStatus.loading;
  bool get isCreating => status == DashboardStatus.creating;

  DashboardState copyWith({
    DashboardStatus? status,
    List<DashboardProduct>? products,
    String? errorMessage,
    String? successMessage,
    bool? unauthorized,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: clearError ? null : errorMessage,
      successMessage: clearSuccess ? null : successMessage,
      unauthorized: unauthorized ?? this.unauthorized,
    );
  }
}
