
class OrderDetails {
  String? id;
  String? order;
  String? product;
  int? quantity;

  OrderDetails({this.id, this.order, this.product, this.quantity});

  OrderDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order = json['orderId'];
    product = json['productId'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['orderId'] = this.order;
    data['productId'] = this.product;
    data['quantity'] = this.quantity;
    return data;
  }
}