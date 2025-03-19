import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/cart/bloc/cart_bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_event.dart';
import 'package:customer/bloc/cart/bloc/cart_state.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/screen/order/order_detail_screen_confirmed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ListOrderConfirmed extends StatefulWidget {
  const ListOrderConfirmed({super.key});

  @override
  State<ListOrderConfirmed> createState() => _ListOrderPendingState();
}

class _ListOrderPendingState extends State<ListOrderConfirmed> {
  // Formatted currency display
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // Format date string to display
  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Trong ListOrderScreen
  void _navigateToDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreenConfirmed(
          order: order,
          onClose: () {
            // Callback này sẽ được gọi từ màn hình chi tiết
            context
                .read<CartBloc>()
                .add(LoadOrderByStatusEvent(status: OrderStatus.CONFIRMED));
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context
        .read<CartBloc>()
        .add(LoadOrderByStatusEvent(status: OrderStatus.CONFIRMED));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Đơn hàng đang chờ xác nhận",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderFailure) {
            return Center(child: Text(state.error));
          }
          if (state is OrderByStatusLoaded) {
            final orders = state.orders;
            if (orders.isEmpty) {
              return Center(child: Text('Không có đơn hàng nào'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () => _navigateToDetail(orders[index]),
                    child: _buildOrderCard(orders[index]));
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final orderDetails = order.orderDetails;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Mã đơn: ${order.id.toString().substring(0, 8)}...',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    OrderStatus.CONFIRMED.description,
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Ngày đặt: ${formatDate(order.orderDate.toString())}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          const Divider(height: 1),

          // Products list
          ...orderDetails!.map((detail) {
            final product = detail.product;
            final String optimizedUrl =
                "${product?.profileImage}?w=150&h=150&c=fill";

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: product?.profileImage != null
                          ? CachedNetworkImage(
                              imageUrl: optimizedUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) =>
                                  const Icon(Icons.image,
                                      color: Colors.grey, size: 40),
                            )
                          : const Icon(Icons.image,
                              color: Colors.grey, size: 40),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.name ?? "Sản phẩm không tên",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product?.description ?? "",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              detail.total.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "x${detail.quantity}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          // Order total
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  currencyFormatter.format(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),

          // User information
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Người đặt: ${order.user?.name} (${order.user?.phone})",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Email: ${order.user?.email}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delivery address
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Địa chỉ: ${order.user?.address}",
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Handle contact action
                  },
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: const Text("Liên hệ"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _navigateToDetail(order);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(color: Colors.green.shade300),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text("Xem chi tiết"),
                    ),
                    // const SizedBox(width: 8),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Handle process order action
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.deepOrange,
                    //     foregroundColor: Colors.white,
                    //     padding: const EdgeInsets.symmetric(horizontal: 12),
                    //   ),
                    //   child: const Text("Xử lý đơn"),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
