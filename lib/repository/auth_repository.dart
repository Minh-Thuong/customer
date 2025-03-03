import 'package:customer/datasource/auth_datasource.dart';
import 'package:either_dart/either.dart';

abstract class IAuthenticationRepository {
  Future<String> login(String email, String password);
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
}
