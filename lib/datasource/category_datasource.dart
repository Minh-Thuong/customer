import 'package:customer/model/category.dart';
import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';

abstract class ICategoryDatasource {
  Future<List<Category>> getCategories();
}

class CategoryRemote extends ICategoryDatasource {
  final Dio _dio;
  CategoryRemote(this._dio);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(
        '/api/categorys',
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['result'];
        print(results);
        return results.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception("Không thể tải danh mục");
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi kết nối API");
    } catch (e) {
      throw Exception("Lỗi không xác định: ${e.toString()}");
    }
  }
}
