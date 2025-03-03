import 'package:bloc/bloc.dart';
import 'package:customer/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthenticationRepository _authenticationRepository;
  AuthBloc(this._authenticationRepository) : super(AuthInitial()) {
    on<AuthLoginRequest>(_onAuthLoginRequest);
  }

  Future<void> _onAuthLoginRequest(
      AuthLoginRequest event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result =
          await _authenticationRepository.login(event.email, event.password);
      emit(AuthSuccess(result));
    } catch (e) {
      emit(AuthFailure(message: 'Login failed'));
    }
  }
}
