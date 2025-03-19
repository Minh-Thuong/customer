import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/model/update_infor_user.dart';
import 'package:customer/screen/login/login.dart';
import 'package:customer/screen/profile/infor_person_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateInforScreen extends StatefulWidget {
  const UpdateInforScreen({super.key});

  @override
  State<UpdateInforScreen> createState() => _UpdateInforScreenState();
}

class _UpdateInforScreenState extends State<UpdateInforScreen> {
  // Các controller để quản lý dữ liệu nhập
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  String? userId;
  final _formKey = GlobalKey<FormState>(); // Key để validate form

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu ban đầu
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    context.read<AuthBloc>().add(GetUserEvent());
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AuthError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Thông tin tài khoản')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: Text('Vui lòng đăng nhập')),
                const SizedBox(height: 20),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Đăng nhập',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state is GetUser) {
          final user = state.user;
          userId = user.id;
          String optimizedUrl = "${user.profileImage}?w=150&h=150&c=fill";

          // Gán giá trị từ user vào các controller
          _nameController.text = user.name!;
          _phoneController.text = user.phone ?? '';
          _emailController.text = user.email!;
          _addressController.text = user.address ?? '';

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              elevation: 0,
              title: const Text('Cập nhật thông tin'),
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back),
              //   onPressed: () => Navigator.pop(context),
              // ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Gán key cho form
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      print("Lỗi chỉnh sửa thông tin: ${state.message}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Vui lòng kiểm tra lại thông tin"),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    if (state is UpdateUserSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cập nhật thông tin thành công'),
                          backgroundColor: Colors.green,
                          // duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                      context.read<AuthBloc>().add(GetUserEvent());
                    }
                  },
                  child: SingleChildScrollView(
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

                        // Các trường chỉnh sửa
                        _buildEditableField("Tên", _nameController),
                        SizedBox(height: 10),
                        _buildEditableField("Số điện thoại", _phoneController),
                        SizedBox(height: 10),
                        _buildEditableField("Email", _emailController),
                        SizedBox(height: 10),
                        _buildEditableField("Địa chỉ", _addressController,
                            maxline: 3),
                        const SizedBox(height: 20),

                        // Nút Lưu và Xóa tài khoản
                        _buildActionButton("Lưu", Colors.green, () {
                          if (_formKey.currentState!.validate() &&
                              userId != null) {
                            final update = UserUpdate(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              email: _emailController.text,
                              address: _addressController.text,
                            );
                            context.read<AuthBloc>().add(UpdateUserEvent(
                                  id: userId!,
                                  userUpdate: update,
                                ));
                          }
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Widget hiển thị ô nhập liệu có thể chỉnh sửa
  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxline = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxline,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label không được để trống';
          }
          return null;
        },
      ),
    );
  }

  // Widget tạo nút hành động
  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 80.0, right: 80.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: color),
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
