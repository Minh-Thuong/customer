import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/product/product_bloc.dart';
import 'package:customer/model/product.dart';
import 'package:customer/screen/cart/adddtocartsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetail extends StatelessWidget {
  final String productId;
  const ProductDetail({super.key, required this.productId});

  void _showAddToCartModal(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddToCartSheet(
          productId: product.id!,
          profileImage: product.profileImage!,
          price: product.price ?? 0.0,
          stock: product.stock ?? 0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<ProductBloc>().add(GetProductByIdEvent(productId));
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        context.read<ProductBloc>().add(GetProductsEvent());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Chi tiết sản phẩm"),
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProductFailure) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is ProductDetailLoaded) {
              final product = state.product;
              String optimizedUrl =
                  "${product.profileImage}?w=150&h=150&c=fill";
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: optimizedUrl,
                      height: 200.h,
                      placeholder: (context, url) => Container(
                        height: 250.h,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.error),
                      ),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40.h,
                            color: const Color.fromARGB(255, 234, 232, 227),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product.name!,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[600]),
                            ),
                          ),
                          Container(
                            child: Text(
                              "${product.price} đ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[600]),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            product.description ?? "",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
        bottomNavigationBar: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductDetailLoaded) {
              final product = state.product;
              return Container(
                color: Colors.white,
                height: 60.h,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Xử lý khi nhấn "Chat ngay"
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat,
                                color: Colors.green,
                              ),
                              Text(
                                'Chat ngay',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Xử lý khi nhấn "Thêm vào giỏ hàng"
                            _showAddToCartModal(context, product);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                              ),
                              const Text(
                                'Thêm vào Giỏ hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
