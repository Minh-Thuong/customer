import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/screen/login/login.dart';
import 'package:customer/screen/profile/update_infor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InforPersonScreen extends StatelessWidget {
  const InforPersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(GetUserEvent());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AuthError) {
          print(state.message);
          return Scaffold(
              appBar: AppBar(title: const Text('Thông tin tài khoản')),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text('Vui lòng đăng nhập')),
                  SizedBox(height: 20),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ));
                      },
                      child: const Text('Đăng nhập',
                          style: TextStyle(color: Colors.white))),
                ],
              ));
        }

        if (state is GetUser || state is UpdateUserSuccess) {
          final user =
              state is GetUser ? state.user : (state as UpdateUserSuccess).user;
          String optimizedUrl = "${user.profileImage}?w=150&h=150&c=fill";
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              elevation: 0,
              title: const Text('Thông tin tài khoản'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hình đại diện
                  CircleAvatar(
                    radius: 50,
                    child: CachedNetworkImage(
                      imageUrl: optimizedUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Image.asset(
                        'assets/placeholder.jpg',
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        size: 70,
                        color: Color.fromARGB(255, 207, 204, 204),
                      ),
                      fadeInDuration: const Duration(milliseconds: 200),
                      fadeOutDuration: const Duration(milliseconds: 200),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tên và SĐT
                  Text(
                    user.name ?? "Trống",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    title: Text("Số điện thoại:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.phone ?? "Trống",
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                  ListTile(
                    title: Text(user.email ?? "Trống",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${user.email}",
                        style: TextStyle(color: Colors.grey[600])),
                  ),
                  ListTile(
                    title: Text("Địa chỉ:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.address ?? "Trống",
                        maxLines: 3, style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(height: 20),

                  // Nút Cập nhật và Xóa tài khoản
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 80.0, right: 80.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateInforScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text("CẬP NHẬT",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(top: 10, left: 80.0, right: 80.0),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     child: ElevatedButton(
                  //       onPressed: () {},
                  //       style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.red),
                  //       child: const Text("XÓA TÀI KHOẢN",
                  //           style: TextStyle(color: Colors.white)),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
