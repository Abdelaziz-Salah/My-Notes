import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider _provider;

  AuthBloc(this._provider) : super(AuthStateUnInitialized()) {
    on<AuthEventInitialize>(_onInitialize);
    on<AuthEventLogin>(_onLogin);
    on<AuthEventLogout>(_onLogout);
    on<AuthEventSendEmailVerification>(_onSendEmailVerification);
    on<AuthEventRegister>(_onRegister);
    on<AuthEventShouldRegister>((event, emit) => emit(AuthStateRegistering()));
    on<AuthEventShouldLogin>((event, emit) => emit(AuthStateLoggedOut()));
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
    emit(AuthStateLoggedOut(isLoading: true));

    final email = event.email;
    final password = event.password;

    try {
      final user = await _provider.logIn(
        email: email,
        password: password,
      );
      log(user.toString());

      if (!user.isEmailVerified) {
        emit(AuthStateLoggedOut());
        emit(AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedOut());
        emit(AuthStateLoggedIn(user));
      }
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
    emit(AuthStateUnInitialized());

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
    emit(state);
  }

  void _onRegister(
    AuthEventRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthStateRegistering(isLoading: true));

    final email = event.email;
    final password = event.password;

    try {
      final user = await _provider.createUser(
        email: email,
        password: password,
      );
      log(user.toString());

      await _provider.sendEmailVerification();

      emit(AuthStateLoggedIn(user));
    } on InvalidEmailAuthException {
      emit(AuthStateRegistering(error: "Invalid Email"));
    } on WeakPasswordAuthException {
      emit(AuthStateRegistering(error: "Weak Password"));
    } on EmailAlreadyInUseAuthException {
      emit(AuthStateRegistering(error: "Email is already in use"));
    } on GenericAuthException catch (error) {
      emit(AuthStateRegistering(error: error.errorCode));
    } on Exception catch (_) {
      emit(AuthStateRegistering(error: "Authentication error"));
    }
  }
}
