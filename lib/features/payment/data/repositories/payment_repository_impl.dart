import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remote;

  PaymentRepositoryImpl({required this.remote});

  @override
  Future<Payment> initiateProductPayment(String productId) async {
    try {
      return await remote.initiateProductPayment(productId);
    } catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<Payment> initiateCartPayment(List<Map<String, dynamic>> cartItems) async {
    try {
      return await remote.initiateCartPayment(cartItems);
    } catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<Payment> initiateBookingPayment(String bookingId, double amount) async {
    try {
      return await remote.initiateBookingPayment(bookingId, amount);
    } catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<Payment> verifyPayment({
    required String transactionId,
    required String amount,
    required String transactionCode,
  }) async {
    try {
      return await remote.verifyPayment(
        transactionId: transactionId,
        amount: amount,
        transactionCode: transactionCode,
      );
    } catch (e) {
      throw Exception(_msg(e));
    }
  }

  @override
  Future<List<Payment>> fetchPaymentHistory() async {
    try {
      return await remote.fetchPaymentHistory();
    } catch (e) {
      throw Exception(_msg(e));
    }
  }

  String _msg(Object e) {
    return e.toString().replaceAll('Exception: ', '').trim();
  }
}
