import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/tutor_request_entity.dart';

enum TutorRequestsStatus { initial, loading, loaded, error }
enum BookingStatusUi { initial, loading, loaded, updating, error }
enum BookingPaymentStatusUi { initial, initiating, success, failure }

class BookingState {
  final TutorRequestsStatus tutorRequestsStatus;
  final BookingStatusUi bookingStatus;
  final BookingPaymentStatusUi paymentStatus;

  final List<TutorRequestEntity> tutorRequests;
  final List<BookingEntity> bookings;
  final BookingEntity? selectedBooking;

  final double walletBalance;
  final String currentRole;

  final bool unauthorized;
  final String? errorMessage;
  final String? successMessage;

  const BookingState({
    this.tutorRequestsStatus = TutorRequestsStatus.initial,
    this.bookingStatus = BookingStatusUi.initial,
    this.paymentStatus = BookingPaymentStatusUi.initial,
    this.tutorRequests = const [],
    this.bookings = const [],
    this.selectedBooking,
    this.walletBalance = 0,
    this.currentRole = 'student',
    this.unauthorized = false,
    this.errorMessage,
    this.successMessage,
  });

  BookingState copyWith({
    TutorRequestsStatus? tutorRequestsStatus,
    BookingStatusUi? bookingStatus,
    BookingPaymentStatusUi? paymentStatus,
    List<TutorRequestEntity>? tutorRequests,
    List<BookingEntity>? bookings,
    BookingEntity? selectedBooking,
    double? walletBalance,
    String? currentRole,
    bool? unauthorized,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedBooking = false,
  }) {
    return BookingState(
      tutorRequestsStatus: tutorRequestsStatus ?? this.tutorRequestsStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      tutorRequests: tutorRequests ?? this.tutorRequests,
      bookings: bookings ?? this.bookings,
      selectedBooking: clearSelectedBooking ? null : (selectedBooking ?? this.selectedBooking),
      walletBalance: walletBalance ?? this.walletBalance,
      currentRole: currentRole ?? this.currentRole,
      unauthorized: unauthorized ?? this.unauthorized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
