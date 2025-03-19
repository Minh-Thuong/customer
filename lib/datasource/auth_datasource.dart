import 'dart:convert';

import 'package:customer/model/update_infor_user.dart';
import 'package:customer/model/user.dart';
import 'package:customer/util/token_manager.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class IAuthenticationDatasource {
  Future<String> login(String email, String password);
  Future<User> getUser();
  Future<void> logout(String token);
  Future<String> loginbygoogle(String email, String name, String imageUrl);
  Future<User> updateInfor(String id, UserUpdate update);
  Future<User> signup(
      String name, String email, String phone, String address, String password);
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

  @override
  Future<void> logout(String token) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Không tìm thấy token");
    }
    final response = await _dio.post(
      '/api/users/auth/logout',
      data: {'token': token},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      print("đã đăng xuất thành công");

      return;
    }
  }

  @override
  Future<String> loginbygoogle(
      String email, String name, String imageUrl) async {
    final response = await _dio.post(
      "/register/google-login",
      data: {"email": email, "name": name, "profileImage": imageUrl},
    );

    print("name: $name email: $email image: $imageUrl");
    if (response.statusCode == 200) {
      final result = response.data["token"];
      print("JWT: $result");
      return result;
    } else {
      throw Exception(
          'Failed to authenticate with Google: ${response.statusCode}');
    }
  }

  @override
  Future<User> updateInfor(String id, UserUpdate update) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Không tìm thấy token");
    }
    try {
      final response = await _dio.put(
        '/api/users/$id',
        data: update.toJson(),
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

  @override
  Future<User> signup(String name, String email, String phone, String address,
      String password) async {
    try {
      final response = await _dio.post('/api/users', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'password': password
      });
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final result = response.data['result'];

        print(result);
        return User.fromJson(result);
      } else {
        throw Exception("API trả về dữ liệu không đúng định dạng");
      }
    } on DioException catch (e) {
      throw Exception("API trả về lỗi: ${e.message}");
    }
  }
}
