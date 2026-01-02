// lib/core/error/failures.dart

class Failure {
  final String message;
  Failure(this.message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}
