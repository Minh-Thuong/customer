import 'package:dio/dio.dart';

abstract class IAuthenticationDatasource {
  Future<String> login(String email, String password);
}

class AuthenticationRemote extends IAuthenticationDatasource {
  final Dio _dio;

  AuthenticationRemote(this._dio);
  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/users/auth/login',
          data: {'email': email, 'password': password});
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final result = response.data['result'];

        if (result != null && result is Map<String, dynamic>) {
          if (result.containsKey('token') && result['token'] is String) {
            return result['token'];
          } else {
            throw Exception("API không trả về token hợp lệ");
          }
        } else {
          throw Exception("API trả về dữ liệu không đúng định dạng");
        }
      } else {
        throw Exception("API trả về lỗi: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("API trả về lỗi: ${e.message}");
    }
  }
}
