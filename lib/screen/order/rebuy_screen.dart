import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/cart/bloc/cart_bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_event.dart';
import 'package:customer/bloc/cart/bloc/cart_state.dart';
import 'package:customer/main.dart';
import 'package:customer/model/order_status.dart';
import 'package:customer/model/order.dart';
import 'package:customer/model/user.dart';
import 'package:customer/screen/home/homescreen.dart';
import 'package:customer/screen/order/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RebuyScreen extends StatefulWidget {
  const RebuyScreen({super.key});

  @override
  State<RebuyScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<RebuyScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Ngăn pop mặc định
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartFailure) {
            return Center(child: Text(state.error));
          }

          if (state is UpdateOrderStatusSuccess) {
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
                  // Phần nội dung cuộn
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        // 1. Thông tin đơn hàng
                        _buildOrderInfoSection(order.orderDate.toString()),
                        const SizedBox(height: 8),

                        // 2. Địa chỉ nhận hàng
                        _buildAddressSection(order.user!),
                        const SizedBox(height: 8),

                        // 3. Hình thức thanh toán
                        _buildPaymentMethodSection(),
                        const SizedBox(height: 8),

                        // 4. Thông tin kiện
                        _buildParcelInfoSection(
                            order.totalAmount ?? 0.0, OrderStatus.CANCELED),
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

                  // 6. Thanh button "Hủy đơn" cố định dưới màn hình
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

  // ------------------------------------------------------------
  // (1) Thông tin đơn hàng
  Widget _buildOrderInfoSection(String dbDateString) {
    // Nếu cần, chuyển đổi thành định dạng ISO 8601
    String isoDateString = dbDateString.replaceFirst(" ", "T");

    // Chuyển chuỗi thành DateTime và chuyển sang múi giờ local nếu cần
    DateTime orderDate = DateTime.parse(isoDateString).toLocal();

    // Định dạng ngày theo định dạng mong muốn: "dd/MM/yyyy, HH:mm"
    String formattedDate = DateFormat("dd/MM/yyyy, HH:mm").format(orderDate);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã đơn hàng + số lượng sản phẩm
            Text(
              "#25030852591 (1 sản phẩm / 1 kiện)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Ngày đặt
            Text(
              "Đặt ngày: $formattedDate",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // (2) Địa chỉ nhận hàng
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

  // ------------------------------------------------------------
  // (3) Hình thức thanh toán
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

  // ------------------------------------------------------------
  // (4) Thông tin kiện
  Widget _buildParcelInfoSection(double totalamount, OrderStatus status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề: Kiện 1/1 - Trạng thái
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

  // ------------------------------------------------------------
  // (5) Sản phẩm trong đơn
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
            // Ảnh sản phẩm (placeholder)
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

            // Thông tin sản phẩm
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
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // (6) Bottom Bar: nút "Hủy đơn"
  Widget _buildBottomBar(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            _showDeleteConfirmationDialog(context, order);
          },
          child: const Text(
            "Mua lại",
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
          title: const Text("Xác nhận mua lại"),
          content: const Text("Bạn có chắc chắn muốn mua lại đơn hàng không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(UpdateOrderStatusEvent(
                    orderId: order.id!, status: OrderStatus.PENDING));
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderDetailScreen()));
              },
              child: const Text("Đồng ý",
                  style: TextStyle(color: Color.fromARGB(255, 32, 195, 13))),
            ),
          ],
        );
      },
    );
  }
}
