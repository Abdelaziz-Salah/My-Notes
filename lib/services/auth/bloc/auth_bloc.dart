import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider _provider;

  AuthBloc(this._provider) : super(AuthStateUnInitialized(isLoading: true)) {
    on<AuthEventInitialize>(_onInitialize);
    on<AuthEventLogin>(_onLogin);
    on<AuthEventLogout>(_onLogout);
    on<AuthEventSendEmailVerification>(_onSendEmailVerification);
    on<AuthEventRegister>(_onRegister);
    on<AuthEventShouldRegister>(
        (event, emit) => emit(AuthStateRegistering(isLoading: false)));
    on<AuthEventShouldLogin>(
        (event, emit) => emit(AuthStateLoggedOut(isLoading: false)));
  }

  void _onInitialize(
    AuthEventInitialize event,
    Emitter<AuthState> emit,
  ) async {
    await _provider.initialize();
    final user = _provider.currentUser;

    if (user == null) {
      emit(AuthStateLoggedOut(isLoading: false));
    } else if (!user.isEmailVerified) {
      emit(AuthStateNeedsVerification(isLoading: false));
    } else {
      emit(AuthStateLoggedIn(user: user, isLoading: false));
    }
  }

  void _onLogin(
    AuthEventLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthStateLoggedOut(
      isLoading: true,
      loadingText: "Please wait while I log you in",
    ));
    final email = event.email;
    final password = event.password;

    try {
      final user = await _provider.logIn(
        email: email,
        password: password,
      );
      log(user.toString());

      if (!user.isEmailVerified) {
        emit(AuthStateLoggedOut(isLoading: false));
        emit(AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedOut(isLoading: false));
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    } on UserNotFoundAuthException {
      emit(AuthStateLoggedOut(
          error: "No user found for that email.", isLoading: false));
    } on WrongPasswordAuthException {
      emit(AuthStateLoggedOut(
          error: "Wrong password provided for that user.", isLoading: false));
    } on GenericAuthException catch (error) {
      emit(AuthStateLoggedOut(error: error.errorCode, isLoading: false));
    } on Exception catch (_) {
      emit(AuthStateLoggedOut(error: "Authentication error", isLoading: false));
    }
  }

  void _onLogout(
    AuthEventLogout event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _provider.logout();

      emit(AuthStateLoggedOut(isLoading: false));
    } on Exception catch (error) {
      emit(AuthStateLoggedOut(error: error.toString(), isLoading: false));
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

      emit(AuthStateLoggedIn(user: user, isLoading: false));
    } on InvalidEmailAuthException {
      emit(AuthStateRegistering(error: "Invalid Email", isLoading: false));
    } on WeakPasswordAuthException {
      emit(AuthStateRegistering(error: "Weak Password", isLoading: false));
    } on EmailAlreadyInUseAuthException {
      emit(AuthStateRegistering(
          error: "Email is already in use", isLoading: false));
    } on GenericAuthException catch (error) {
      emit(AuthStateRegistering(error: error.errorCode, isLoading: false));
    } on Exception catch (_) {
      emit(AuthStateRegistering(
          error: "Authentication error", isLoading: false));
    }
  }
}
