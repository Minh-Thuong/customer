part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequest extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequest({required this.email, required this.password});

  @override
  // TODO: implement props
  List<Object> get props => [email, password];
}

class AuthSignupRequest extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String password;

  const AuthSignupRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, phone, address, password];
}

class CheckLoginEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class AppStarted extends AuthEvent {} 

class GetUserEvent extends AuthEvent {}
