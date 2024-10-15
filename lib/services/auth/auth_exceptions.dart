class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class GenericAuthException implements Exception {
  final String errorCode;

  GenericAuthException(this.errorCode);
}

class UserNotLoggedInAuthException implements Exception {}
