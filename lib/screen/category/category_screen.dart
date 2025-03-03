import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/category/bloc/category_bloc.dart';
import 'package:customer/model/category.dart';
import 'package:customer/screen/category/product_by_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CategoryBloc>().add(GetCategories());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Center(child: const Text("Danh mục sản phẩm")),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }

          if (state is CategoryLoaded) {
            final categories = state.categories;
            return RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProductGrid(context, categories),
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
  Widget _buildProductGrid(BuildContext context, List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GridView.builder(
        cacheExtent: 3000,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 0.7,
        ),
        // itemCount: state.products.length,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          String optimizedUrl = "${category.profileImage}?w=150&h=150&c=fill";
          return InkWell(
            onTap: () {
              // Điều hướng tới màn hình chi tiết sản phẩm
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return ProductByCategoryScreen(categoryID: category.id);
                },
              ));
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
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
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
