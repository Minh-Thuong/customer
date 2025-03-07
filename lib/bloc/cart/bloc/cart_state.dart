part of 'cart_bloc.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {}

final class AddToCartLoading extends CartState {}

// Trạng thái thành công khi thêm sản phẩm vào giỏ hàng
class AddCartSuccess extends CartState {
  final Order order;

  const AddCartSuccess({required this.order});

  @override
  List<Object> get props => [order];
}

// Trạng thái thất bại khi thêm vào giỏ hàng
class CartFailure extends CartState {
  final String error;

  const CartFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class CartLoading extends CartState {}

final class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  final String orderId; // Thêm orderId

  const CartLoaded({required this.cartItems, required this.orderId});

  @override
  List<Object> get props => [cartItems, orderId];
}

final class UpdateQuantityProductSuccess extends CartState {
  final OrderDetails cartItems;

  const UpdateQuantityProductSuccess({required this.cartItems});

  @override
  List<Object> get props => [cartItems];
}
