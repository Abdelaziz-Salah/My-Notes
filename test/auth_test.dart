import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();

    test("Shouldn't be initialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot logout before initializing", () {
      expect(provider.logout(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test("Should be able to be initialized", () async {
      await provider.initialize();

      expect(provider.isInitialized, true);
    });

    test("Should be able to be initialized in less than 2 sec", () async {
      await provider.initialize();

      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
  });
}

class NotInitializedException implements Exception {}



class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    await Future.delayed(const Duration(seconds: 2));

    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "meme@me.com") throw UserNotFoundAuthException();
    if (password == "123456") throw WrongPasswordAuthException();

    const user = AuthUser(isEmailVerified: false);
    _user = user;

    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = const AuthUser(isEmailVerified: true);
  }
}
