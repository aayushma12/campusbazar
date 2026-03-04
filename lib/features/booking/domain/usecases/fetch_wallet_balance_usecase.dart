import '../repositories/booking_repository.dart';

class FetchWalletBalanceUseCase {
  final BookingRepository repository;

  FetchWalletBalanceUseCase(this.repository);

  Future<double> call() {
    return repository.fetchWalletBalance();
  }
}
