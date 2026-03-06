import '../../domain/entities/booking_entity.dart';

enum BookingStatusView { initial, loading, success, error }

class BookingState {
  final BookingStatusView status;
  final List<BookingEntity> bookings;
  final String? errorMessage;
  final bool isLoading;

  const BookingState({
    this.status = BookingStatusView.initial,
    this.bookings = const [],
    this.errorMessage,
    this.isLoading = false,
  });

  BookingState copyWith({
    BookingStatusView? status,
    List<BookingEntity>? bookings,
    String? errorMessage,
    bool? isLoading,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
