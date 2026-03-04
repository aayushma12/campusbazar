import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../payment/domain/entities/payment_entity.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/tutor_request_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/accept_tutor_request_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/confirm_booking_payment_usecase.dart';
import '../../domain/usecases/create_tutor_request_usecase.dart';
import '../../domain/usecases/fetch_wallet_balance_usecase.dart';
import '../../domain/usecases/get_booking_by_id_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import '../../domain/usecases/get_tutor_requests_usecase.dart';
import '../../domain/usecases/initiate_booking_payment_usecase.dart';
import 'booking_state.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(BookingRemoteDataSourceImpl(GetIt.instance<ApiClient>()));
});

final getTutorRequestsUseCaseProvider = Provider<GetTutorRequestsUseCase>((ref) {
  return GetTutorRequestsUseCase(ref.read(bookingRepositoryProvider));
});

final createTutorRequestUseCaseProvider = Provider<CreateTutorRequestUseCase>((ref) {
  return CreateTutorRequestUseCase(ref.read(bookingRepositoryProvider));
});

final acceptTutorRequestUseCaseProvider = Provider<AcceptTutorRequestUseCase>((ref) {
  return AcceptTutorRequestUseCase(ref.read(bookingRepositoryProvider));
});

final getBookingsUseCaseProvider = Provider<GetBookingsUseCase>((ref) {
  return GetBookingsUseCase(ref.read(bookingRepositoryProvider));
});

final getBookingByIdUseCaseProvider = Provider<GetBookingByIdUseCase>((ref) {
  return GetBookingByIdUseCase(ref.read(bookingRepositoryProvider));
});

final initiateBookingPaymentUseCaseProvider = Provider<InitiateBookingPaymentUseCase>((ref) {
  return InitiateBookingPaymentUseCase(ref.read(bookingRepositoryProvider));
});

final confirmBookingPaymentUseCaseProvider = Provider<ConfirmBookingPaymentUseCase>((ref) {
  return ConfirmBookingPaymentUseCase(ref.read(bookingRepositoryProvider));
});

final cancelBookingUseCaseProvider = Provider<CancelBookingUseCase>((ref) {
  return CancelBookingUseCase(ref.read(bookingRepositoryProvider));
});

final fetchWalletBalanceUseCaseProvider = Provider<FetchWalletBalanceUseCase>((ref) {
  return FetchWalletBalanceUseCase(ref.read(bookingRepositoryProvider));
});

final bookingNotifierProvider = NotifierProvider<BookingNotifier, BookingState>(BookingNotifier.new);

// Backward compatibility with old imports
final bookingViewModelProvider = bookingNotifierProvider;

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() => const BookingState();

  Future<void> loadTutorRequests() async {
    state = state.copyWith(
      tutorRequestsStatus: TutorRequestsStatus.loading,
      clearError: true,
      clearSuccess: true,
      unauthorized: false,
    );

    try {
      final requests = await ref.read(getTutorRequestsUseCaseProvider).call();
      state = state.copyWith(
        tutorRequestsStatus: TutorRequestsStatus.loaded,
        tutorRequests: requests,
      );
    } catch (e) {
      state = state.copyWith(
        tutorRequestsStatus: TutorRequestsStatus.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> createTutorRequest({
    required String subject,
    required String description,
    required String schedule,
  }) async {
    final request = TutorRequestEntity(
      id: '',
      studentId: '',
      studentName: '',
      subject: subject,
      description: description,
      schedule: schedule,
      status: 'open',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      tutorRequestsStatus: TutorRequestsStatus.loading,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(createTutorRequestUseCaseProvider).call(request);
      await loadTutorRequests();
      state = state.copyWith(successMessage: 'Tutor request created successfully.');
    } catch (e) {
      state = state.copyWith(
        tutorRequestsStatus: TutorRequestsStatus.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> acceptTutorRequest(String requestId) async {
    final previous = List<TutorRequestEntity>.from(state.tutorRequests);
    final optimistic = previous.where((e) => e.id != requestId).toList();

    state = state.copyWith(
      tutorRequests: optimistic,
      bookingStatus: BookingStatusUi.updating,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(acceptTutorRequestUseCaseProvider).call(requestId);
      await loadTutorRequests();
      await loadWalletBalance();
      state = state.copyWith(successMessage: 'Tutor request accepted.');
    } catch (e) {
      state = state.copyWith(
        tutorRequests: previous,
        bookingStatus: BookingStatusUi.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> loadBookings({String role = 'student'}) async {
    state = state.copyWith(
      bookingStatus: BookingStatusUi.loading,
      currentRole: role,
      clearError: true,
      clearSuccess: true,
      unauthorized: false,
    );

    try {
      final bookings = await ref.read(getBookingsUseCaseProvider).call(role: role);
      state = state.copyWith(
        bookingStatus: BookingStatusUi.loaded,
        bookings: bookings,
      );
    } catch (e) {
      state = state.copyWith(
        bookingStatus: BookingStatusUi.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> loadBookingById(String bookingId) async {
    state = state.copyWith(
      bookingStatus: BookingStatusUi.loading,
      clearError: true,
      unauthorized: false,
    );

    try {
      final booking = await ref.read(getBookingByIdUseCaseProvider).call(bookingId);
      state = state.copyWith(
        bookingStatus: BookingStatusUi.loaded,
        selectedBooking: booking,
      );
    } catch (e) {
      state = state.copyWith(
        bookingStatus: BookingStatusUi.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<Payment?> initiateBookingPayment(String bookingId) async {
    state = state.copyWith(
      paymentStatus: BookingPaymentStatusUi.initiating,
      clearError: true,
      clearSuccess: true,
      unauthorized: false,
    );

    try {
      final payment = await ref.read(initiateBookingPaymentUseCaseProvider).call(bookingId);
      state = state.copyWith(paymentStatus: BookingPaymentStatusUi.success);
      return payment;
    } catch (e) {
      state = state.copyWith(
        paymentStatus: BookingPaymentStatusUi.failure,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
      return null;
    }
  }

  Future<void> confirmBookingPayment(
    String bookingId, {
    required String transactionCode,
    required String transactionUUID,
    required String amount,
  }) async {
    state = state.copyWith(paymentStatus: BookingPaymentStatusUi.initiating, clearError: true);

    try {
      await ref.read(confirmBookingPaymentUseCaseProvider).call(
            bookingId,
            transactionCode: transactionCode,
            transactionUUID: transactionUUID,
            amount: amount,
          );
      state = state.copyWith(
        paymentStatus: BookingPaymentStatusUi.success,
        successMessage: 'Booking payment confirmed.',
      );
      await loadBookingById(bookingId);
      await loadBookings(role: state.currentRole);
    } catch (e) {
      state = state.copyWith(
        paymentStatus: BookingPaymentStatusUi.failure,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    state = state.copyWith(bookingStatus: BookingStatusUi.updating, clearError: true, clearSuccess: true);

    try {
      await ref.read(cancelBookingUseCaseProvider).call(bookingId);
      state = state.copyWith(successMessage: 'Booking cancelled successfully.');
      await loadBookings(role: state.currentRole);
      if (state.selectedBooking?.id == bookingId) {
        await loadBookingById(bookingId);
      }
    } catch (e) {
      state = state.copyWith(
        bookingStatus: BookingStatusUi.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> loadWalletBalance() async {
    try {
      final balance = await ref.read(fetchWalletBalanceUseCaseProvider).call();
      state = state.copyWith(walletBalance: balance);
    } catch (_) {
      // Wallet is optional; suppress errors from UI flow.
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true, unauthorized: false);
  }

  String _msg(Object e) => e.toString().replaceAll('Exception: ', '').trim();

  bool _isUnauthorized(Object e) {
    final lower = _msg(e).toLowerCase();
    return lower.contains('401') || lower.contains('unauthorized');
  }
}
