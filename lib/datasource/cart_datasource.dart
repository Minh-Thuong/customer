import 'dart:convert';

import 'package:customer/model/order.dart';
import 'package:customer/model/order_detail.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/model/product.dart';
import 'package:customer/util/token_manager.dart';
import 'package:dio/dio.dart';

abstract class IOrderDataSource {
  Future<Order> add_to_cart(String productId, int quantity);
  Future<List<Order>> get_cart(OrderStatus status);
  Future<List<Product>> getProductsByIds(List<String> productIds);
  Future<OrderDetails> update_quantity_product(String orderId, String detailId, int newQuantity);
}

class CartRemote extends IOrderDataSource {
  final Dio _dio;

  CartRemote(this._dio);
  @override
  Future<Order> add_to_cart(String productId, int quantity) async {
    final token = await TokenManager.getToken();

    // kiểm tra xem token hợp lệ hay không
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.post(
        '/api/orders/add-to-cart',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("Phản hồi từ API: ${response.data}");
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
  Future<List<Order>> get_cart(OrderStatus status) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    final statusString = status.name; // Convert OrderStatus to string
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
        print("Phản hồi từ API: ${response.data}");
        final List<dynamic> result = response.data;
        return result.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception('Failed to get cart.');
      }
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByIds(List<String> productIds) async {
    try {
      final response = await _dio.get(
        '/api/products/by-ids',
        queryParameters: {'ids': productIds},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> result = response.data;
        print("Phản hồi từ API: $result");
        return result.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get products.');
      }
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<OrderDetails> update_quantity_product(String orderId, String detailId, int newQuantity) async {
    final token = await TokenManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    try {
      final response = await _dio.put(
        '/api/orders/$orderId/details/$detailId',
        data: '{ "quantity": $newQuantity}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Phản hồi từ API: ${response.data}");
        final result = response.data;
        return  OrderDetails.fromJson(result);
      } else {
        throw Exception('Failed to update cart.');
      }
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }
}
