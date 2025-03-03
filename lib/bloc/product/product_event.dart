part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class GetProductsEvent extends ProductEvent {}

class GetProductsByCategoryEvent extends ProductEvent {
  final String categoryId;
  final int page;
  final int limit;

  const GetProductsByCategoryEvent(this.categoryId, this.page, this.limit);

  @override
  // TODO: implement props
  List<Object> get props => [categoryId, page, limit];
}
