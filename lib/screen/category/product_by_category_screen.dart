import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/product/product_bloc.dart';
import 'package:customer/model/product.dart';
import 'package:customer/screen/search/search_screen.dart';
import 'package:customer/widgets/buildproductgrid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductByCategoryScreen extends StatelessWidget {
  final String categoryID;
  const ProductByCategoryScreen({super.key, required this.categoryID});

  @override
  Widget build(BuildContext context) {
    context
        .read<ProductBloc>()
        .add(GetProductsByCategoryEvent(categoryID, 0, 10));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text("Danh mục sản phẩm"),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductFailure) {
            return Center(child: Text(state.message));
          }

          if (state is ProductByCategoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<ProductBloc>()
                    .add(GetProductsByCategoryEvent(categoryID, 0, 10));
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildProductGrid(context, state.products),
                  ],
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  // Widget hiển thị lưới sản phẩm
  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return GridView.builder(
      cacheExtent: 3000,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
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
              side: const BorderSide(color: Color.fromARGB(255, 152, 187, 134)),
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
                    product.name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${product.price} đ",
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
