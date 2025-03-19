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
  final User user;
  const AuthSignUp({required this.user});

  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class AuthAuthenticated extends AuthState {
  final String userId; // Giả sử có thông tin userId
  const AuthAuthenticated({required this.userId});
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
}

class GetUser extends AuthState {
  final User user;

  const GetUser(this.user);

  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class UpdateUserSuccess extends AuthState {
  final User user;

  const UpdateUserSuccess(this.user);

  @override
  // TODO: implement props
  List<Object> get props => [user];
}
