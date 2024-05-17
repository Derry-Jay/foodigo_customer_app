import 'package:global_configuration/global_configuration.dart';

class RazorPayOrder {
  final String orderID, entity, currency, offerID, status;
  final int receiptID, amount, amountPaid, amountDue, createdAt, attempts;
  RazorPayOrder(
      this.orderID,
      this.entity,
      this.amount,
      this.amountPaid,
      this.amountDue,
      this.currency,
      this.receiptID,
      this.offerID,
      this.status,
      this.attempts,
      this.createdAt);
  Map<String, dynamic> get json {
    final gc = GlobalConfiguration();
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['order_id'] = orderID;
    map['entity'] = entity;
    map['amount'] = amount;
    map['amount_paid'] = amountPaid;
    map['amount_due'] = amountDue;
    map['currency'] = currency;
    map['key'] = gc.getValue('razor_pay_key');
    return map;
  }

  factory RazorPayOrder.fromMap(Map<String, dynamic> json) => RazorPayOrder(
      json['id'],
      json['entity'],
      json['amount'],
      json['amount_paid'],
      json['amount_due'],
      json['currency'],
      json['receipt'] == null
          ? 0
          : (int.tryParse(json['receipt'].toString().trim().split("#").last) ??
              0),
      json['offer_id'] ?? "",
      json['status'],
      json['attempts'],
      json['created_at']);
}
