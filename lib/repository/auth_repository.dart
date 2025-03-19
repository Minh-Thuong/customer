import 'package:customer/datasource/auth_datasource.dart';
import 'package:customer/model/update_infor_user.dart';
import 'package:customer/model/user.dart';
import 'package:either_dart/either.dart';

abstract class IAuthenticationRepository {
  Future<String> login(String email, String password);
  Future<User> getUser();
  Future<void> logout(String token);
  Future<String> loginbygoogle(String email, String name, String imageUrl);
  Future<User> updateInfor(String id, UserUpdate update);
  Future<User> signup(
      String name, String email, String phone, String address, String password);
}

class AuthenticationRepository extends IAuthenticationRepository {
  final IAuthenticationDatasource _authenticationDatasource;

  AuthenticationRepository(this._authenticationDatasource);

  @override
  Future<String> login(String email, String password) async {
    try {
      final token = await _authenticationDatasource.login(email, password);
      if (token.isNotEmpty) {
        return token;
      } else {
        throw Exception("API trả về lỗi: Token rỗng");
      }
    } catch (e) {
      throw Exception(
          "Lỗi đăng nhập: ${e.toString()}"); // Hiển thị thông báo dễ hiểu hơn
    }
  }

  @override
  Future<User> getUser() async {
    try {
      final user = await _authenticationDatasource.getUser();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      final user = await _authenticationDatasource.logout(token);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> loginbygoogle(
      String email, String name, String imageUrl) async {
    try {
      final result =
          await _authenticationDatasource.loginbygoogle(email, name, imageUrl);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> updateInfor(String id, UserUpdate update) async {
    try {
      final result = await _authenticationDatasource.updateInfor(id, update);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> signup(String name, String email, String phone, String address,
      String password) {
    try {
      final result = _authenticationDatasource.signup(
          name, email, phone, address, password);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
