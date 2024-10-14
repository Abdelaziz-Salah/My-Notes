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
    emit(AuthStateLoading());

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
      emit(AuthStateLoginFailure(Exception("No user found for that email.")));
    } on WrongPasswordAuthException {
      emit(AuthStateLoginFailure(
          Exception("Wrong password provided for that user.")));
    } on GenericAuthException catch (error) {
      emit(AuthStateLoginFailure(error));
    } on Exception catch (error) {
      emit(AuthStateLoginFailure(error));
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
      emit(AuthStateLogoutFailure(error));
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
      emit(AuthStateLoginFailure(error));
    }
  }
}
