import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider _provider;

  AuthBloc(this._provider) : super(AuthStateLoading()) {
    on<AuthEventInitialize>(_onInitialize);
    on<AuthEventLogin>(_onLogin);
    on<AuthEventLogout>(_onLogout);
    on<AuthEventSendEmailVerification>(_onSendEmailVerification);
    on<AuthEventCreateUser>(_onCreateUser);
    on<AuthEventLoginDebounceComplete>(_onLoginDebounceComplete);
  }

  void _onInitialize(
    AuthEventInitialize event,
    Emitter<AuthState> emit,
  ) async {
    await _provider.initialize();
    final user = _provider.currentUser;

    if (user == null) {
      emit(AuthStateLoggedOut());
    } else if (!user.isEmailVerified) {
      emit(AuthStateNeedsVerification());
    } else {
      emit(AuthStateLoggedIn(user));
    }
  }

  void _onLogin(
    AuthEventLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthStateLoggedOut(isLoginButtonEnabled: false));

    final email = event.email;
    final password = event.password;

    try {
      final user = await _provider.logIn(
        email: email,
        password: password,
      );

      log(user.toString());
      emit(AuthStateLoggedIn(user));
    } on UserNotFoundAuthException {
      emit(AuthStateLoggedOut(error: "No user found for that email."));
    } on WrongPasswordAuthException {
      emit(AuthStateLoggedOut(error: "Wrong password provided for that user."));
    } on GenericAuthException catch (error) {
      emit(AuthStateLoggedOut(error: error.errorCode));
    } on Exception catch (_) {
      emit(AuthStateLoggedOut(error: "Authentication error"));
    }
  }

  void _onLogout(
    AuthEventLogout event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthStateLoading());

    try {
      await _provider.logout();

      emit(AuthStateLoggedOut());
    } on Exception catch (error) {
      emit(AuthStateLoggedOut(error: error.toString()));
    }
  }

  void _onSendEmailVerification(
    AuthEventSendEmailVerification event,
    Emitter<AuthState> emit,
  ) async {
    await _provider.sendEmailVerification();
  }

  void _onCreateUser(
    AuthEventCreateUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthStateLoading());

    final email = event.email;
    final password = event.password;

    try {
      final user = await _provider.createUser(
        email: email,
        password: password,
      );

      log(user.toString());
      emit(AuthStateLoggedIn(user));
    } on Exception catch (error) {
      emit(AuthStateLoggedOut(error: error.toString()));
    }
  }

  void _onLoginDebounceComplete(
    AuthEventLoginDebounceComplete event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthStateLoggedOut(isLoginButtonEnabled: true));
  }
}
