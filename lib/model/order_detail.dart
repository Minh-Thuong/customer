import 'package:customer/model/product.dart';

class OrderDetails {
  String? id;
  String? orderId; // Sửa tên trường
  int? quantity;
  double? total;
  Product? product;

  OrderDetails({this.id, this.orderId, this.quantity, this.total, this.product});

  OrderDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['orderId'];
    quantity = json['quantity'];
    total = json['total']?.toDouble();
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['orderId'] = orderId;
    data['quantity'] = quantity;
    data['total'] = total;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}