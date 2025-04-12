import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_event.dart';
import 'package:customer/bloc/cart/bloc/cart_state.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/screen/order/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  int selectedDeliveryOption = 1; // Lựa chọn giao hàng mặc định

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AuthBloc>().add(GetUserEvent());
    context.read<CartBloc>().add(GetCartEvent(status: OrderStatus.ADDTOCART));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CartFailure) {
          return Center(child: Text(state.error));
        }
        if (state is CartLoaded) {
          final order = state.order;
          final items = order.orderDetails;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text("Xác nhận đơn hàng"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Danh sách nội dung cuộn
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    cacheExtent: 3000,
                    children: [
                      // Địa chỉ nhận hàng
                      _buildAddressCard(),
                      const Divider(),
                      // Hình thức thanh toán
                      ListTile(
                        title: const Text("Hình thức thanh toán"),
                        trailing: _buildPaymentMethod(),
                      ),
                      const Divider(),
                      // Danh sách sản phẩm {
                      ...?items?.map((item) {
                        return _buildProductItem(
                            item.product?.profileImage ?? "",
                            item.product?.name ?? "",
                            item.product?.description ?? "",
                            item.total ?? 0,
                            item.quantity ?? 1);
                      }),

                      const SizedBox(height: 10),
                    ],
                  ),
                )),

                // Thanh tổng tiền + nút đặt hàng cố định
                _buildBottomBar(order.totalAmount ?? 0),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  // Địa chỉ nhận hàng
  Widget _buildAddressCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is GetUser) {
          final user = state.user;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin nhận hàng",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const SizedBox(height: 5),
                  Text("${user.name} - ${user.phone}",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(
                    "${user.email}",
                  ),
                  Text(
                    "${user.address}",
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  // Hình thức thanh toán
  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text("Thanh toán khi nhận hàng (COD)",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    );
  }

  // Lựa chọn giao hàng
  Widget _buildDeliveryOptions() {
    return Card(
      child: Column(
        children: [
          RadioListTile<int>(
            title: const Text("Thứ 7. Trước 13h, 08/03"),
            subtitle: const Text("NowFree Giao Nhanh 2H (Trễ tặng 100k)",
                style: TextStyle(color: Colors.orange)),
            value: 1,
            groupValue: selectedDeliveryOption,
            onChanged: (value) =>
                setState(() => selectedDeliveryOption = value!),
          ),
          RadioListTile<int>(
            title: const Text("Thứ 2. 10/03"),
            subtitle: const Text("Giao trong 48 giờ"),
            value: 2,
            groupValue: selectedDeliveryOption,
            onChanged: (value) =>
                setState(() => selectedDeliveryOption = value!),
          ),
        ],
      ),
    );
  }

  // Widget sản phẩm
  Widget _buildProductItem(
      String image, String title, String subtitle, double price, int quantity) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text("$price đ",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thanh tổng tiền + nút đặt hàng cố định
  Widget _buildBottomBar(double totalPrice) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tổng tiền
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tổng thanh toán (Đã VAT)",
                  style: TextStyle(fontSize: 14)),
              Text("$totalPrice đ",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
            ],
          ),
          // Nút đặt hàng
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () {
              context.read<CartBloc>().add(PlaceOrderEvent());
              Future.delayed(Duration(milliseconds: 300), () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const OrderDetailScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đặt hàng thành công!")),
                );
              });
            },
            child: const Text("Đặt hàng",
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
