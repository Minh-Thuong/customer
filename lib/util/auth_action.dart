import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/util/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void AuthAction(BuildContext context, Map<String, dynamic> data, bool islogin) {
  final authBloc = BlocProvider.of<AuthBloc>(context);

  if (islogin) {
    authBloc.add(
        AuthLoginRequest(email: data['email']!, password: data['password']!));
  } else {
    
    authBloc.add(AuthSignupRequest(
        name: data['name']!,
        email: data['email']!,
        phone: data['phone']!,
        address: data['address']!,
        password: data['password']!));
  }
}

Future<void> AuthLogout(BuildContext context) async {
  // Xoá token trong SharedPreferences
  await TokenManager.deleteToken();
}
