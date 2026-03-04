import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> createPayment(List<String> productIds, double amount);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient _apiClient;
  TransactionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.transactions);
      final data = response.data['data'] as List<dynamic>?;
      return data != null
          ? data.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList()
          : [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to load transactions');
    }
  }

  @override
  Future<void> createPayment(List<String> productIds, double amount) async {
    try {
      await _apiClient.post(ApiEndpoints.paymentCreate, data: {
        'productIds': productIds,
        'amount': amount,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to create payment');
    }
  }
}
