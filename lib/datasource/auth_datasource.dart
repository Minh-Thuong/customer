import 'dart:convert';

import 'package:customer/model/user.dart';
import 'package:customer/util/token_manager.dart';
import 'package:dio/dio.dart';

abstract class IAuthenticationDatasource {
  Future<String> login(String email, String password);
  Future<User> getUser();
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

        print(result);

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

  @override
  Future<User> getUser() async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Không tìm thấy token");
    }
    try {
      final response = await _dio.get(
        '/api/users/myInfor',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

// Debug dữ liệu trả về
      print("Dữ liệu API trả về kiểu: ${response.data['result'].runtimeType}");
      print("Dữ liệu API trả về: ${jsonEncode(response.data['result'])}");

      if (response.statusCode == 200 && response.data['result'] != null) {
        final result = response.data['result'];

        print("Thông tin tài khoan: $result");
        return User.fromJson(result);
      }

      throw Exception("Không tìm thấy sản phẩm");
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi kết nối API");
    } catch (e) {
      throw Exception("Lỗi không xác định: ${e.toString()}");
    }
  }
}
