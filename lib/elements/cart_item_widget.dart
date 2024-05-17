import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/models/ordered_food.dart';
import 'package:foodigo_customer_app/pages/cart_page.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItemWidget extends StatefulWidget {
  final Cart cart;
  CartItemWidget({Key key, @required this.cart}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CartItemWidgetState();
  static CartPageState of(BuildContext context) =>
      context.findAncestorStateOfType<CartPageState>();
}

class CartItemWidgetState extends StateMVC<CartItemWidget> {
  HotelController con;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  CartPageState get cps => CartItemWidget.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  CartItemWidgetState() : super(HotelController()) {
    con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    print("cart test");
    print(widget.cart.json);
    super.initState();
    cps;
    con.waitForHotelData(widget.cart.hotelID);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Container(
        height: height / 2,
        margin:
            EdgeInsets.symmetric(horizontal: width / 25, vertical: height / 50),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
                margin: EdgeInsets.only(top: height / 16),
                child: Row(children: [
                  Container(
                    width: width / 2,
                    child: Text(
                      con.hotel == null
                          ? ""
                          : (con.hotel.restName == null
                              ? ""
                              : con.hotel.restName),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                      con.hotel == null
                          ? ""
                          : (con.hotel.location == null
                              ? ""
                              : con.hotel.location),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500))
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                padding: EdgeInsets.symmetric(
                    horizontal: width / 50, vertical: height / 100),
                decoration: BoxDecoration(
                    color: Color(0xffFCEAEA),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(size / 160)))),
            Container(
                child: Column(children: [
                  for (OrderedFood cf in widget.cart.foods)
                    Row(children: [
                      Expanded(
                          child: Text(cf.food,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500))),
                      Expanded(
                          child: Row(children: [
                        Card(
                          shape: StadiumBorder(
                              side: BorderSide(color: Color(0xffBAD600))),
                          elevation: 0,
                          child: Row(children: [
                            InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(size * 2)),
                                child: Image.asset("assets/images/minus.png",
                                    width: width / 20, height: height / 40),
                                onTap: () async {
                                  final sharedPrefs = await _sharedPrefs;
                                  final resID =
                                      sharedPrefs.getString("spHotelID");
                                  cps.setState(() => widget.cart
                                      .decrementProductCount(
                                          widget.cart.foods.indexOf(cf),
                                          cps.c));
                                  if (widget.cart.foods.indexOf(cf) != -1 &&
                                      widget.cart.foods.indexOf(cf) <
                                          cps.c.length) {
                                    int i =
                                        cps.c[widget.cart.foods.indexOf(cf)];
                                    cps.a[i] = cps.a[i] <= 1 ? 0 : cps.a[i] - 1;
                                    cps.b[i] = cps.a[i] <= 1
                                        ? 0.0
                                        : (double.tryParse(cf.price ?? "0.0") ??
                                                0.0) *
                                            cps.a[i];
                                    print(widget.cart.json);
                                    final p = await sharedPrefs.setString(
                                        "cartData",
                                        json.encode(widget.cart.json));
                                    final q = await sharedPrefs.setString(
                                        "itemCount", json.encode(cps.a));
                                    final r = await sharedPrefs.setString(
                                        "itemPrice", json.encode(cps.b));
                                    final s = await sharedPrefs.setString(
                                        "items", json.encode(cps.c));
                                    if (p && q && r && s) {
                                      print(cps.a);
                                      print(cps.b);
                                      print(cps.c);
                                    }
                                  } else if (widget.cart.foods.isEmpty) {
                                    final n = await sharedPrefs.remove("items");
                                    final p =
                                        await sharedPrefs.remove("cartData");
                                    final q =
                                        await sharedPrefs.remove("itemCount");
                                    final r =
                                        await sharedPrefs.remove("itemPrice");
                                    final s =
                                        await sharedPrefs.remove("spHotelID");
                                    final t =
                                        await sharedPrefs.remove("coupon");
                                    if (n && p && q && r && s && t)
                                      // Navigator.pop(context);
                                      cps.onpop(resID);
                                  } else {
                                    print(widget.cart.json);
                                    final p = await sharedPrefs.setString(
                                        "cartData",
                                        json.encode(widget.cart.json));
                                    final q = await sharedPrefs.setString(
                                        "itemCount", json.encode(cps.a));
                                    final r = await sharedPrefs.setString(
                                        "itemPrice", json.encode(cps.b));
                                    final s = await sharedPrefs.setString(
                                        "items", json.encode(cps.c));
                                    if (p && q && r && s) {
                                      print(cps.a);
                                      print(cps.b);
                                      print(cps.c);
                                    }
                                  }
                                }),
                            Container(
                                child: Text(cf.quantity.toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                decoration: BoxDecoration(
                                    color: Color(0xfff7f7f7),
                                    border:
                                        Border.all(color: Color(0xffBAD600))),
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / 50,
                                    vertical: height / 400)),
                            InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(size * 2)),
                                onTap: () async {
                                  final sharedPrefs = await _sharedPrefs;
                                  cps.setState(() => widget.cart
                                      .incrementProductCount(
                                          widget.cart.foods.indexOf(cf)));
                                  int i = cps.c[widget.cart.foods.indexOf(cf)];
                                  print(i);
                                  ++cps.a[i];
                                  cps.b[i] =
                                      double.tryParse(cf.price) * cps.a[i];
                                  final p = await sharedPrefs.setString(
                                      "cartData",
                                      json.encode(widget.cart.json));
                                  final q = await sharedPrefs.setString(
                                      "itemCount", json.encode(cps.a));
                                  final r = await sharedPrefs.setString(
                                      "itemPrice", json.encode(cps.b));
                                  if (p && q && r) {
                                    print(cps.a);
                                    print(cps.b);
                                  }
                                },
                                child: Image.asset("assets/images/plus.png",
                                    width: width / 20))
                          ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                        ),
                        Text(
                            widget.cart
                                .getFoodPrice(widget.cart.foods.indexOf(cf))
                                .toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween)),
                    ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  TextFormField(
                      cursorColor: Color(0xffbad600),
                      decoration: InputDecoration(
                          // prefixStyle: TextStyle(
                          //     color: Colors.black,
                          //     fontWeight: FontWeight.w600,
                          //     fontSize: 17.179869184),
                          // prefix: IntrinsicHeight(
                          //   child: Row(
                          //     children: [
                          //       // Text("+91"),
                          //       Flexible(
                          //           child: Text("+91",
                          //               style: TextStyle(
                          //                   color: Colors.black,
                          //                   fontSize: 17.179869184,
                          //                   fontWeight:
                          //                       FontWeight.w600))),
                          //       VerticalDivider(
                          //           thickness: 1,
                          //           color: Color(0xff707070),
                          //           indent: 0,
                          //           endIndent: 0,
                          //           width: 1)
                          //     ],
                          //   ),
                          // ),
                          // ,
                          // prefixIcon: Padding(
                          //   padding: const EdgeInsets.only(top: 12),
                          //   child: Text(
                          //     "+91",
                          //     style: TextStyle(
                          //         color: Colors.black,
                          //         fontWeight: FontWeight.w600,
                          //         fontSize: 17.179869184),
                          //   ),
                          // ),
                          // prefixText: "+91",
                          hintText: "Preferred choice",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffBAD600)),
                            borderRadius: BorderRadius.circular(size / 200),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffBAD600)),
                            borderRadius: BorderRadius.circular(size / 200),
                          )),
                      controller: cps.note,
                      keyboardType: TextInputType.name,
                      // inputFormatters: [
                      //   WhitelistingTextInputFormatter.digitsOnly
                      // ],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.179869184)),
                ]),
                padding: EdgeInsets.symmetric(
                    horizontal: width / 50, vertical: height / 64),
                decoration: BoxDecoration(
                    color: Color(0xffF7F7F7),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(size / 200))))
          ],
        ),
        // shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(size))),
        // elevation: 0,
        // borderOnForeground: true
      ),
    );
  }
}
