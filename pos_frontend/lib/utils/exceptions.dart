class ApiException implements Exception {
  final String message;
  final int statusscode;

  const ApiException({required this.message, required this.statusscode});

  @override
  String toString() => 'ApiException [$statusscode] :$message)';
}

class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}
