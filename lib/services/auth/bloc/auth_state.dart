import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn(this.user);
}

// class AuthStateLoginFailure extends AuthState {
//   final Exception exception;

//   const AuthStateLoginFailure(this.exception);
// }

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  final String? error;
  final bool isLoginButtonEnabled;

  const AuthStateLoggedOut({this.error, this.isLoginButtonEnabled = true});
}

// class AuthStateLogoutFailure extends AuthState {
//   final Exception exception;

//   const AuthStateLogoutFailure(this.exception);
// }
