import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:customer/model/product.dart';
import 'package:customer/repository/product_repository.dart';
import 'package:equatable/equatable.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(ProductInitial()) {
    on<GetProductsEvent>(_onLoadProducts);
    on<GetProductsByCategoryEvent>(_onLoadProductsByCategory);
    on<SearchProductsEvent>(_searchProducts);
    on<GetProductByIdEvent>(_getProductDetail);
  }

  Future<void> _onLoadProducts(
      GetProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    
    try {
      final products = await _productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadProductsByCategory(
      GetProductsByCategoryEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProductsByCategory(
          event.categoryId, event.page, event.limit);
      emit(ProductByCategoryLoaded(products));
    } catch (e) {
      emit(ProductFailure(message: e.toString()));
    }
  }

  Future<void> _searchProducts(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.searchProducts(
          event.query, event.page, event.limit);
      if (products.isEmpty) {
        emit(SearchProductEmpty());
      } else {
        emit(SearchProductLoaded(products));
      }
    } catch (e) {
      emit(ProductFailure(message: e.toString()));
    }
  }

  Future<void> _getProductDetail(
      GetProductByIdEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await _productRepository.getProductById(event.id);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductFailure(message: e.toString()));
    }
  }
}
