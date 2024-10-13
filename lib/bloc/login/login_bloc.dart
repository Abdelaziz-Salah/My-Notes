import 'package:bloc/bloc.dart';
import 'package:mynotes/bloc/login/login_events.dart';
import 'package:mynotes/bloc/login/login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState()) {
    on<UsernameChangedEvent>(_onUsernameChanged);
    on<PasswordChangedEvent>(_onPasswordChanged);
    on<LoginSubmittedEvent>(_onLoginSubmittedEvent);
  }

  void _onUsernameChanged(
    UsernameChangedEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitialState());
  }

  void _onPasswordChanged(
    PasswordChangedEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitialState());
  }

  void _onLoginSubmittedEvent(
      LoginSubmittedEvent event, Emitter<LoginState> emit) async {
    emit(LoginValidatingState());

    // Simulating input validation (like checking for non-empty fields)
    if (event.username.isEmpty || event.password.isEmpty) {
      emit(LoginErrorState("Username or password cannot be empty."));
      return;
    }

    // Simulating a login process (this could be a call to an API)
    await Future.delayed(Duration(seconds: 2)); // Fake delay for login

    // Here we can assume login always fails for demo purposes
    if (event.username == "user" && event.password == "password") {
      emit(LoginSuccessState());
    } else {
      emit(LoginErrorState("Invalid credentials."));
    }
  }
}
