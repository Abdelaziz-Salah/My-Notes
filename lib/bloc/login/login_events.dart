abstract class LoginEvent {}

class UsernameChangedEvent extends LoginEvent {
  final String username;
  UsernameChangedEvent(this.username);
}

// Password changed event
class PasswordChangedEvent extends LoginEvent {
  final String password;
  PasswordChangedEvent(this.password);
}

// Login form submitted event
class LoginSubmittedEvent extends LoginEvent {
  final String username;
  final String password;
  LoginSubmittedEvent(this.username, this.password);
}