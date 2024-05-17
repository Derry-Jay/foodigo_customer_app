import 'package:foodigo_customer_app/models/order.dart';
import 'package:foodigo_customer_app/models/reply.dart';

class OrderBase {
  final Reply response;
  final List<Order> orders;
  OrderBase(this.response, this.orders);
  factory OrderBase.fromMap(Map<String, dynamic> json) {
    return OrderBase(
        Reply.fromMap(json),
        json['data'] == null
            ? <Order>[]
            : List.from(json['data']).map((e) => Order.fromMap(e)).toList());
  }
}
