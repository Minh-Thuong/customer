import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/cart/bloc/cart_bloc.dart';
import 'package:customer/model/cart_item.dart';
import 'package:customer/model/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(GetCartEvent(status: OrderStatus.ADDTOCART));
  }

  int getTotalAmount() {
    final state = context.read<CartBloc>().state;
    if (state is CartLoaded) {
      return state.cartItems.fold(
          0,
          (total, item) =>
              total + (item.product.price ?? 0).toInt() * item.quantity);
    }
    return 0;
  }

  void _updateQuantity(BuildContext context, String detailId, int change) {
    final state = context.read<CartBloc>().state;
    if (state is CartLoaded) {
      final cartItem =
          state.cartItems.firstWhere((item) => item.detailId == detailId);
      final newQuantity = cartItem.quantity + change;
      if (newQuantity > 0) {
        context.read<CartBloc>().add(
              UpdateQuantityEvent(
                orderId: state.orderId,
                detailId: detailId,
                newQuantity: newQuantity,
              ),
            );
      }
    }
  }

  void removeItem(BuildContext context, int index) {
    final state = context.read<CartBloc>().state;
    if (state is CartLoaded) {
      final cartItem = state.cartItems[index];
      context.read<CartBloc>().add(
            RemoveItemEvent(
                orderId: state.orderId, detailId: cartItem.detailId),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Giỏ hàng"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartFailure) {
            return Center(child: Text("Lỗi: ${state.error}"));
          }

          if (state is CartLoaded) {
            final cartItems = state.cartItems;
            if (cartItems.isEmpty) {
              return const Center(child: Text("Giỏ hàng trống"));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product;
                      String optimizedUrl =
                          "${product.profileImage}?w=150&h=150&c=fill";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: optimizedUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${product.price ?? 0} đ",
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove,
                                              size: 18),
                                          onPressed: () => _updateQuantity(
                                              context, item.detailId, -1),
                                        ),
                                        Text(
                                          "${item.quantity}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          onPressed: () => _updateQuantity(
                                              context, item.detailId, 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => removeItem(context, index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng thanh toán",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${getTotalAmount()} đ",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Đặt hàng thành công!")),
                          );
                        },
                        child: const Text(
                          "TIẾN HÀNH ĐẶT HÀNG",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
