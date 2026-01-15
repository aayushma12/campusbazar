class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  // NOTE: Change this to your backend server URL
  // For Android Emulator use: 'http://10.0.2.2:3000'
  // For iOS Simulator use: 'http://localhost:3000'
  // For Physical Device use your computer's IP: 'http://192.168.1.x:3000'
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.100:3000'; // Physical Device - Change IP

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String register = '/api/auth/register';
  static const String registerAdmin = '/api/auth/register/admin';
  static const String registerTutor = '/api/auth/register/tutor';
  static const String login = '/api/auth/login';
  
  // Add more endpoints as needed
  // static const String logout = '/auth/logout';
  // static const String refreshToken = '/auth/refresh';
  // static const String forgotPassword = '/auth/forgot-password';
}
