import 'package:customer/model/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String detailId; // Thêm detailId

  CartItem({required this.product, required this.quantity, required this.detailId});

  @override
  String toString() => 'CartItem(product: ${product.name}, quantity: $quantity, detailId: $detailId)';
}