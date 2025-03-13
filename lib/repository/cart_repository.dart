import 'package:customer/datasource/cart_datasource.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/order_detail.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/model/product.dart';

abstract class ICartRepository {
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

final class CartRepository extends ICartRepository {
  final IOrderDataSource _datasource;
  CartRepository(this._datasource);
  @override
  Future<Order> addToCart(String productId, int quantity) async {
    try {
      final result = await _datasource.addToCart(productId, quantity);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order> getCart(OrderStatus status) async {
    try {
      final result = await _datasource.getCart(status);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderDetails> updateQuantityProduct(
      String orderId, String detailId, int newQuantity) async {
    try {
      final result = await _datasource.updateQuantityProduct(
          orderId, detailId, newQuantity);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order> placeOrder() async {
    try {
      return await _datasource.placeOrder();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteProductFromCart(String productId) async {
    try {
      final result = await _datasource.deleteProductFromCart(productId);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order> updateStatus(String orderId, OrderStatus status) async {
     try {
      final result = await _datasource.updateStatus(orderId, status);
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
     try {
      final result = await _datasource.getOrdersByStatus(status);
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<Order> getOrder(String orderId) async {
   try {
      final result = await _datasource.getOrder(orderId);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
