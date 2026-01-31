class ApiEndpoints {
  ApiEndpoints._();

  // For Android Emulator: 'http://10.0.2.2:4000'
  // For Real Device (WIFI): Use your machine's IP (e.g., 'http://192.168.x.x:4000')
  // For iOS Simulator: 'http://localhost:4000'
  static const String baseUrl = 'http://10.0.2.2:4000'; 

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Endpoints ============
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/profile';
  
  static const String registerAdmin = '/api/auth/register/admin';
  static const String registerTutor = '/api/auth/register/tutor';
}
