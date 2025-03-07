import 'package:customer/model/order_detail.dart';

class Order {
  String? id;
  double? totalAmount;
  String? orderDate;
  Null deliveryDate;
  String? customer;
  Null createdBy;
  String? status;
  List<OrderDetails>? orderDetails;

  Order(
      {this.id,
      this.totalAmount,
      this.orderDate,
      this.deliveryDate,
      this.customer,
      this.createdBy,
      this.status,
      this.orderDetails});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalAmount = json['totalAmount'];
    orderDate = json['orderDate'];
    deliveryDate = json['deliveryDate'];
    customer = json['customerId'];
    createdBy = json['createdById'];
    status = json['status'];
    if (json['orderDetails'] != null) {
      orderDetails = <OrderDetails>[];
      json['orderDetails'].forEach((v) {
        orderDetails!.add(OrderDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['totalAmount'] = totalAmount;
    data['orderDate'] = orderDate;
    data['deliveryDate'] = deliveryDate;
    data['customerId'] = customer;
    data['createdById'] = createdBy;
    data['status'] = status;
    if (orderDetails != null) {
      data['orderDetails'] = orderDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
