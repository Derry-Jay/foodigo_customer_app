import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/cart_bill_widget.dart';
import 'package:foodigo_customer_app/elements/cart_item_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/models/coupon.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  final RouteArgument rar;
  CartPage(this.rar);
  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends StateMVC<CartPage> {
  int id = -1;
  Coupon coupon;
  Cart cart;
  bool flag;
  HotelController con;
  String d1, d2;
  var kms, cusLoc;
  List<int> a = List.empty(growable: true), c = List.empty(growable: true);
  List<double> b = List.empty(growable: true);
  Map<String, dynamic> cartData, addressData;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  TextEditingController note = new TextEditingController();
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));

  CartPageState() : super(HotelController()) {
    con = controller;
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    final f1 = sharedPrefs.containsKey("itemCount");
    final f2 = sharedPrefs.containsKey("itemPrice");
    final f3 = sharedPrefs.containsKey("coupon");
    final f4 = sharedPrefs.containsKey("items");
    id = int.tryParse(sharedPrefs.getString("spHotelID") ?? "-1") ?? -1;
    if (mounted) {
      hp.lockScreenRotation();
      hp.getConnectStatus();
    }
    if (f1)
      a = List.from(json.decode(sharedPrefs.getString("itemCount")))
          .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
          .toList();
    if (f2)
      b = List.from(json.decode(sharedPrefs.getString("itemPrice")))
          .map((e) => double.tryParse(e.toString() ?? "0.0") ?? 0.0)
          .toList();
    if (f3)
      coupon = Coupon.fromMap(json.decode(sharedPrefs.getString("coupon")));
    if (f4)
      c = List.from(json.decode(sharedPrefs.getString("items")))
          .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
          .toList();
    flag = sharedPrefs.containsKey("cartData");
    cartData = flag
        ? (sharedPrefs.getString("cartData") == null ||
                sharedPrefs.getString("cartData") == ""
            ? Map<String, dynamic>()
            : json.decode(sharedPrefs.getString("cartData")))
        : Map<String, dynamic>();
    addressData = sharedPrefs.containsKey("defaultAddress")
        ? json.decode(sharedPrefs.getString("defaultAddress"))
        : Map<String, dynamic>();
    if (cart == null && cartData != null && cartData.isNotEmpty)
      cart = Cart.fromMap(cartData);
    if (addressData.isNotEmpty) {
      d1 = addressData["area"];
      d2 = addressData["clipped_address"];
    }

    await con.waitForHotelData(id);
    con.pauseForFoods(id);

    double lat = addressData['latitude'];
    double long = addressData['longitude'];
    cusLoc = LatLng(lat, long);
    kms = hp.distanceInKM(con.hotel.coordinates, cusLoc).ceil();
    await con.waitForFoodigoGST();
    await con.getDeliveryFee(kms);
  }

  void updateData() async {
    final sharedPrefs = await _sharedPrefs;
    flag = sharedPrefs.containsKey("cartData");
    cartData = flag
        ? (sharedPrefs.getString("cartData") == null ||
                sharedPrefs.getString("cartData").isEmpty
            ? Map<String, dynamic>()
            : json.decode(sharedPrefs.getString("cartData")))
        : Map<String, dynamic>();
    if (cart == null && cartData != null && cartData.isNotEmpty)
      setState(() => cart = Cart.fromMap(cartData));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    updateData();
    return Scaffold(
        backgroundColor: Colors.white,
        // resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //     title: Text('Personal Details'),
        //     leading: IconButton(
        //         icon: Icon(Icons.arrow_back_ios),
        //         onPressed: () => Navigator.of(context).pop()),
        //     centerTitle: true,
        //     elevation: 0),
        body: cartData == null
            ? Image.asset("assets/images/loading_trend.gif",
                fit: BoxFit.fill, height: height, width: width)
            : (cartData.isEmpty
                ? Center(
                    child: Text(
                        hp.loc.dont_have_any_item_in_your_cart + " !!!!",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffa11414))),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CartItemWidget(cart: cart),
                      Align(
                          child: Column(children: [
                            CartBillWidget(
                              cart: cart,
                              deliveryfee:
                                  double.tryParse(con.deliveryFee.toString()) ??
                                      0.0,
                              hotelGst:
                                  con.hotel == null ? "" : con.hotel.gstNum,
                            ),
                            Container(
                                margin: EdgeInsets.only(top: height / 40),
                                child: Row(
                                    children: [
                                      Text(
                                          "Delivery Time : " +
                                              ((hp.travelTime1(
                                                              con.hotel == null
                                                                  ? LatLng(
                                                                      0.0, 0.0)
                                                                  : (con.hotel.coordinates ==
                                                                          null
                                                                      ? LatLng(
                                                                          0.0,
                                                                          0.0)
                                                                      : con
                                                                          .hotel
                                                                          .coordinates),
                                                              cusLoc ??
                                                                  LatLng(0.0,
                                                                      0.0)) *
                                                          5) /
                                                      3)
                                                  .ceil()
                                                  .toString() +
                                              " mins",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          "Distance : " +
                                              (con.hotel == null
                                                  ? "0"
                                                  : hp
                                                      .distanceInKM(
                                                          con.hotel.coordinates,
                                                          cusLoc)
                                                      .ceil()
                                                      .toString()) +
                                              " Kms",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600))
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween),
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / 25,
                                    vertical: height / 100),
                                decoration: BoxDecoration(
                                    color: Color(0xffFCEAEA),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(radius / 80)))),
                            Row(children: [
                              Expanded(
                                  // height: height / 16,
                                  // width: width / 2.4,
                                  child: d1 != null && d2 != null
                                      ? Column(
                                          children: [
                                              Container(
                                                  child: Text(
                                                      hp.loc.delivery_address,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                              0xffa11414))),
                                                  padding: EdgeInsets.only(
                                                      left: width / 25.6,
                                                      bottom: height / 400)),
                                              Container(
                                                  child: Text(d1,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  padding: EdgeInsets.only(
                                                      top: height / 400,
                                                      left: width / 25.6)),
                                              Container(
                                                  padding: EdgeInsets.only(
                                                      left: width / 25.6),
                                                  child: Text(d2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500)))
                                            ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start)
                                      : Text(
                                          hp.loc.confirm_your_delivery_address,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xffa11414)))),
                              OutlinedButton(
                                  onPressed: () async {
                                    // double lat = addressData['latitude'];
                                    // // double.parse();
                                    // double long = addressData['longitude'];
                                    // var l = LatLng(lat, long);
                                    // print(l);

                                    // print(coupon.admin);
                                    int price = 0;
                                    if (con.hotel.gstNum == "") {
                                      if (coupon != null) {
                                        if (coupon.type == "percent") {
                                          price = (cart.cartValuewithoutGST *
                                                  (100 -
                                                      (double.tryParse(coupon
                                                              .discount) ??
                                                          0.0)))
                                              .toInt();
                                          price =
                                              price + (con.deliveryFee * 100);
                                        } else {
                                          price = ((cart.cartValuewithoutGST -
                                                      (double.tryParse(coupon
                                                              .discount) ??
                                                          0.0)) *
                                                  100)
                                              .toInt();
                                          price =
                                              price + (con.deliveryFee * 100);
                                        }
                                      } else {
                                        price = (cart.cartValuewithoutGST * 100)
                                            .toInt();
                                        price = price + (con.deliveryFee * 100);
                                      }
                                    } else {
                                      if (coupon != null) {
                                        if (coupon.type == "percent") {
                                          price = (cart.cartValue *
                                                  (100 -
                                                      (double.tryParse(coupon
                                                              .discount) ??
                                                          0.0)))
                                              .toInt();
                                          price =
                                              price + (con.deliveryFee * 100);
                                        } else {
                                          price = ((cart.cartValue -
                                                      (double.tryParse(coupon
                                                              .discount) ??
                                                          0.0)) *
                                                  100)
                                              .toInt();
                                          price =
                                              price + (con.deliveryFee * 100);
                                        }
                                      } else {
                                        price = (cart.cartValue * 100).toInt();
                                        price = price + (con.deliveryFee * 100);
                                      }
                                    }

                                    hp.navigateTo('/paymentMethod',
                                        arguments: RouteArgument(
                                            param: {
                                              "amount": price.toString(),
                                              "currency": "INR",
                                              "receipt": "receipt#" +
                                                  Random()
                                                      .nextInt(99999)
                                                      .toString()
                                            },
                                            tax: {
                                              // "tax": cart.gst.toString(),
                                              "tax": con.hotel.gstNum == ""
                                                  ? ""
                                                  : hp
                                                      .getTax(coupon != null &&
                                                              coupon.couponID >
                                                                  0
                                                          ? (cart.itemTotal -
                                                              hp.getCouponDiscount(
                                                                  cart, coupon))
                                                          : cart.itemTotal)
                                                      .toString(),
                                              "order_final_amount":
                                                  cart.itemTotal.toString(),
                                              "deliveryfee":
                                                  con.deliveryFee.toString(),
                                              "hint": note.text,
                                              "coupon_owner": coupon != null
                                                  ? coupon.admin.toString()
                                                  : "",
                                              "coupon_amount": (hp
                                                  .getCouponDiscount(
                                                      cart, coupon)
                                                  .toStringAsFixed(2)),
                                              "order_amount": coupon == null
                                                  ? cart.itemTotal
                                                      .toStringAsFixed(2)
                                                  :
                                                  // coupon.admin != 0
                                                  //     ? cart.itemTotal
                                                  //         .toStringAsFixed(2)
                                                  //     :
                                                  coupon != null &&
                                                          coupon.couponID > 0
                                                      ? (cart.itemTotal -
                                                              hp.getCouponDiscount(
                                                                  cart, coupon))
                                                          .toStringAsFixed(2)
                                                      : cart.itemTotal
                                                          .toStringAsFixed(2)
                                            },
                                            id: coupon == null
                                                    //  ||
                                                    //         coupon.hotelID !=
                                                    //             cart.hotelID
                                                    ||
                                                    coupon.couponID <= 0
                                                ? ""
                                                : coupon.couponID.toString()),
                                        onGoBack: onGoBack);
                                    print(price);
                                  },
                                  child: Container(
                                      child: Center(
                                        child: Text(hp.loc.confirm_payment,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white)),
                                      ),
                                      height: height / 16,
                                      width: width / 2.305843009213693952),
                                  style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(
                                          Size.square(radius / 25)),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.zero))),
                                      side: MaterialStateProperty.all(
                                          BorderSide(color: Color(0xffa11414))),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xffa11414))))
                            ], crossAxisAlignment: CrossAxisAlignment.end)
                          ]),
                          alignment: Alignment.bottomCenter)
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween)));
  }

  onpop(dynamic result) {
    Navigator.pop(context, result);
  }

  @override
  void dispose() {
    hp.rollbackOrientations();
    super.dispose();
  }

  FutureOr onGoBack(dynamic value) async {
    final sharedPrefs = await _sharedPrefs;
    if (sharedPrefs.containsKey("coupon"))
      setState(() => coupon =
          Coupon.fromMap(json.decode(sharedPrefs.getString("coupon"))));
    if (!sharedPrefs.containsKey("cartData"))
      setState(() => cartData = Map<String, dynamic>());
  }
}
