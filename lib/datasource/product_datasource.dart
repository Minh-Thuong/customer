import 'package:customer/model/product.dart';
import 'package:dio/dio.dart';

abstract class ProductDatasource {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(String id, int page, int limit);
}

class ProductRemote implements ProductDatasource {
  final Dio _dio;

  ProductRemote(this._dio);
  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get(
        '/api/products',
      );

      if (response.statusCode == 200) {
        final List<dynamic> result = response.data['result'];

        print("$result");
        return result.map((product) => Product.fromJson(product)).toList();
      }
      throw Exception("Không thể tải sản phẩm");
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi kết nối API");
    } catch (e) {
      throw Exception("Lỗi không xác định$e");
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(
      String categoryId, int page, int limit) async {
    try {
      final response = await _dio.get(
        '/api/products/category?categoryId=$categoryId&page=$page&size=$limit',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print("Mã trạng thái: ${response.statusCode}");
      print("Dữ liệu nhận về: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['result']['content'];
        print("Results API: $results"); // Kiểm tra dữ liệu
        return results.map((product) => Product.fromJson(product)).toList();
      }

      throw Exception("Không tìm thấy sản phẩm");
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Lỗi kết nối API");
    } catch (e) {
      throw Exception("Lỗi không xác định: ${e.toString()}");
    }
  }
}
