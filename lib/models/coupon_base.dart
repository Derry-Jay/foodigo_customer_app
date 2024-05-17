import 'package:foodigo_customer_app/models/coupon.dart';
import 'package:foodigo_customer_app/models/reply.dart';

class CouponBase {
  final Reply response;
  final List<Coupon> coupons;
  CouponBase(this.response, this.coupons);
  factory CouponBase.fromMap(Map<String, dynamic> json) {
    return CouponBase(Reply.fromMap(json),
        List.from(json['data']).map((e) => Coupon.fromMap(e)).toList());
  }
}
