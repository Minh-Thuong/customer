import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://172.16.108.195:8080',
  ));
  static Dio get instance => _dio;
}
