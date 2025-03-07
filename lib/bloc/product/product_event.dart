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

class SearchProductsEvent extends ProductEvent {
  final String query;
  final int page;
  final int limit;

  const SearchProductsEvent(this.query, this.page, this.limit);

  @override
  // TODO: implement props
  List<Object> get props => [query, page, limit];
}


final class GetProductByIdEvent extends ProductEvent {
  final String id;
  const GetProductByIdEvent(this.id);

  @override
  // TODO: implement props
  List<Object> get props => [id];
}