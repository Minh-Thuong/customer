import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/bloc/product/product_bloc.dart';
import 'package:customer/model/product.dart';
import 'package:customer/screen/cart/cart_screen.dart';
import 'package:customer/widgets/buildproductgrid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String currentQuery = "";
  int page = 0;
  int limit = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: SizedBox(
          height: 35.h,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (query) {
                    setState(() {
                      currentQuery = query;
                    });
                    context
                        .read<ProductBloc>()
                        .add(SearchProductsEvent(query, page, limit));
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.black54),
                      hintText: "Tìm tên, mã SKU, ...",
                      hintStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(0, 195, 231, 191),
                          ))),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) {
                  //     return CartScreen();
                  //   },
                  // ));
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
          if (state is SearchProductEmpty) {
            return Center(child: Text("Không tìm thấy sản phẩm"));
          }
          if (state is ProductLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(GetProductsEvent());
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildProductGrid(context, state.products),
                  ],
                ),
              ),
            );
          } else if (state is SearchProductLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(GetProductsEvent());
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
}
