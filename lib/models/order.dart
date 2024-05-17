import 'package:google_maps_flutter/google_maps_flutter.dart';

class Order {
  final int orderID, hotelID, customerID, driverID, otp, orderStatusID;
  final String hint,
      payMethod,
      tax,
      deliveryFee,
      orderStatus,
      total,
      couponamount,
      dateTime;
  final LatLng hotelLoc, driverLoc, customerLoc;
  final bool active;
  Order(
      this.orderID,
      this.orderStatusID,
      this.tax,
      this.deliveryFee,
      this.active,
      this.hint,
      this.hotelID,
      this.customerID,
      this.driverID,
      this.hotelLoc,
      this.driverLoc,
      this.customerLoc,
      this.total,
      this.otp,
      this.orderStatus,
      this.couponamount,
      this.dateTime,
      this.payMethod);
  factory Order.fromMap(Map<String, dynamic> json) {
    print(json['active']);
    return Order(
      json['id'] ?? -1,
      json['order_status_id'] ?? 0,
      json['tax'] == null ? "" : json['tax'].toString(),
      json['delivery_fee'] == null ? "" : json['delivery_fee'].toString(),
      json['active'] ?? false,
      json['hint'].toString() ?? "",
      json['restaurant_id'] ?? -1,
      json['user_id'] ?? -1,
      int.tryParse(json['driver_id'] ?? "-1") ?? -1,
      LatLng(
          json['restaurent_lat'] == null
              ? 0.0
              : (json['restaurent_lat'] is double
                  ? json['restaurent_lat']
                  : (json['restaurent_lat'] is int
                      ? json['restaurent_lat'].toDouble() ?? 0.0
                      : double.tryParse(json['restaurent_lat'] ?? "0.0") ??
                          0.0)),
          json['restaurent_lang'] == null
              ? 0.0
              : (json['restaurent_lang'] is double
                  ? json['restaurent_lang']
                  : (json['restaurent_lang'] is int
                      ? json['restaurent_lang'].toDouble() ?? 0.0
                      : double.tryParse(json['restaurent_lang'] ?? "0.0") ??
                          0.0))),
      LatLng(
          json['driver_lat'] == null
              ? 0.0
              : (json['driver_lat'] is double
                  ? json['driver_lat']
                  : (json['driver_lat'] is int
                      ? json['driver_lat'].toDouble() ?? 0.0
                      : double.tryParse(json['driver_lat'] ?? "0.0") ?? 0.0)),
          json['driver_lang'] == null
              ? 0.0
              : (json['driver_lang'] is double
                  ? json['driver_lang']
                  : (json['driver_lang'] is int
                      ? json['driver_lang'].toDouble() ?? 0.0
                      : double.tryParse(json['driver_lang'] ?? "0.0") ?? 0.0))),
      LatLng(
          json['customer_lat'] == null
              ? 0.0
              : (json['customer_lat'] is double
                  ? json['customer_lat']
                  : (json['customer_lat'] is int
                      ? json['customer_lat'].toDouble() ?? 0.0
                      : double.tryParse(json['customer_lat'] ?? "0.0") ?? 0.0)),
          json['customer_lang'] == null
              ? 0.0
              : (json['customer_lang'] is double
                  ? json['customer_lang']
                  : (json['customer_lang'] is int
                      ? json['customer_lang'].toDouble() ?? 0.0
                      : double.tryParse(json['customer_lang'] ?? "0.0") ??
                          0.0))),
      // json['order_amount'] == null
      //     ?
      (json['total_amount'] == null ? "" : json['total_amount'].toString()),
      // : json['order_amount'].toString(),
      json['orderotp'] == null ? 0 : json['orderotp'],
      json['order_status'] == null || json['order_status'].isEmpty
          ? (json['status'] == null || json['status'].isEmpty
              ? "Order Status Unavailable"
              : json['status'])
          : json['order_status'].toString(),
      json['coupon_amount'] == null ? "" : json['coupon_amount'].toString(),
      json['created_at'].toString() ?? "",
      json['paymethod'] == null ? "" : json['paymethod'].toString(),
    );
  }

  bool isIn(List<Order> orders) {
    bool val = false;
    if (orders == null || orders.isEmpty)
      return orders.isNotEmpty;
    else {
      for (Order i in orders)
        if (i == this) {
          val = true;
          break;
        }
      return val;
    }
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Order && this.orderID == other.orderID;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.orderID.hashCode;
}
