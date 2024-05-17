import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/pages/cart_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartBillWidget extends StatefulWidget {
  final Cart cart;
  final double deliveryfee;
  final String hotelGst;
  CartBillWidget(
      {Key key, @required this.cart, this.deliveryfee, this.hotelGst})
      : super(key: key);
  @override
  CartBillWidgetState createState() => CartBillWidgetState();
  static CartPageState of(BuildContext context) =>
      context.findAncestorStateOfType<CartPageState>();
}

class CartBillWidgetState extends State<CartBillWidget> {
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  CartPageState get cps => CartBillWidget.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        elevation: 0,
        child: Container(
            child: Column(
              children: [
                Row(children: [
                  Image.asset('assets/images/discount.png',
                      height: height / 32, fit: BoxFit.cover),
                  Text(
                      cps.coupon == null //|| cps.coupon.hotelID != cps.id
                          ? "APPLY COUPON"
                          : cps.coupon.code.toUpperCase(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16)),
                  IconButton(
                      icon: Icon(
                          cps.coupon == null //|| cps.coupon.hotelID != cps.id
                              ? Icons.arrow_forward_ios
                              : Icons.close),
                      onPressed: () async {
                        print("widget.cart.itemTotal");
                        print(widget.cart.itemTotal);
                        final sharedPrefs = await _sharedPrefs;
                        if (cps.coupon == null) {
                          cps.hp.navigateTo('/coupons',
                              arguments: widget.cart, onGoBack: cps.onGoBack);
                        } else {
                          final p = await sharedPrefs.remove("coupon");
                          if (p) cps.setState(() => cps.coupon = null);
                        }
                      })
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                Divider(color: Color(0xffE2E0E0), indent: 5, endIndent: 5),
                Column(children: [
                  Row(children: [
                    Text("Item Total",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14)),
                    Text(
                        // cps.coupon != null && cps.coupon.couponID > 0
                        //     ? (widget.cart.itemTotal -
                        //             cps.hp.getCouponDiscount(
                        //                 widget.cart, cps.coupon))
                        //         .toStringAsFixed(2)
                        //     :
                        widget.cart.itemTotal.toStringAsFixed(2),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14))
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  Row(children: [
                    Text("Delivery Charge",
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff676666),
                            fontWeight: FontWeight.w500)),
                    Text(widget.deliveryfee.toString(),
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff676666),
                            fontWeight: FontWeight.w500))
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  widget.hotelGst == ""
                      ? Container()
                      : Row(children: [
                          Text("Tax",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff676666),
                                  fontWeight: FontWeight.w500)),
                          Text(
                              cps.hp
                                  .getTax(cps.coupon != null &&
                                          cps.coupon.couponID > 0
                                      ? (widget.cart.itemTotal -
                                          cps.hp.getCouponDiscount(
                                              widget.cart, cps.coupon))
                                      : widget.cart.itemTotal)
                                  .toString(), //widget.cart.gst.toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff676666),
                                  fontWeight: FontWeight.w500))
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  Visibility(
                      child: Row(children: [
                        Text("Coupon Discount",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff676666),
                                fontWeight: FontWeight.w500)),
                        Text(
                            "- " +
                                (cps.hp
                                    .getCouponDiscount(widget.cart, cps.coupon)
                                    .toStringAsFixed(2)),
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff676666),
                                fontWeight: FontWeight.w500))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      visible: cps.coupon != null && cps.coupon.couponID > 0
                      // &&
                      // cps.coupon.hotelID == widget.cart.hotelID
                      )
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                Divider(color: Color(0xffE2E0E0), indent: 5, endIndent: 5),
                Row(children: [
                  Text("Grand Total",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  widget.hotelGst == ""
                      ? Text(
                          cps.coupon == null || cps.coupon.couponID <= 0
                              // ||
                              // cps.coupon.hotelID != widget.cart.hotelID
                              ? (widget.cart.itemTotal + widget.deliveryfee)
                                  .toString()
                              : (widget.cart.itemTotal - cps.hp.getCouponDiscount(widget.cart, cps.coupon) + widget.deliveryfee)
                                  .toStringAsFixed(2),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16))
                      : Text(
                          cps.coupon == null || cps.coupon.couponID <= 0
                              // ||
                              // cps.coupon.hotelID != widget.cart.hotelID
                              ? (widget.cart.itemTotal +
                                      widget.deliveryfee +
                                      cps.hp.getTax(
                                          cps.coupon != null && cps.coupon.couponID > 0
                                              ? (widget.cart.itemTotal -
                                                  cps.hp.getCouponDiscount(
                                                      widget.cart, cps.coupon))
                                              : widget.cart.itemTotal))
                                  .toString()
                              : (widget.cart.itemTotal -
                                      cps.hp.getCouponDiscount(
                                          widget.cart, cps.coupon) +
                                      widget.deliveryfee +
                                      cps.hp.getTax(cps.coupon != null && cps.coupon.couponID > 0
                                          ? (widget.cart.itemTotal -
                                              cps.hp.getCouponDiscount(widget.cart, cps.coupon))
                                          : widget.cart.itemTotal))
                                  .toStringAsFixed(2),
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16))
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
              ],
            ),
            padding: EdgeInsets.symmetric(
                horizontal: width / 25, vertical: height / 80)),
        color: Color(0xffF6F6F6));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
