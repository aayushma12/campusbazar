import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tutor_request_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../state/booking_state.dart';
import '../../../../core/services/service_locator.dart';

final bookingViewModelProvider = NotifierProvider<BookingViewModel, BookingState>(
  BookingViewModel.new,
);

class BookingViewModel extends Notifier<BookingState> {
  late final BookingRepository _repository;

  @override
  BookingState build() {
    _repository = sl<BookingRepository>();
    return const BookingState();
  }

  Future<void> loadBookings({String? type}) async {
    state = state.copyWith(status: BookingStatusView.loading, isLoading: true);
    try {
      final data = await _repository.getBookings(role: type ?? 'student');
      state = state.copyWith(status: BookingStatusView.success, bookings: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(status: BookingStatusView.error, errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> createBooking(Map<String, dynamic> body) async {
    try {
      final request = TutorRequestEntity(
        id: '',
        studentId: '',
        studentName: '',
        subject: (body['subject'] ?? '').toString(),
        description: (body['description'] ?? '').toString(),
        schedule: (body['schedule'] ?? body['preferredTime'] ?? '').toString(),
        status: 'open',
        createdAt: DateTime.now(),
      );
      await _repository.createTutorRequest(request);
      await loadBookings(type: 'student');
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateBookingStatus(String id, String status) async {
    try {
      if (status.toLowerCase() == 'accepted') {
        await _repository.acceptTutorRequest(id);
      }
      await loadBookings(type: 'tutor');
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
