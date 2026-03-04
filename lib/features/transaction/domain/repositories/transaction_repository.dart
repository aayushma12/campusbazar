import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> createPayment(List<String> productIds, double amount);
}
