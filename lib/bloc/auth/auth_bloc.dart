import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:customer/model/update_infor_user.dart';
import 'package:customer/model/user.dart';
import 'package:customer/repository/auth_repository.dart';
import 'package:customer/util/token_manager.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthenticationRepository _authenticationRepository;
  // Khởi tạo GoogleSignIn với scope cần thiết
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ], // Scope để lấy email, bạn có thể thêm scope khác nếu cần
  );

  AuthBloc(this._authenticationRepository) : super(AuthInitial()) {
    on<AuthLoginRequest>(_onAuthLoginRequest);
    on<CheckLoginEvent>(_onCheckLoginEvent);
    on<AppStarted>(_onAppStarted); // Thêm sự kiện mới
    on<GetUserEvent>(_onGetMyInfor);
    on<LogoutEvent>(_onLogoutEvent);
    on<AuthGoogleRequest>(_onAuthByGoogle);
    on<UpdateUserEvent>(_onUpdateUser);
    on<AuthSignupRequest>(_onAuthSignupRequest);
  }

  Future<void> _onAuthSignupRequest(
      AuthSignupRequest event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authenticationRepository.signup(
          event.name, event.email, event.phone, event.address, event.password);

      emit(AuthSignUp(user: result));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onUpdateUser(
      UpdateUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authenticationRepository.updateInfor(
          event.id, event.userUpdate);
      emit(UpdateUserSuccess(user));
      emit(GetUser(user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutEvent(
      LogoutEvent event, Emitter<AuthState> emit) async {
    await _authenticationRepository.logout(event.token);
    await TokenManager.deleteToken();
    await _googleSignIn.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthLoginRequest(
      AuthLoginRequest event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result =
          await _authenticationRepository.login(event.email, event.password);
      // Lưu token sau khi đăng nhập thành công
      await TokenManager.saveToken(result);

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

  Future<void> _onGetMyInfor(
      GetUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authenticationRepository.getUser();
      emit(GetUser(user));
      // emit(UpdateUserSuccess(user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthByGoogle(
      AuthGoogleRequest event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Đăng nhập với Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthFailure(message: 'Google Sign-In cancelled'));
        return;
      }
      print(
          "email: ${googleUser.email} name: ${googleUser.displayName} image: ${googleUser.photoUrl}");
      // Gửi ID token đến API
      final jwtToken = await _authenticationRepository.loginbygoogle(
        googleUser.email,
        googleUser.displayName!,
        googleUser.photoUrl ?? '',
      );

      // Thành công, chuyển sang trạng thái AuthSuccess
      // Lưu token sau khi đăng nhập thành công
      await TokenManager.saveToken(jwtToken);

      emit(AuthSuccess(jwtToken));
      emit(AuthAuthenticated(userId: jwtToken));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
