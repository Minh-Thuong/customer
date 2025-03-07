import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/bloc/cart/bloc/cart_bloc.dart';
import 'package:customer/bloc/category/bloc/category_bloc.dart';
import 'package:customer/bloc/product/product_bloc.dart';
import 'package:customer/datasource/auth_datasource.dart';
import 'package:customer/datasource/cart_datasource.dart';
import 'package:customer/datasource/category_datasource.dart';
import 'package:customer/datasource/product_datasource.dart';
import 'package:customer/dio/dio_client.dart';
import 'package:customer/nav.dart';
import 'package:customer/repository/auth_repository.dart';
import 'package:customer/repository/cart_repository.dart';
import 'package:customer/repository/category_repositor.dart';
import 'package:customer/repository/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ScreenUtilInit(
      child: MultiBlocProvider(providers: [
    BlocProvider(
      create: (context) => AuthBloc(
          AuthenticationRepository(AuthenticationRemote(DioClient.instance))),
    ),
    BlocProvider(
        create: (context) =>
            ProductBloc(ProductRepository(ProductRemote(DioClient.instance)))),
    BlocProvider(
        create: (context) => CategoryBloc(
            CategoryRepository(CategoryRemote(DioClient.instance)))),
    BlocProvider(
      create: (context) =>
          CartBloc(CartRepository(CartRemote(DioClient.instance))),
    )
  ], child: const StoreApp())));
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Nav(),
      debugShowCheckedModeBanner: false,
    );
  }
}
