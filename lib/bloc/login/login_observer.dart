import 'dart:developer';

import 'package:bloc/bloc.dart';

class LoginObserver extends BlocObserver {
  const LoginObserver();

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log("${bloc.runtimeType} $change");
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log("${bloc.runtimeType} $error $stackTrace");
    super.onError(bloc, error, stackTrace);
  }
}
