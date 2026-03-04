import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> initiateProductPayment(String productId);
  Future<PaymentModel> initiateCartPayment(List<Map<String, dynamic>> cartItems);
  Future<PaymentModel> initiateBookingPayment(String bookingId, double amount);
  Future<PaymentModel> verifyPayment({
    required String transactionId,
    required String amount,
    required String transactionCode,
  });
  Future<List<PaymentModel>> fetchPaymentHistory();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;

  PaymentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaymentModel> initiateProductPayment(String productId) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.paymentInit,
        data: {'productId': productId},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return PaymentModel.fromInitJson(data, productId: productId);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to initialize payment'));
    }
  }

  @override
  Future<PaymentModel> initiateCartPayment(List<Map<String, dynamic>> cartItems) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.paymentInitCart,
        data: {'cartItems': cartItems},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return PaymentModel.fromInitJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to initialize cart payment'));
    }
  }

  @override
  Future<PaymentModel> initiateBookingPayment(String bookingId, double amount) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.paymentInitBooking,
        data: {'bookingId': bookingId, 'amount': amount},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return PaymentModel.fromInitJson(data, productId: bookingId);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to initialize booking payment'));
    }
  }

  @override
  Future<PaymentModel> verifyPayment({
    required String transactionId,
    required String amount,
    required String transactionCode,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.paymentVerify,
        data: {
          'transactionUUID': transactionId,
          'amount': amount,
          'transactionCode': transactionCode,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return PaymentModel.fromTransactionJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Payment verification failed'));
    }
  }

  @override
  Future<List<PaymentModel>> fetchPaymentHistory() async {
    try {
      final response = await apiClient.get(ApiEndpoints.paymentHistory);
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? const [];
      return list.whereType<Map<String, dynamic>>().map(PaymentModel.fromTransactionJson).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to load payment history'));
    }
  }

  String _parseError(DioException e, {required String fallback}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map<String, dynamic> ? data['message']?.toString() : null;

    if (status == 401) return 'Unauthorized. Please login again.';
    if (status == 400) return message ?? 'Invalid payment request.';
    if (status == 500) return message ?? 'Server error. Please try again.';
    return message ?? e.message ?? fallback;
  }
}
