import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TransactionEntity>> getTransactions() => _remoteDataSource.getTransactions();

  @override
  Future<void> createPayment(List<String> productIds, double amount) =>
      _remoteDataSource.createPayment(productIds, amount);
}
