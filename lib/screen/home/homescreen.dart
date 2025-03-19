import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/auth/auth_bloc.dart';
import 'package:customer/bloc/product/product_bloc.dart';
import 'package:customer/screen/cart/cart_screen.dart';
import 'package:customer/screen/search/search_screen.dart';
import 'package:customer/widgets/buildproductgrid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    super.initState();
    // Gọi sự kiện trong initState thay vì trong build
    context.read<ProductBloc>().add(GetProductsEvent());
    // Kiểm tra trạng thái đăng nhập khi mở Homescreen
    context.read<AuthBloc>().add(AppStarted());
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(),
                      ),
                    ).then((_) {
                      context.read<ProductBloc>().add(GetProductsEvent());
                    });
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
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductFailure) {
            return Center(child: Text(state.message));
          }

          if (state is ProductLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(GetProductsEvent());
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBanner(),
                    buildProductGrid(context, state.products, () {
                      context.read<ProductBloc>().add(GetProductsEvent());
                    }),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 150.h,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl:
              "https://cdn-media.sforum.vn/storage/app/media/anh-dep-110.jpg",
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
