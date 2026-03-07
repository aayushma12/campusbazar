import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../payment/data/models/payment_model.dart';
import '../models/booking_model.dart';
import '../models/tutor_request_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<TutorRequestModel>> getTutorRequests();
  Future<TutorRequestModel> createTutorRequest(TutorRequestModel request);
  Future<void> acceptTutorRequest(String requestId);

  Future<List<BookingModel>> getBookings({String role});
  Future<BookingModel> getBookingById(String bookingId);

  Future<PaymentModel> initiateBookingPayment(String bookingId);
  Future<void> confirmBookingPayment(
    String bookingId, {
    required String transactionCode,
    required String transactionUUID,
    required String amount,
  });

  Future<void> cancelBooking(String bookingId);
  Future<double> fetchWalletBalance();
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient _apiClient;
  BookingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TutorRequestModel>> getTutorRequests() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.tutorRequestsAvailable);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>? ?? const [];
      return data.whereType<Map<String, dynamic>>().map(TutorRequestModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to fetch tutor requests'));
    }
  }

  @override
  Future<TutorRequestModel> createTutorRequest(TutorRequestModel request) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.tutorRequestCreate, data: request.toRequestJson());
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return TutorRequestModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to create tutor request'));
    }
  }

  @override
  Future<void> acceptTutorRequest(String requestId) async {
    try {
      await _apiClient.post('${ApiEndpoints.tutorRequestAccept}/$requestId');
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to accept tutor request'));
    }
  }

  @override
  Future<List<BookingModel>> getBookings({String role = 'student'}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.myBookings,
        queryParameters: {'role': role},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>? ?? const [];
      return data.whereType<Map<String, dynamic>>().map(BookingModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to fetch bookings'));
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.bookings}/$bookingId');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return BookingModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to fetch booking detail'));
    }
  }

  @override
  Future<PaymentModel> initiateBookingPayment(String bookingId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.bookings}/$bookingId/initiate-payment');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return PaymentModel.fromInitJson(data, productId: bookingId);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to initiate booking payment'));
    }
  }

  @override
  Future<void> confirmBookingPayment(
    String bookingId, {
    required String transactionCode,
    required String transactionUUID,
    required String amount,
  }) async {
    try {
      await _apiClient.post(
        '${ApiEndpoints.bookings}/$bookingId/confirm-payment',
        data: {
          'transactionCode': transactionCode,
          'transactionUUID': transactionUUID,
          'amount': amount,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to confirm booking payment'));
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _apiClient.delete('${ApiEndpoints.bookings}/$bookingId');
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to cancel booking'));
    }
  }

  @override
  Future<double> fetchWalletBalance() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.bookingWallet);
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        return 0;
      }

      final dataRaw = body['data'];
      final data = dataRaw is Map<String, dynamic> ? dataRaw : const <String, dynamic>{};

      // Common payload shapes seen across backend versions:
      // 1) { data: { walletAmount: 1200 } }
      // 2) { data: { balance: 1000, pendingBalance: 200 } }
      // 3) { balance: 1000, pendingBalance: 200 }
      final walletAmount = _readAmount(data, const ['walletAmount', 'amount', 'walletBalance', 'totalBalance']);
      if (walletAmount != null) {
        return walletAmount;
      }

      final available = _readAmount(
            data,
            const ['balance', 'availableBalance', 'available', 'currentBalance'],
          ) ??
          _readAmount(
            body,
            const ['balance', 'availableBalance', 'available', 'currentBalance'],
          ) ??
          0;

      final pending = _readAmount(
            data,
            const ['pendingBalance', 'pending', 'holdBalance'],
          ) ??
          _readAmount(
            body,
            const ['pendingBalance', 'pending', 'holdBalance'],
          ) ??
          0;

      return available + pending;
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to fetch wallet balance'));
    }
  }

  double? _readAmount(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String _parseError(DioException e, {required String fallback}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = data is Map<String, dynamic> ? data['message']?.toString() : null;

    if (status == 401) return 'Unauthorized. Please login again.';
    if (status == 400) return msg ?? 'Invalid request data.';
    if (status == 404) return msg ?? 'Resource not found.';
    if (status == 409) return msg ?? 'Conflict: request already processed.';
    if (status == 500) return msg ?? 'Server error.';
    return msg ?? e.message ?? fallback;
  }
}
