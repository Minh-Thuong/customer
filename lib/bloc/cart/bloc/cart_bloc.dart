import 'package:bloc/bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_event.dart';
import 'package:customer/bloc/cart/bloc/cart_state.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/order_detail.dart';
import 'package:customer/repository/cart_repository.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc(this._cartRepository) : super(CartInitial()) {
    on<AddToCartEvent>(_onAddToCartEvent);
    on<GetCartEvent>(_onGetCartEvent);
    on<UpdateQuantityEvent>(_onUpdateQuantityEvent);
    on<RemoveItemEvent>(_onRemoveItemEvent);
    on<PlaceOrderEvent>(_onPlaceOrderEvent);
    on<UpdateOrderStatusEvent>(_onUpdateStatusOrder);
    on<LoadOrderByStatusEvent>(_onGetOrderByStatus);
    on<GetOrderEvent>(_onGetOrder);
  }

  Future<void> _onGetOrder(GetOrderEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final order = await _cartRepository.getOrder(event.orderId);
      emit(OrderLoaded(order: order));
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }

  Future<void> _onAddToCartEvent(
      AddToCartEvent event, Emitter<CartState> emit) async {
    emit(AddToCartLoading());
    try {
      final order =
          await _cartRepository.addToCart(event.productId, event.quantity);
      emit(AddCartSuccess(order: order));
    } catch (e) {
      if (e.toString().contains("Token không hợp lệ")) {
        emit(CartTokenInvalid());
      } else {
        emit(CartFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onGetCartEvent(
      GetCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final orders = await _cartRepository.getCart(event.status);

      emit(CartLoaded(order: orders));
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateQuantityEvent(
      UpdateQuantityEvent event, Emitter<CartState> emit) async {
    try {
      final state = this.state;
      if (state is CartLoaded) {
        final order = state.order;
        final updatedDetail = await _cartRepository.updateQuantityProduct(
          event.orderId,
          event.detailId,
          event.newQuantity,
        );

        final updatedOrderDetails = order.orderDetails?.map((detail) {
          if (detail.id == event.detailId) {
            // Giữ lại thông tin product từ detail cũ, chỉ cập nhật quantity và total
            return OrderDetails(
              id: detail.id,
              orderId: detail.orderId,
              product: detail.product,
              quantity: updatedDetail.quantity,
              total: updatedDetail.total,
            );
          }
          return detail;
        }).toList();

        // Tạo Order mới với orderDetails đã cập nhật
        final updatedOrder = Order(
          id: order.id,
          totalAmount: order.totalAmount, // Có thể cần tính lại totalAmount
          orderDate: order.orderDate,
          deliveryDate: order.deliveryDate,
          customerId: order.customerId,
          createdById: order.createdById,
          status: order.status,
          orderDetails: updatedOrderDetails,
        );

        emit(CartLoaded(order: updatedOrder));
      }
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }

  Future<void> _onRemoveItemEvent(
      RemoveItemEvent event, Emitter<CartState> emit) async {
    try {
      final state = this.state;
      if (state is CartLoaded) {
        final order = state.order;
        final success =
            await _cartRepository.deleteProductFromCart(event.productId);
        if (success) {
          final updatedOrderDetails = order.orderDetails
              ?.where((detail) => detail.product?.id != event.productId)
              .toList();

          // Tạo Order mới với orderDetails đã cập nhật
          final updatedOrder = Order(
            id: order.id,
            totalAmount: order.totalAmount, // Có thể cần tính lại totalAmount
            orderDate: order.orderDate,
            deliveryDate: order.deliveryDate,
            customerId: order.customerId,
            createdById: order.createdById,
            status: order.status,
            orderDetails: updatedOrderDetails,
          );
          emit(CartLoaded(order: updatedOrder));
        } else {
          emit(CartFailure(error: 'Xóa sản phẩm thất bại.'));
        }
      }
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }

  Future<void> _onPlaceOrderEvent(
      PlaceOrderEvent event, Emitter<CartState> emit) async {
    emit(PlaceOrderLoading());
    try {
      final order = await _cartRepository.placeOrder();
      emit(PlaceOrderSuccess(order: order));
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateStatusOrder(
      UpdateOrderStatusEvent event, Emitter<CartState> emit) async {
    emit(UpdateOrderStatusLoading());

    try {
      final order =
          await _cartRepository.updateStatus(event.orderId, event.status);
      emit(UpdateOrderStatusSuccess(order: order));
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }

  Future<void> _onGetOrderByStatus(
      LoadOrderByStatusEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final orders = await _cartRepository.getOrdersByStatus(event.status);
      emit(OrderByStatusLoaded(orders: orders));
    } catch (e) {
      emit(CartFailure(error: e.toString()));
    }
  }
}
