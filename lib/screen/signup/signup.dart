import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/screen/login/login.dart';
import 'package:customer/util/auth_action.dart';
import 'package:customer/widgets/buildloginorsignup_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false; // biến kiểm soát hiển thị mật khẩu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Đặt true để tránh tràn khi bàn phím xuất hiện
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        // SingleChildScrollView cho phép cuộn khi bàn ph임 xuất hiện
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.network(
                "https://res.cloudinary.com/dnwp3ccn7/image/upload/v1744094734/e7z5altam2rsmawnrubx.png",
                height: 150,
              ),
              const SizedBox(height: 16),
              // const Text(
              //   "Women's Secret Beauty",
              //   style: TextStyle(
              //     fontSize: 28,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.green,
              //   ),
              // ),
              const SizedBox(height: 8),
              const Text(
                "Đăng ký tài khoản",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  icon: Icons.person,
                  hintText: "Họ và tên",
                  controller: _nameController,
                  keyboardType: TextInputType.name),
              const SizedBox(height: 16),
              _buildTextField(
                  icon: Icons.email,
                  hintText: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(
                  icon: Icons.phone,
                  hintText: "Số điện thoại",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(
                  icon: Icons.location_on,
                  hintText: "Địa chỉ",
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress),
              const SizedBox(height: 16),
              _buildPasswordTextField(Icons.lock, "Mật khẩu"),
              const SizedBox(height: 16),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  // if (state is AuthSuccess) {
                  //   Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(
                  //       builder: (context) => const LoginScreen(),
                  //     ),
                  //   );
                  // }
                  if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đăng ký thất bại"),
                      ),
                    );
                  }
                  if (state is AuthSignUp) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Đăng ký thành công"),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                builder: (context, state) {
                  return buildLoginButton(text: "Đăng ký", onPressed: _signup);
                },
              ),

              const SizedBox(height: 16),
              //đã có tài khoản
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }));
                },
                child: const Text(
                  "Bạn đã có tài khoản? Đăng nhập ngay",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required IconData icon,
      required String hintText,
      required TextEditingController controller,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: const Color.fromARGB(255, 17, 196, 23), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(IconData icon, String hintText) {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: const Color.fromARGB(255, 17, 196, 23), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _signup() {
    final name = _nameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final address = _addressController.text;
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showError("Vui lòng nhập họ và tên");
      return;
    }

    if (email.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email)) {
      _showError("Vui lòng nhập email hợp lệ");
      return;
    }

    if (phone.isEmpty || !RegExp(r"^\d{10}$").hasMatch(phone)) {
      _showError("Vui lòng nhập số điện thoại hợp lệ");
      return;
    }

    if (address.isEmpty) {
      _showError("Vui lòng nhập địa chỉ");
      return;
    }
    if (password.isEmpty || password.length < 8) {
      _showError("Mật khẩu phải có ít nhất 8 ký tự");
      return;
    }

    AuthAction(
        context,
        {
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'password': password
        },
        false);
  }
}
