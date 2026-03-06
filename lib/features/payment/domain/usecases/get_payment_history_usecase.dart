import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentHistoryUseCase {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase(this.repository);

  Future<List<Payment>> call() {
    return repository.fetchPaymentHistory();
  }
}
