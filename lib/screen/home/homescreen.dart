import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/product/product_bloc.dart';
import 'package:customer/model/product.dart';
import 'package:customer/screen/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ProductBloc>().add(GetProductsEvent());
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
                        return SearchScreen();
                        // return BlocBuilder<ProductBloc, ProductState>(
                        //   builder: (context, state) {
                        //     context.read<ProductBloc>().add(GetProductsEvent());
                        //     return SearchScreen();
                        //   },
                        // );
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
                onPressed: () {},
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
                    _buildProductGrid(context, state.products),
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

  // Widget hiển thị banner
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

  // Widget hiển thị lưới sản phẩm
  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        cacheExtent: 4000,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        // itemCount: state.products.length,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          String optimizedUrl = "${product.profileImage}?w=150&h=150&c=fill";
          return InkWell(
            onTap: () {
              // Điều hướng tới màn hình chi tiết sản phẩm
              // Navigator.pushNamed(context, '/productDetail', arguments: product);
            },
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side:
                    const BorderSide(color: Color.fromARGB(255, 152, 187, 134)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CachedNetworkImage(
                        imageUrl: optimizedUrl,
                        // "https://cdn-media.sforum.vn/storage/app/media/anh-dep-110.jpg",
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
                    SizedBox(height: 8.h),
                    Text(
                      product.name ?? 'No name available',
                      // "Tên sản phẩm",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "${product.price} đ",
                      // "Giá",
                      style:
                          const TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
