import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  /// Optional runtime override:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.x.x:4000
  /// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000   (Android emulator)
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Smart default host per platform to avoid common local-network routing issues.
  static String get baseUrl {
    final overridden = _envBaseUrl.trim();
    if (overridden.isNotEmpty) return overridden;

    if (kIsWeb) {
      return 'http://localhost:4000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Works for physical Android device when using `adb reverse tcp:4000 tcp:4000`.
        // For emulator, override with --dart-define=API_BASE_URL=http://10.0.2.2:4000
        return 'http://127.0.0.1:4000';
      case TargetPlatform.iOS:
        return 'http://localhost:4000';
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:4000';
    }
  }

  /// Candidate base URLs used for automatic fallback when connection errors occur.
  /// Primary `baseUrl` is always first.
  static List<String> get fallbackBaseUrls {
    final candidates = <String>[baseUrl];

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Emulator host mapping.
      candidates.add('http://10.0.2.2:4000');
      // Physical device via adb reverse.
      candidates.add('http://127.0.0.1:4000');
      // Occasionally useful in desktop-hosted Android environments.
      candidates.add('http://localhost:4000');
    }

    final seen = <String>{};
    return candidates.where((e) => seen.add(e)).toList(growable: false);
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Endpoints ============
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String profile = '/api/v1/users/me';
  static const String profileSettings = '/api/v1/users/me/settings';
  static const String profilePushSettings = '/api/v1/users/me/settings/notifications';
  static const String profileChangePassword = '/api/v1/users/me/change-password';
  static const String profileDeleteAccount = '/api/v1/users/me/account';
  
  static const String registerAdmin = '/api/v1/auth/register/admin';
  static const String registerTutor = '/api/v1/auth/register/tutor';

  // Listing/Product endpoints
  static const String listings = '/api/v1/products';
  static const String categories = '/api/v1/categories';
  static const String userFavorites = '/api/v1/wishlist';

  // Cart
  static const String cart = '/api/v1/cart';

  // Orders
  static const String orders = '/api/v1/orders';

  // Bookings
  static const String bookings = '/api/v1/bookings';
  static const String myBookings = '/api/v1/bookings/mine';
  static const String bookingWallet = '/api/v1/bookings/wallet';

  // Tutor requests
  static const String tutorRequestCreate = '/api/v1/tutor/request';
  static const String tutorRequestAccept = '/api/v1/tutor/accept';
  static const String tutorRequestsAvailable = '/api/v1/tutor/available';
  static const String tutorRequestsMine = '/api/v1/tutor/my-requests';
  static const String tutorRequestsAccepted = '/api/v1/tutor/accepted-requests';

  // Chat
  static const String chat = '/api/v1/chats';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static const String notificationsUnreadCount = '/api/v1/notifications/unread-count';

  // Transactions/Payments
  static const String transactions = '/api/v1/payment';
  static const String paymentCreate = '/api/v1/payment/create';
  static const String paymentInit = '/api/v1/payment/init';
  static const String paymentInitCart = '/api/v1/payment/init-cart';
  static const String paymentVerify = '/api/v1/payment/verify';
  static const String paymentHistory = '/api/v1/payment/history';
  static const String paymentTransaction = '/api/v1/payment/transaction';
  static const String paymentInitBooking = '/api/v1/payment/init-booking';

  // Reports
  static const String reports = '/api/v1/reports';
}
