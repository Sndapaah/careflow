import 'package:equatable/equatable.dart';

/// Domain-level error type. Data sources translate their own exceptions into
/// one of these so the presentation layer never sees transport details.
sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];

  @override
  String toString() => '$runtimeType($message)';
}

/// The backend was reachable but rejected the request.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end.']);
}

/// No usable connection.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please try again.',
  ]);
}

/// Bad credentials, expired session, wrong OTP.
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Those details did not match.']);
}

/// Local storage read/write problem.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read saved data.']);
}

/// The requested resource does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find that.']);
}

/// Device location is unavailable or permission was denied.
final class LocationFailure extends Failure {
  const LocationFailure([
    super.message = 'We need your location to find nearby care.',
  ]);
}
