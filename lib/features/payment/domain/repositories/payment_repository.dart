import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Payment> initiateProductPayment(String productId);
  Future<Payment> initiateCartPayment(List<Map<String, dynamic>> cartItems);
  Future<Payment> initiateBookingPayment(String bookingId, double amount);

  // Backend contract requires transaction UUID + decoded callback payload.
  Future<Payment> verifyPayment({
    required String transactionId,
    required String amount,
    required String transactionCode,
  });

  Future<List<Payment>> fetchPaymentHistory();
}
