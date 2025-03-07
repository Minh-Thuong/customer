import 'package:customer/datasource/cart_datasource.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/order_detail.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/model/product.dart';

abstract class ICartRepository {
  Future<Order> addToCart(String productId, int quantity);
  Future<List<Order>> getCart(OrderStatus status);
  Future<List<Product>> getProductsByIds(List<String> productIds);
  Future<OrderDetails> updateQuantityProduct(String orderId, String detailId, int newQuantity);
}

final class CartRepository extends ICartRepository {
  final IOrderDataSource _datasource;
  CartRepository(this._datasource);
  @override
  Future<Order> addToCart(String productId, int quantity) async {
    try {
      final result = await _datasource.add_to_cart(productId, quantity);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Order>> getCart(OrderStatus status) async {
    try {
      final result =await _datasource.get_cart(status);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByIds(List<String> productIds) async {
    try {
      final result =await _datasource.getProductsByIds(productIds);
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<OrderDetails> updateQuantityProduct(String orderId, String detailId, int newQuantity) async {
     try {
      final result =await _datasource.update_quantity_product( orderId, detailId, newQuantity);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
