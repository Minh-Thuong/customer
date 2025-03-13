import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/cart/bloc/cart_bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_event.dart';
import 'package:customer/bloc/cart/bloc/cart_state.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/user.dart';
import 'package:customer/screen/order/rebuy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen2 extends StatefulWidget {
  final Order order;
  final VoidCallback onClose;
  const OrderDetailScreen2(
      {super.key, required this.order, required this.onClose});

  @override
  State<OrderDetailScreen2> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen2> {
  @override
  void initState() {
    super.initState();
    context
        .read<CartBloc>()
        .add(GetOrderEvent(orderId: widget.order.id!)); // Load order details
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Cho phép pop màn hình
      onPopInvoked: (didPop) {
        if (didPop) {
          widget.onClose(); // Gọi callback khi màn hình bị pop
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading indicator
          }

          if (state is CartFailure) {
            return Center(child: Text(state.error));
          }

          if (state is OrderLoaded) {
            final order = state.order;
            final products = order.orderDetails;

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text("Chi tiết đơn hàng"),
                backgroundColor: Colors.green,
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        _buildOrderInfoSection(order.orderDate.toString()),
                        const SizedBox(height: 8),
                        _buildAddressSection(order.user!),
                        const SizedBox(height: 8),
                        _buildPaymentMethodSection(),
                        const SizedBox(height: 8),
                        _buildParcelInfoSection(
                            order.totalAmount ?? 0.0, OrderStatus.PENDING),
                        const SizedBox(height: 8),
                        ...products!.map(
                          (e) {
                            return _buildProductItem(
                              title: e.product!.name ?? 'Unknown Product',
                              subtitle: e.product!.description ??
                                  'Unknown Description',
                              price: e.product!.price ?? 0.0,
                              quantity: e.quantity ?? 0,
                              image: e.product!.profileImage ?? '',
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  _buildBottomBar(order),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderInfoSection(String dbDateString) {
    String isoDateString = dbDateString.replaceFirst(" ", "T");
    DateTime orderDate = DateTime.parse(isoDateString).toLocal();
    String formattedDate = DateFormat("dd/MM/yyyy, HH:mm").format(orderDate);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "#25030852591 (1 sản phẩm / 1 kiện)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Đặt ngày: $formattedDate",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(User user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Địa chỉ nhận hàng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${user.name} - ${user.phone}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${user.email}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "${user.address}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: const Text(
          "Hình thức thanh toán",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            "Thanh toán khi nhận hàng (COD)",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildParcelInfoSection(double totalamount, OrderStatus status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Kiện hàng",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    OrderStatus.PENDING.description.toString(),
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng tiền",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("$totalamount đ",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem({
    required String title,
    required String subtitle,
    required double price,
    required String image,
    required int quantity,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Số luong: $quantity",
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  Text(
                    "$price đ",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            _showDeleteConfirmationDialog(context, order);
          },
          child: const Text(
            "Hủy đơn",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận hủy"),
          content: const Text("Bạn có chắc chắn muốn hủy đơn hàng không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(UpdateOrderStatusEvent(
                    orderId: order.id!, status: OrderStatus.CANCELED));
                Navigator.pop(context);
                // Hiển thị thông báo SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Đơn hàng đã được hủy thành công",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                Future.delayed(
                  Duration(microseconds: 2),
                  () {
                    Navigator.pop(context);
                  },
                );
            
              },
              child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
