import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({String message = "Local Database Failure"})
    : super(message);
}

class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({String message = "API Failure", this.statusCode})
    : super(message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = "Network connection failed"})
    : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure({String message = "Authentication failed"})
    : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure({String message = "Validation failed"})
    : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = "Cache Failure"})
    : super(message);
}
