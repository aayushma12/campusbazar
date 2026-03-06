import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_providers.dart';
import '../state/dashboard_state.dart';

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() => const DashboardState();

  Future<void> loadProducts({int page = 1, int limit = 20}) async {
    state = state.copyWith(
      status: DashboardStatus.loading,
      clearError: true,
      clearSuccess: true,
      unauthorized: false,
    );

    final result = await ref.read(getProductsUseCaseProvider).call(page: page, limit: limit);

    result.fold(
      (failure) {
        final unauthorized = _isUnauthorized(failure.message);
        state = state.copyWith(
          status: DashboardStatus.error,
          errorMessage: failure.message,
          unauthorized: unauthorized,
        );
      },
      (products) {
        state = state.copyWith(
          status: DashboardStatus.loaded,
          products: products,
          clearError: true,
          clearSuccess: true,
          unauthorized: false,
        );
      },
    );
  }

  Future<void> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String campus,
    required String condition,
    required bool negotiable,
    required List<File> imageFiles,
  }) async {
    state = state.copyWith(
      status: DashboardStatus.creating,
      clearError: true,
      clearSuccess: true,
      unauthorized: false,
    );

    final result = await ref.read(createProductUseCaseProvider).call(
          title: title,
          description: description,
          price: price,
          categoryId: categoryId,
          campus: campus,
          condition: condition,
          negotiable: negotiable,
          imageFiles: imageFiles,
        );

    result.fold(
      (failure) {
        final unauthorized = _isUnauthorized(failure.message);
        state = state.copyWith(
          status: DashboardStatus.error,
          errorMessage: failure.message,
          unauthorized: unauthorized,
        );
      },
      (created) {
        state = state.copyWith(
          status: DashboardStatus.success,
          products: [created, ...state.products],
          successMessage: 'Product created successfully',
          clearError: true,
          unauthorized: false,
        );
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true, unauthorized: false);
  }

  bool _isUnauthorized(String message) {
    final lower = message.toLowerCase();
    return lower.contains('401') || lower.contains('unauthorized');
  }
}
