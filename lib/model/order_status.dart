class OrderStatus {
  final String name;
  final String description;

  const OrderStatus._(this.name, this.description);

  static const ADDTOCART =
      OrderStatus._("ADDTOCART", "Thêm sản phẩm vào giỏ hàng");
  static const PENDING = OrderStatus._("PENDING", "Đang chờ xác nhận");
  static const CONFIRMED = OrderStatus._("CONFIRMED", "Đã xác nhận");
  static const CANCELED = OrderStatus._("CANCELED", "Đã hủy");
  static const PREPARING = OrderStatus._("PREPARING", "Đang chuẩn bị hàng");
  static const READY_TO_SHIP =
      OrderStatus._("READY_TO_SHIP", "Đã sẵn sàng để giao");
  static const SHIPPING = OrderStatus._("SHIPPING", "Đang vận chuyển");
  static const OUT_FOR_DELIVERY =
      OrderStatus._("OUT_FOR_DELIVERY", "Đang giao hàng");
  static const DELIVERY_FAILED =
      OrderStatus._("DELIVERY_FAILED", "Giao hàng thất bại");
  static const DELIVERED = OrderStatus._("DELIVERED", "Đã giao hàng");
  static const RETURN_REQUESTED =
      OrderStatus._("RETURN_REQUESTED", "Yêu cầu trả hàng");
  static const RETURNED = OrderStatus._("RETURNED", "Đã trả hàng");
  static const REFUNDED = OrderStatus._("REFUNDED", "Đã hoàn tiền");

  static const values = [
    ADDTOCART,
    PENDING,
    CONFIRMED,
    CANCELED,
    PREPARING,
    READY_TO_SHIP,
    SHIPPING,
    OUT_FOR_DELIVERY,
    DELIVERY_FAILED,
    DELIVERED,
    RETURN_REQUESTED,
    RETURNED,
    REFUNDED,
  ];

  static OrderStatus fromString(String status) {
    return values.firstWhere(
      (e) => e.name == status.toUpperCase(),
      orElse: () => OrderStatus.PENDING, // Giá trị mặc định nếu không tìm thấy
    );
  }
}
