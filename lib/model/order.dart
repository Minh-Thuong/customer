import 'package:customer/model/order_detail.dart';
import 'package:customer/model/user.dart';

class Order {
  String? id;
  double? totalAmount;
  String? orderDate;
  String? deliveryDate; // Sửa từ Null thành String? để khớp với API
  String? customerId; // Sửa tên trường
  String? createdById; // Sửa tên trường
  String? status;
  User? user;
  List<OrderDetails>? orderDetails;

  Order({
    this.id,
    this.totalAmount,
    this.orderDate,
    this.deliveryDate,
    this.customerId,
    this.createdById,
    this.status,
    this.user,
    this.orderDetails,
  });

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalAmount = json['totalAmount']?.toDouble();
    orderDate = json['orderDate'];
    deliveryDate = json['deliveryDate'];
    customerId = json['customerId'];
    createdById = json['createdById'];
    status = json['status'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['orderDetails'] != null) {
      orderDetails = (json['orderDetails'] as List)
          .map((v) => OrderDetails.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['totalAmount'] = totalAmount;
    data['orderDate'] = orderDate;
    data['deliveryDate'] = deliveryDate;
    data['customerId'] = customerId;
    data['createdById'] = createdById;
    data['status'] = status;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (orderDetails != null) {
      data['orderDetails'] = orderDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
