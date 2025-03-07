import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:customer/model/cart_item.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/order_detail.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/repository/cart_repository.dart';
import 'package:equatable/equatable.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  CartBloc(this._cartRepository) : super(CartInitial()) {
    on<AddToCartEvent>(_onAddToCartEvent);
    on<GetCartEvent>(_onGetCartEvent);
    on<UpdateQuantityEvent>(_updateQuantityProductEvent);
  }
Future<void> _updateQuantityProductEvent(UpdateQuantityEvent event, Emitter<CartState> emit) async {
    try {
      final state = this.state;
      if (state is CartLoaded) {
        // Gọi API để cập nhật số lượng
        final updatedOrderDetail = await _cartRepository.updateQuantityProduct(
          event.orderId,
          event.detailId,
          event.newQuantity,
        );

        // Cập nhật danh sách CartItem
        final updatedCartItems = state.cartItems.map((item) {
          if (item.detailId == event.detailId) {
            return CartItem(
              product: item.product,
              quantity: updatedOrderDetail.quantity!,
              detailId: item.detailId,
            );
          }
          return item;
        }).toList();

        // Phát trạng thái CartLoaded mới
        emit(CartLoaded(cartItems: updatedCartItems, orderId: state.orderId));
      }
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }
  Future<void> _onAddToCartEvent(
      AddToCartEvent event, Emitter<CartState> emit) async {
    emit(AddToCartLoading());
    try {
      final result =
          await _cartRepository.addToCart(event.productId, event.quantity);
      print(
          "AddCartSuccess emitted"); // Kiểm tra xem trạng thái này có được phát không
      emit(AddCartSuccess(order: result));
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }

  Future<void> _onGetCartEvent(
      GetCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final orders = await _cartRepository.getCart(event.status);
      if (orders.isNotEmpty) {
        final order =
            orders.first; // Giả định chỉ có một order với trạng thái ADDTOCART
        final productIds =
            order.orderDetails!.map((detail) => detail.product!).toList();
        print("ProductIds: $productIds");
        final products = await _cartRepository.getProductsByIds(productIds);
        final cartItems = order.orderDetails!.map((detail) {
          final product = products.firstWhere((p) => p.id == detail.product);
          return CartItem(
            detailId: detail.id!, // Thêm detailId
            product: product,
            quantity: detail.quantity!,
          );
        }).toList();
        emit(CartLoaded(cartItems: cartItems, orderId: order.id!));
      } else {
        emit(CartLoaded(cartItems: [], orderId: ''));
      }
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }
}
