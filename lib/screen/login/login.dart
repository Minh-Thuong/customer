import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/nav.dart';
import 'package:customer/screen/home/homescreen.dart';
import 'package:customer/screen/signup/signup.dart';
import 'package:customer/util/auth_action.dart';
import 'package:customer/util/token_manager.dart';
import 'package:customer/widgets/buildloginorsignup_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false; // Biến kiểm soát hiển thị mật khẩu

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Đặt true để tránh tràn khi bàn phím xuất hiện
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        // SingleChildScrollView cho phép cuộn khi bàn phím xuất hiện
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Logo
              Image.network(
                "https://res.cloudinary.com/dnwp3ccn7/image/upload/v1744094734/e7z5altam2rsmawnrubx.png",
                height: 150,
              ),
              const SizedBox(height: 16),
              // Tiêu đề
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
                "Đăng nhập tài khoản",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              // Ô nhập Email
              _buildEmailTextField(Icons.email, "Địa chỉ email"),
              const SizedBox(height: 16),
              // Ô nhập Password
              _buildPasswordTextField(Icons.lock, "Mật khẩu"),
              const SizedBox(height: 16),
              // Hoặc tiếp tục với
              const Text("Hoặc", style: TextStyle(color: Colors.black)),

              const SizedBox(height: 16),
              // Nút Google & Facebook
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      print(state);

                      if (state is AuthFailure) {
                        print(state.message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đăng nhập thất bại"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      if (state is AuthSuccess) {
                        await TokenManager.saveToken(state.token);
                        Navigator.pop(context);
                      }
                    },
                    child: _buildSocialButton("Đăng nhập với Google",
                        "https://lh3.googleusercontent.com/COxitqgJr1sJnIDe8-jiKhxDx1FrYbtRHKJ9z_hELisAlapwE9LUPh6fcXIfb5vwpbMl4xl9H9TRFPc5NOO8Sb3VSgIBrfRYvW6cUA"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Nút đăng nhập
              BlocConsumer<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }
                  return buildLoginButton(
                    text: "Đăng nhập",
                    onPressed: () {
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      // Dispatch the AuthLoginRequest event to the AuthBloc
                      context.read<AuthBloc>().add(
                          AuthLoginRequest(email: email, password: password));
                    },
                  );
                },
                listener: (context, state) async {
                  if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  if (state is AuthSuccess) {
                    await TokenManager.saveToken(state.token);
                    // Navigator.pop(context);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Nav()));
                  }
                },
              ),

              const SizedBox(height: 16),
              // Tạo tài khoản mới
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Bạn chưa có tài khoản? Đăng ký ngay",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField(IconData icon, String hintText) {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
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

  Widget _buildSocialButton(String text, String imagePath) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () {
        context.read<AuthBloc>().add(AuthGoogleRequest());
      },
      icon: Image.network(imagePath, height: 24),
      label: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}
