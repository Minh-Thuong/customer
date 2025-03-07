part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

final class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

final class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded(this.products);

  @override
  // TODO: implement props
  List<Object> get props => [products];
}

final class ProductFailure extends ProductState {
  final String message;
  const ProductFailure({required this.message});
}

final class ProductByCategoryLoaded extends ProductState {
  final List<Product> products;
  const ProductByCategoryLoaded(this.products);

  @override
  // TODO: implement props
  List<Object> get props => [products];
}

final class SearchProductLoaded extends ProductState {
  final List<Product> products;
  const SearchProductLoaded(this.products);

  @override
  // TODO: implement props
  List<Object> get props => [products];
}

final class SearchProductEmpty extends ProductState {}

final class ProductDetailLoaded extends ProductState {
  final Product product;
  const ProductDetailLoaded(this.product);

  @override
  // TODO: implement props
  List<Object> get props => [product];
}
