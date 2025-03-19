import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/cart/bloc/cart_bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_event.dart';
import 'package:customer/bloc/cart/bloc/cart_state.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/screen/order/order_confirm_screen.dart';
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
    context
        .read<CartBloc>()
        .add(const GetCartEvent(status: OrderStatus.ADDTOCART));
  }

  int? getTotalAmount() {
    final state = context.read<CartBloc>().state;
    if (state is CartLoaded) {
      return state.order.orderDetails?.fold(
        0,
        (total, detail) =>
            total! +
            ((detail.product?.price ?? 0).toInt() * (detail.quantity ?? 0)),
      );
    }
    return 0;
  }

  void _updateQuantity(BuildContext context, String detailId, int change) {
    final state = context.read<CartBloc>().state;
    if (state is CartLoaded) {
      final order = state.order;

      final detail = order.orderDetails?.firstWhere((d) => d.id == detailId);
      final newQuantity = (detail?.quantity ?? 0) + change;
      if (newQuantity > 0) {
        context.read<CartBloc>().add(
              UpdateQuantityEvent(
                orderId: order.id ?? '',
                detailId: detailId,
                newQuantity: newQuantity,
              ),
            );
      }
    }
  }

  void _removeItem(BuildContext context, String productId) {
    context.read<CartBloc>().add(RemoveItemEvent(productId: productId));
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
            print("Lỗi: ${state.error}");
            return Center(child: Text("Giỏ hàng trống"));
          }

          if (state is CartLoaded) {
            final order = state.order;
            final orderDetails = order.orderDetails ?? [];
            if (orderDetails.isEmpty) {
              return const Center(child: Text("Giỏ hàng trống"));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    cacheExtent: 3000,
                    itemCount: orderDetails.length,
                    itemBuilder: (context, index) {
                      final detail = orderDetails[index];
                      final product = detail.product;
                      final String optimizedUrl =
                          "${product?.profileImage}?w=150&h=150&c=fill";

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
                                      product?.name ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${detail.total ?? 0} đ",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove,
                                              size: 18),
                                          onPressed: () => _updateQuantity(
                                              context, detail.id!, -1),
                                        ),
                                        Text(
                                          "${detail.quantity ?? 0}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          onPressed: () => _updateQuantity(
                                              context, detail.id!, 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  if (product?.id != null) {
                                    _showDeleteConfirmationDialog(
                                        context, product!.id!);
                                  }
                                },
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
                              color: Colors.red,
                            ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OrderConfirmationScreen(),
                            ),
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

  void _showDeleteConfirmationDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text(
              "Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeItem(context, productId);
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
