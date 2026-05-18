sealed class AuthException implements Exception {
  const AuthException();
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException();
}

class ServerAuthException extends AuthException {
  const ServerAuthException(this.message);
  final String message;
}
