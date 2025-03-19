import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/screen/cart/cart_screen.dart';
import 'package:customer/screen/login/login.dart';
import 'package:customer/screen/order/list_order_cancel.dart';
import 'package:customer/screen/order/list_order_confirmed.dart';
import 'package:customer/screen/order/list_order_delivered.dart';
import 'package:customer/screen/order/list_order_pending.dart';
import 'package:customer/screen/profile/infor_person_screen.dart';
import 'package:customer/screen/search/search_screen.dart';
import 'package:customer/util/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    context.read<AuthBloc>().add(CheckLoginEvent());
    // context.read<AuthBloc>().add(GetUserEvent());
  }

  @override
  void didPopNext() {
    super.didPopNext();
    print('didPopNext được gọi từ ProfileScreen');
    context.read<AuthBloc>().add(CheckLoginEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: SizedBox(
          height: 40.h,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const SearchScreen();
                      },
                    ));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 8),
                      Icon(Icons.search, color: Colors.black54, size: 25),
                      SizedBox(width: 8),
                      Text(
                        "Tìm tên, mã SKU, ...",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
               onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return CartScreen();
                    },
                  ));
                },
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        builder: (context, state) {
          return ListView(
            children: [
              // _buildProfileInfo(context),
              _buildListInfor(
                  context, "Thông tin cá nhân", InforPersonScreen()),
              _buildListInfor(
                  context, "Đơn hàng chờ xử lý", ListOrderPending()),
              _buildListInfor(
                  context, "Đơn hàng đã được xác nhận", ListOrderConfirmed()),
              _buildListInfor(
                  context, "Lịch sử mua hàng", ListOrderDelivered()),
              _buildListInfor(context, "Đơn hàng đã hủy", ListOrderCancel()),
              if (state is AuthAuthenticated)
                _buildListInfor(
                  context,
                  "Đăng xuất",
                  LoginScreen(),
                  onTap: () => _logout(context),
                )
              else if (state is AuthUnauthenticated)
                _buildListInfor(context, "Đăng nhập", LoginScreen())
              else
                const SizedBox
                    .shrink(), // Không hiển thị nút nếu đang loading hoặc trạng thái khác
            ],
          );
        },
        listener: (BuildContext context, AuthState state) {
          if (state is AuthUnauthenticated &&
              state.message == 'Đăng xuất thành công') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng xuất thành công')),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đăng xuất thất bại: ${state.message}')),
            );
          }
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      debugPrint("Bắt đầu đăng xuất...");
      final token = await TokenManager.getToken();
      if (token != null) {
        context.read<AuthBloc>().add(LogoutEvent(token: token));
        debugPrint("Đã gửi LogoutEvent");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Thông báo"),
              content: Text("Đăng xuất thành công"),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog khi nhấn OK
                  },
                ),
              ],
            );
          },
        );
      } else {
        debugPrint("Token rỗng, không cần đăng xuất");
      }
    } catch (e) {
      debugPrint("Lỗi khi đăng xuất: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng xuất thất bại: $e')),
      );
    }
  }

  // Widget hiển thị thông tin hồ sơ cá nhân
  Widget _buildProfileInfo(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is GetUser) {
          final user = state.user;
          String avatarUrl = '${user.profileImage}?w=150&h=150&c=fill';
          return Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side:
                    const BorderSide(color: Color.fromARGB(255, 152, 187, 134)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Avatar image
                    CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      width: 60.w,
                      height: 60.h,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 60, color: Colors.red),
                    ),
                    SizedBox(width: 16.w),
                    // User info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.name}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${user.email}",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color.fromARGB(255, 152, 187, 134)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Avatar image
                  CachedNetworkImage(
                    imageUrl:
                        "https://cdn-media.sforum.vn/storage/app/media/anh-dep-110.jpg",
                    fit: BoxFit.cover,
                    width: 60.w,
                    height: 60.h,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                  SizedBox(width: 16.w),
                  // User info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Tên người dùng",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "email@example.com",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị các thông tin khác trong hồ sơ
  Widget _buildListInfor(BuildContext context, String title, Widget page,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0, left: 18.0, top: 8.0),
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return page;
                },
              ));
            },
        child: ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color.fromARGB(255, 152, 187, 134)),
          ),
        ),
      ),
    );
  }
}
