import 'package:customer/model/product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String detailId; // Thêm detailId
  final double total;

  CartItem(
      {required this.product, required this.quantity, required this.detailId, required this.total});

  @override
  String toString() =>
      'CartItem(product: ${product.name}, quantity: $quantity, detailId: $detailId)';
}
