import 'package:equatable/equatable.dart';
import 'package:customer/model/order_status.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddToCartEvent extends CartEvent {
  final String productId;
  final int quantity;

  const AddToCartEvent({required this.productId, required this.quantity});

  @override
  List<Object> get props => [productId, quantity];
}

class GetCartEvent extends CartEvent {
  final OrderStatus status;

  const GetCartEvent({required this.status});

  @override
  List<Object> get props => [status];
}

class UpdateQuantityEvent extends CartEvent {
  final String orderId;
  final String detailId;
  final int newQuantity;

  const UpdateQuantityEvent({
    required this.orderId,
    required this.detailId,
    required this.newQuantity,
  });

  @override
  List<Object> get props => [orderId, detailId, newQuantity];
}

class RemoveItemEvent extends CartEvent {
  final String productId;

  const RemoveItemEvent({required this.productId});

  @override
  List<Object> get props => [productId];
}

class PlaceOrderEvent extends CartEvent {}

class UpdateOrderStatusEvent extends CartEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object> get props => [orderId, status];
}

class LoadOrderByStatusEvent extends CartEvent {
  final OrderStatus status;

  const LoadOrderByStatusEvent({required this.status});

  @override
  List<Object> get props => [status];
}

class GetOrderEvent extends CartEvent {
  final String orderId;

  const GetOrderEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}
