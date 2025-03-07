import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.2.1.239:8080',
  ));
  static Dio get instance => _dio;
}
