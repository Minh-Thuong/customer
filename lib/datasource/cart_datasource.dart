import 'dart:convert';

import 'package:customer/model/order.dart';
import 'package:customer/model/order_detail.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/util/token_manager.dart';
import 'package:dio/dio.dart';

abstract class IOrderDataSource {
  Future<Order> addToCart(String productId, int quantity);
  Future<Order> getCart(OrderStatus status);
  Future<OrderDetails> updateQuantityProduct(
      String orderId, String detailId, int newQuantity);
  Future<bool> deleteProductFromCart(String productId);
  Future<Order> placeOrder();
  Future<Order> updateStatus(String orderId, OrderStatus status);
  Future<List<Order>> getOrdersByStatus(OrderStatus status);
  Future<Order> getOrder(String orderId);
}

class CartRemote implements IOrderDataSource {
  final Dio _dio;

  CartRemote(this._dio);

  @override
  Future<Order> addToCart(String productId, int quantity) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.post(
        '/api/orders/add-to-cart',
        data: {'productId': productId, 'quantity': quantity},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Failed to add product to cart.');
      }
    } catch (e) {
      throw Exception('Failed to add product to cart: $e');
    }
  }

  @override
  Future<Order> getCart(OrderStatus status) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    final statusString = status.name;
    try {
      final response = await _dio.get(
        '/api/orders/my-orders/$statusString',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> result =
            response.data; // Ép kiểu thành List<dynamic>
        if (result.isNotEmpty) {
          return Order.fromJson(
              result.first as Map<String, dynamic>); // Lấy phần tử đầu tiên
        } else {
          throw Exception('Không có đơn hàng nào với trạng thái này.');
        }
      } else {
        throw Exception('Failed to get cart.');
      }
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  @override
  Future<OrderDetails> updateQuantityProduct(
      String orderId, String detailId, int newQuantity) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.put(
        '/api/orders/$orderId/details/$detailId',
        data: {'quantity': newQuantity},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return OrderDetails.fromJson(response.data);
      } else {
        throw Exception('Failed to update cart.');
      }
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  @override
  Future<bool> deleteProductFromCart(String productId) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.delete(
        '/api/orders/cart/remove/$productId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Xóa sản phẩm khỏi giỏ hàng thất bại.');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa sản phẩm: $e');
    }
  }

  @override
  Future<Order> placeOrder() async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.post(
        '/api/orders/create',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(response.data);

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Đặt hàng thất bại.');
      }
    } catch (e) {
      throw Exception('Đặt hàng thất bại: $e');
    }
  }

  @override
  Future<Order> updateStatus(String orderId, OrderStatus status) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.put(
        '/api/orders/$orderId/update-status',
        data: {'status': status.name},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(response.data);

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Cập nhật trang thái thất bại');
      }
    } catch (e) {
      throw Exception('Cập nhật trang thái thất bại: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final statusString = status.name;
      final response = await _dio.get(
        '/api/orders/my-orders/$statusString',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(response.data);

      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;

        return result.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception('Cập nhật trang thái thất bại');
      }
    } catch (e) {
      throw Exception('Cập nhật trang thái thất bại: $e');
    }
  }

  @override
  Future<Order> getOrder(String orderId) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.get(
        '/api/orders/$orderId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(response.data);

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Cập nhật trang thái thất bại');
      }
    } catch (e) {
      throw Exception('Cập nhật trang thái thất bại: $e');
    }
  }
}
