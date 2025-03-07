import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:customer/model/user.dart';
import 'package:customer/repository/auth_repository.dart';
import 'package:customer/util/token_manager.dart';
import 'package:equatable/equatable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthenticationRepository _authenticationRepository;
  AuthBloc(this._authenticationRepository) : super(AuthInitial()) {
    on<AuthLoginRequest>(_onAuthLoginRequest);
    on<CheckLoginEvent>(_onCheckLoginEvent);
    on<AppStarted>(_onAppStarted); // Thêm sự kiện mới
    on<GetUserEvent>(_onGetMyInfor);
  }

  Future<void> _onAuthLoginRequest(
      AuthLoginRequest event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result =
          await _authenticationRepository.login(event.email, event.password);
      await TokenManager.saveToken(
          result); // Lưu token sau khi đăng nhập thành công
      emit(AuthSuccess(result));
      emit(AuthAuthenticated(userId: result));
    } catch (e) {
      emit(AuthFailure(message: 'Login failed'));
    }
  }

  Future<void> _onCheckLoginEvent(
      CheckLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final exp = prefs.getString('token_expiry');

      if (token != null && exp != null) {
        final expiryTime = DateTime.parse(exp);
        if (DateTime.now().isBefore(expiryTime)) {
          emit(AuthAuthenticated(userId: token)); // Token còn hạn
        } else {
          await prefs.remove('auth_token');
          await prefs.remove('token_expiry');
          emit(AuthUnauthenticated()); // Token hết hạn
        }
      } else {
        emit(AuthUnauthenticated()); // Không có token
      }
    } catch (e) {
      emit(AuthError(message: "Lỗi khi kiểm tra đăng nhập: $e"));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Trạng thái đang tải
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token'); // Lấy token
      final exp = prefs.getString('token_expiry'); // Lấy thời gian hết hạn

      if (token != null && exp != null) {
        final expiryTime = DateTime.parse(exp); // Chuyển expiry thành DateTime
        if (DateTime.now().isBefore(expiryTime)) {
          // Token còn hạn
          emit(AuthAuthenticated(userId: token));
        } else {
          // Token hết hạn, xóa token khỏi bộ nhớ
          await prefs.remove('auth_token');
          await prefs.remove('token_expiry');
          emit(AuthUnauthenticated());
        }
      } else {
        // Không có token
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: "Lỗi khi kiểm tra đăng nhập: $e"));
    }
  }

  Future<void> _onGetMyInfor(GetUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authenticationRepository.getUser();
      emit(GetUser( user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
