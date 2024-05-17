import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/models/coupon.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponItemWidget extends StatefulWidget {
  final Coupon coupon;
  final String route;
  final Cart cart;
  CouponItemWidget({Key key, @required this.coupon, this.route, this.cart})
      : super(key: key);
  @override
  CouponItemWidgetState createState() => CouponItemWidgetState();
}

class CouponItemWidgetState extends StateMVC<CouponItemWidget> {
  HotelController con;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get pixelRatio => dimensions.devicePixelRatio;
  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  CouponItemWidgetState() : super(HotelController()) {
    con = controller;
  }

  @override
  void initState() {
    super.initState();
    //con.waitForHotelData(widget.coupon.hotelID);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // final str = "Get " +
    //     widget.coupon.discount +
    //     " " +
    //     widget.coupon.type +
    //     " discount at " +
    //     (con.hotel == null ? "" : con.hotel.restName);
    final str = "Get " +
        widget.coupon.discount +
        " " +
        widget.coupon.type +
        " discount";
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
      child: Card(
          elevation: 0,
          color: Color(0xfff6f6f6),
          shape: BeveledRectangleBorder(
            borderRadius:
                BorderRadius.circular(radius / 151.115727451828646838272),
          ),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(radius / 151.115727451828646838272))),
              child: IntrinsicWidth(
                  child: Column(children: [
                Row(children: [
                  Container(
                      color: Color(0xfffceaea),
                      child: Text(widget.coupon.code.toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 14.7573952589676412928)),
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 80, vertical: height / 160)
                      // , margin: EdgeInsets.only(bottom: height / 200)
                      ),
                  widget.route == "profile"
                      ? Container()
                      : GestureDetector(
                          child: Container(
                              child: Text("APPLY",
                                  style: TextStyle(
                                      fontSize: 12.8,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              padding: EdgeInsets.symmetric(
                                  vertical: height / 160,
                                  horizontal: width / 50),
                              decoration: BoxDecoration(
                                  color: Color(0xffA11414),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(radius /
                                          151.115727451828646838272)))),
                          onTap: () async {
                            final sharedPrefs =
                                await SharedPreferences.getInstance();
                            double expect = double.tryParse(
                                widget.coupon.amountExpect.toString());
                            if (widget.coupon.type == "percent") {
                              if (!sharedPrefs.containsKey("spHotelID")) {
                                final p = await sharedPrefs.setString(
                                    "coupon", json.encode(widget.coupon.json));
                                if (p)
                                  Fluttertoast.showToast(
                                      msg:
                                          "The Coupon is applied, you can get the discount on checkout");
                                Navigator.of(context).pop();
                              } else {
                                int i = int.tryParse(
                                        sharedPrefs.getString("spHotelID") ??
                                            "-1") ??
                                    -1;
                                // if (i == widget.coupon.hotelID) {}
                                final p = await sharedPrefs.setString(
                                    "coupon", json.encode(widget.coupon.json));
                                if (p)
                                  Fluttertoast.showToast(
                                      msg:
                                          "The Coupon is applied, you can get the discount on checkout");
                                Navigator.of(context).pop();

                                // else
                                //   Fluttertoast.showToast(
                                //       msg:
                                //           "You Cannot Use the Coupon with this Restaurant");
                              }
                            } else if (widget.cart.itemTotal >= expect) {
                              if (!sharedPrefs.containsKey("spHotelID")) {
                                final p = await sharedPrefs.setString(
                                    "coupon", json.encode(widget.coupon.json));
                                if (p)
                                  Fluttertoast.showToast(
                                      msg:
                                          "The Coupon is applied, you can get the discount on checkout");
                                Navigator.of(context).pop();
                              } else {
                                int i = int.tryParse(
                                        sharedPrefs.getString("spHotelID") ??
                                            "-1") ??
                                    -1;
                                // if (i == widget.coupon.hotelID) {}
                                final p = await sharedPrefs.setString(
                                    "coupon", json.encode(widget.coupon.json));
                                if (p)
                                  Fluttertoast.showToast(
                                      msg:
                                          "The Coupon is applied, you can get the discount on checkout");
                                Navigator.of(context).pop();

                                // else
                                //   Fluttertoast.showToast(
                                //       msg:
                                //           "You Cannot Use the Coupon with this Restaurant");
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Minimum order value for this coupon is ₹ " +
                                          widget.coupon.amountExpect
                                              .toString());
                            }
                          })
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                // SizedBox(
                //   height: 8.0,
                // ),
                Text(str,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: str.length > 40
                            ? 13.7438953472
                            : 14.7573952589676412928)),
                Divider(),
                Text(
                    "Use code " +
                        widget.coupon.code +
                        " and get up to " +
                        widget.coupon.discount +
                        " " +
                        widget.coupon.type +
                        " discount",
                    style: TextStyle(color: Colors.black, fontSize: 12.8)),
                SizedBox(
                  height: 5.0,
                ),
                Text("Expires on - " + widget.coupon.expiryDate.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 12.8))
              ], crossAxisAlignment: CrossAxisAlignment.start)),
              //height: height / 5,
              padding: EdgeInsets.symmetric(
                  vertical: height / 100, horizontal: width / 40))),
    );
  }
}
