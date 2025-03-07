part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  const AuthSuccess(this.token);

  @override
  // TODO: implement props
  List<Object> get props => [token];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthLogout extends AuthState {}

class AuthSignUp extends AuthState {
  final String result;
  const AuthSignUp({required this.result});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}

class AuthAuthenticated extends AuthState {
  final String userId; // Giả sử có thông tin userId
  AuthAuthenticated({required this.userId});
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class GetUser extends AuthState {
  final User user;

  GetUser(this.user);

  @override
  // TODO: implement props
  List<Object> get props => [user];
}