import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required UserRepository userRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationStatusChanged>(_onStatusChanged);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);

    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(AuthenticationStatusChanged(status)),
    );
  }

  final UserRepository _userRepository;
  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<AuthenticationStatus> _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationRepository.dispose();
    _authenticationStatusSubscription.cancel();
    return super.close();
  }

  // helper function
  Future<void> _onStatusChanged(AuthenticationStatusChanged event, Emitter<AuthenticationState> emit) async {
    switch (event.status) {
      case AuthenticationStatus.authenticated:
        final user = await _tryGetUser();
        emit(user != null ? AuthenticationState.authenticated(user) : const AuthenticationState.unauthenticated());
        break;

      case AuthenticationStatus.unauthenticated:
        emit(const AuthenticationState.unauthenticated());
        break;

      default:
        emit(const AuthenticationState.unknown());
        break;
    }
  }

  FutureOr<void> _onLogoutRequested(AuthenticationLogoutRequested event, Emitter<AuthenticationState> emit) {
    if (state.status != AuthenticationStatus.unauthenticated) {
      _authenticationRepository.logOut();
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future<User?> _tryGetUser() async {
    try {
      final user = await _userRepository.getUser();

      return user;
    } on Exception catch (_) {
      return null;
    }
  }
}
