part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}


// Sự kiện thêm sản phẩm vào giỏ hàng
class AddToCartEvent extends CartEvent {
  final String productId;
  final int quantity;

  AddToCartEvent({required this.productId, required this.quantity});

  @override
  List<Object> get props => [ productId, quantity];
}

class GetCartEvent extends CartEvent {
  final OrderStatus status;
  GetCartEvent({required this.status});

  @override
  // TODO: implement props
  List<Object> get props => [status];
}
class UpdateQuantityEvent extends CartEvent {
  final String orderId;
  final String detailId;
  final int newQuantity;

  UpdateQuantityEvent({
    required this.orderId,
    required this.detailId,
    required this.newQuantity,
  });
}

class RemoveItemEvent extends CartEvent {
  final String orderId;
  final String detailId;

  RemoveItemEvent({required this.orderId, required this.detailId});

  @override
  List<Object> get props => [orderId, detailId];
}