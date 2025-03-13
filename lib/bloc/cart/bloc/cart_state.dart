import 'package:equatable/equatable.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/order_detail.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {}

final class AddToCartLoading extends CartState {}

class AddCartSuccess extends CartState {
  final Order order;

  const AddCartSuccess({required this.order});

  @override
  List<Object> get props => [order];
}

class CartFailure extends CartState {
  final String error;

  const CartFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Order order;

  const CartLoaded({required this.order});

  @override
  // TODO: implement props
  List<Object> get props => [order];
}

class UpdateOrderStatusLoading extends CartState {}

class PlaceOrderLoading extends CartState {}

class PlaceOrderSuccess extends CartState {
  final Order order;

  const PlaceOrderSuccess({required this.order});

  @override
  List<Object> get props => [order];
}

// Trong cart_state.dart
class CartTokenInvalid extends CartState {}

class UpdateOrderStatusSuccess extends CartState {
  final Order order;

  const UpdateOrderStatusSuccess({required this.order});

  @override
  List<Object> get props => [order];
}

class OrderLoading extends CartState {}

class OrderFailure extends CartState {
  final String error;

  const OrderFailure({required this.error});

  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class OrderByStatusLoaded extends CartState {
  final List<Order> orders;

  const OrderByStatusLoaded({required this.orders});

  @override
  // TODO: implement props
  List<Object> get props => [orders];
}

class OrderLoaded extends CartState {
  final Order order;

  const OrderLoaded({required this.order});

  @override
  // TODO: implement props
  List<Object> get props => [order];
}
