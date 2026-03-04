import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/tutor_request_entity.dart';
import '../../../payment/domain/entities/payment_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/tutor_request_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;
  BookingRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TutorRequestEntity>> getTutorRequests() => _remoteDataSource.getTutorRequests();

  @override
  Future<TutorRequestEntity> createTutorRequest(TutorRequestEntity request) {
    final model = TutorRequestModel(
      id: request.id,
      studentId: request.studentId,
      studentName: request.studentName,
      subject: request.subject,
      description: request.description,
      schedule: request.schedule,
      status: request.status,
      createdAt: request.createdAt,
    );
    return _remoteDataSource.createTutorRequest(model);
  }

  @override
  Future<void> acceptTutorRequest(String requestId) => _remoteDataSource.acceptTutorRequest(requestId);

  @override
  Future<List<BookingEntity>> getBookings({String role = 'student'}) => _remoteDataSource.getBookings(role: role);

  @override
  Future<BookingEntity> getBookingById(String bookingId) => _remoteDataSource.getBookingById(bookingId);

  @override
  Future<Payment> initiateBookingPayment(String bookingId) => _remoteDataSource.initiateBookingPayment(bookingId);

  @override
  Future<void> confirmBookingPayment(
    String bookingId, {
    required String transactionCode,
    required String transactionUUID,
    required String amount,
  }) {
    return _remoteDataSource.confirmBookingPayment(
      bookingId,
      transactionCode: transactionCode,
      transactionUUID: transactionUUID,
      amount: amount,
    );
  }

  @override
  Future<void> cancelBooking(String bookingId) => _remoteDataSource.cancelBooking(bookingId);

  @override
  Future<double> fetchWalletBalance() => _remoteDataSource.fetchWalletBalance();
}
