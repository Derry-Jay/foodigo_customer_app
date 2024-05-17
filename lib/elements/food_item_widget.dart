import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/models/food.dart';
import 'package:foodigo_customer_app/models/ordered_food.dart';
import 'package:foodigo_customer_app/pages/hotel_details_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodItemWidget extends StatefulWidget {
  final Food food;
  final int index;
  final String imgbase;
  FoodItemWidget({@required this.food, @required this.index, this.imgbase});
  @override
  FoodItemWidgetState createState() => FoodItemWidgetState();
  static HotelDetailsPageState of(BuildContext context) =>
      context.findAncestorStateOfType<HotelDetailsPageState>();
}

class FoodItemWidgetState extends State<FoodItemWidget> {
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  HotelDetailsPageState get hps => FoodItemWidget.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  String hotelID;
  bool isSelect = false;
  bool isload = true;
  bool isopen = false;

  void timeSet() {
    print("From time one");
    print(widget.food.fromtime);
    print(widget.food.fromtimeone);
    DateFormat dateFormat = new DateFormat.Hm();
    DateTime now = DateTime.now();
    DateTime open = dateFormat.parse(widget.food.fromtime);
    open = new DateTime(now.year, now.month, now.day, open.hour, open.minute);
    DateTime close = dateFormat.parse(widget.food.totime);
    close =
        new DateTime(now.year, now.month, now.day, close.hour, close.minute);
    DateTime open1 = dateFormat.parse(widget.food.fromtimeone);
    open1 =
        new DateTime(now.year, now.month, now.day, open1.hour, open1.minute);
    DateTime close1 = dateFormat.parse(widget.food.totimeone);
    close1 =
        new DateTime(now.year, now.month, now.day, close1.hour, close1.minute);
    DateTime open2 = dateFormat.parse(widget.food.fromtimetwo);
    open2 =
        new DateTime(now.year, now.month, now.day, open2.hour, open2.minute);
    DateTime close2 = dateFormat.parse(widget.food.totimetwo);
    close2 =
        new DateTime(now.year, now.month, now.day, close2.hour, close2.minute);
    var isDateInRange = isCurrentDateInRange(open, close);
    var isDateInRange1 = isCurrentDateInRange(open1, close1);
    var isDateInRange2 = isCurrentDateInRange(open2, close2);
    if (isDateInRange || isDateInRange1 || isDateInRange2) {
      setState(() {
        isopen = true;
      });
    }

    print("From time one");
    print(widget.food.fromtime);
    print(widget.food.totime);
    print(widget.food.fromtimeone);
    print(widget.food.fromtimetwo);
    print(widget.food.fromtimetwo);
    print(widget.food.totimetwo);
    print(isDateInRange1);
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  void setHotelID() async {
    final sharedPrefs = await _sharedPrefs;
    // int id;
    // id = int.tryParse(sharedPrefs.getString("spHotelID") ?? 0);
    // sharedPrefs.getString("spHotelID");
    setState(() {
      // hotelID = id;
      hotelID = sharedPrefs.getString("spHotelID");
    });
    // print("Hotel ID: $hotelID");
    // print("Hotel widget ID: ${widget.food.hotel.restID}");
    // print("test_data_index");
    // print(hps.a[widget.index]);
    //print("column : ${hps.a[widget.index]}");
    hps.setState(() {
      isload = false;
    });
    isSelect = sharedPrefs.containsKey("spHotelID") ? true : false;
  }

  void assignState() {
    setHotelID();
    timeSet();
    print("Hotel ID: $hotelID");
    print("Hotel widget ID: ${widget.food.hotel.restID}");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(widget.imgbase);
    print(hp.imgBaseUrl);
    return isload
        ? hp.getCardLoader(size, 5, 1)
        : Opacity(
            opacity: isopen ? 1 : 0.4,
            child: Card(
                color: isopen ? Colors.transparent : Colors.grey,
                margin: EdgeInsets.symmetric(
                    horizontal: width / 200, vertical: height / 128),
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.only(left: width / 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {},
                          child: (widget.imgbase == null ||
                                  hp.imgBaseUrl == null)
                              ? Image.asset("assets/images/noImage.png")
                              : ClipRRect(
                                  child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      height: height / 11.52921504606846976,
                                      width: width / 5.76460752303423488,
                                      imageUrl:
                                          widget.imgbase + widget.food.s3url,
                                      placeholder: hp.getPlaceHolder,
                                      errorWidget: hp.getErrorWidget),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(radius / 160)))),
                      SizedBox(width: width / 40),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width / 1.5,
                              child: Text(
                                widget.food.foodName,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              child: Row(
                                  children: [
                                    SizedBox(
                                      width: width / 1.8014398509481984,
                                      child: Text("₹ " + widget.food.price,
                                          style: TextStyle(
                                              color: Color(0xff110202),
                                              fontSize: 14)),
                                    ),
                                    // hotelID != widget.food.hotel.restID &&
                                    //         !isselect &&
                                    hotelID ==
                                                widget.food.hotel.restID
                                                    .toString() &&
                                            hps.a[widget.index] != 0
                                        ? Container(
                                            height: height / 32,
                                            width: width / 6.4,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Color(0xffa11414)),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        radius / 10))),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                    child: IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        splashRadius:
                                                            radius / 64,
                                                        icon: Icon(Icons.remove,
                                                            size: radius / 50,
                                                            color: Color(
                                                                0xffa11414)),
                                                        onPressed: () async {
                                                          if (isopen) {
                                                            if (hps.a[widget
                                                                        .index] >
                                                                    0 &&
                                                                hps.b[widget
                                                                        .index] >
                                                                    0.0)
                                                              hps.setState(() {
                                                                --hps.a[widget
                                                                    .index];
                                                                hps.b[widget
                                                                    .index] = hps
                                                                            .a[
                                                                        widget
                                                                            .index] *
                                                                    (double.tryParse(widget.food.price ??
                                                                            "0.0") ??
                                                                        0.0);
                                                              });
                                                            final sharedPrefs =
                                                                await _sharedPrefs;
                                                            Cart cart = Cart.fromMap(sharedPrefs
                                                                    .containsKey(
                                                                        "cartData")
                                                                ? json.decode(
                                                                    sharedPrefs
                                                                        .getString(
                                                                            "cartData"))
                                                                : hps.cartData);
                                                            OrderedFood pcp;
                                                            for (OrderedFood cp
                                                                in cart.foods) {
                                                              if (cp.foodID ==
                                                                  widget.food
                                                                      .foodID) {
                                                                pcp = cp;
                                                                break;
                                                              }
                                                            }
                                                            if (pcp != null &&
                                                                (pcp.quantity >
                                                                    0)) {
                                                              if (pcp.quantity ==
                                                                  1) {
                                                                final p = hps.c
                                                                    .remove(widget
                                                                        .index);
                                                                final q = cart
                                                                    .foods
                                                                    .remove(
                                                                        pcp);
                                                                if (p && q)
                                                                  print(cart
                                                                      .json);
                                                              } else
                                                                pcp.quantity -=
                                                                    1;
                                                            }
                                                            if (cart.foods
                                                                .isEmpty) {
                                                              final p =
                                                                  await sharedPrefs
                                                                      .remove(
                                                                          "cartData");
                                                              final q =
                                                                  await sharedPrefs
                                                                      .remove(
                                                                          "itemCount");
                                                              final r =
                                                                  await sharedPrefs
                                                                      .remove(
                                                                          "itemPrice");
                                                              final s =
                                                                  await sharedPrefs
                                                                      .remove(
                                                                          "spHotelID");
                                                              final t =
                                                                  await sharedPrefs
                                                                      .remove(
                                                                          "items");
                                                              if (p &&
                                                                  q &&
                                                                  r &&
                                                                  s &&
                                                                  t)
                                                                print(
                                                                    cart.json);
                                                            } else {
                                                              final p = await sharedPrefs
                                                                  .setString(
                                                                      "cartData",
                                                                      json.encode(
                                                                          cart.json));
                                                              final q = await sharedPrefs
                                                                  .setString(
                                                                      "itemCount",
                                                                      json.encode(
                                                                          hps.a));
                                                              final r = await sharedPrefs
                                                                  .setString(
                                                                      "itemPrice",
                                                                      json.encode(
                                                                          hps.b));
                                                              final s = await sharedPrefs
                                                                  .setString(
                                                                      "items",
                                                                      json.encode(
                                                                          hps.c));
                                                              if (p &&
                                                                  q &&
                                                                  r &&
                                                                  s)
                                                                hps.setState(() => hps
                                                                        .cartData =
                                                                    json.decode(
                                                                        sharedPrefs
                                                                            .getString("cartData")));
                                                            }
                                                          }
                                                        })),
                                                Text(
                                                    hps.a[widget.index]
                                                        .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xffA11414))),
                                                Flexible(
                                                    child: IconButton(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        splashRadius:
                                                            radius / 64,
                                                        icon: Icon(Icons.add,
                                                            size: radius / 50,
                                                            color: Color(
                                                                0xffa11414)),
                                                        onPressed: () async {
                                                          if (isopen) {
                                                            hps.setState(() {
                                                              ++hps.a[
                                                                  widget.index];
                                                              hps.b[widget
                                                                  .index] = hps
                                                                          .a[
                                                                      widget
                                                                          .index] *
                                                                  (double.tryParse(widget
                                                                              .food
                                                                              .price ??
                                                                          "0.0") ??
                                                                      0.0);
                                                            });
                                                            final sharedPrefs =
                                                                await _sharedPrefs;
                                                            Cart cart = Cart.fromMap(sharedPrefs
                                                                    .containsKey(
                                                                        "cartData")
                                                                ? json.decode(
                                                                    sharedPrefs
                                                                        .getString(
                                                                            "cartData"))
                                                                : hps.cartData);
                                                            OrderedFood pcp;
                                                            for (OrderedFood cp
                                                                in cart.foods)
                                                              if (cp.foodID ==
                                                                  widget.food
                                                                      .foodID) {
                                                                pcp = cp;
                                                                break;
                                                              }
                                                            if (pcp == null)
                                                              cart.foods.add(
                                                                  OrderedFood
                                                                      .fromMap({
                                                                "food_id":
                                                                    widget.food
                                                                        .foodID,
                                                                "quantity":
                                                                    hps.a[widget
                                                                        .index],
                                                                "name": widget
                                                                    .food
                                                                    .foodName,
                                                                "price": widget
                                                                    .food.price
                                                              }));
                                                            else
                                                              pcp.quantity += 1;
                                                            final p = await sharedPrefs
                                                                .setString(
                                                                    "cartData",
                                                                    json.encode(
                                                                        cart.json));
                                                            final q = await sharedPrefs
                                                                .setString(
                                                                    "itemCount",
                                                                    json.encode(
                                                                        hps.a));
                                                            final r = await sharedPrefs
                                                                .setString(
                                                                    "itemPrice",
                                                                    json.encode(
                                                                        hps.b));
                                                            if (p && q && r)
                                                              hps.setState(() => hps
                                                                      .cartData =
                                                                  json.decode(sharedPrefs
                                                                      .getString(
                                                                          "cartData")));
                                                          }
                                                        }))
                                              ],
                                            ),
                                          )
                                        : hotelID !=
                                                widget.food.hotel.restID
                                                    .toString()
                                            ? OutlinedButton(
                                                onPressed: () async {
                                                  if (isopen) {
                                                    final sharedPrefs =
                                                        await _sharedPrefs;
                                                    if (!sharedPrefs
                                                            .containsKey(
                                                                "spHotelID") ||
                                                        ((int.tryParse(sharedPrefs
                                                                        .getString(
                                                                            "spHotelID") ??
                                                                    "-1") ??
                                                                -1) ==
                                                            widget.food.hotel
                                                                .restID)) {
                                                      hps.setState(() {
                                                        hps.c.add(widget.index);
                                                        ++hps.a[widget.index];
                                                        hps.b[widget
                                                            .index] = hps.a[
                                                                widget.index] *
                                                            (double.tryParse(widget
                                                                        .food
                                                                        .price ??
                                                                    "0.0") ??
                                                                0.0);
                                                        hotelID = widget
                                                            .food.hotel.restID
                                                            .toString();
                                                      });

                                                      Cart cart = Cart.fromMap(
                                                          sharedPrefs
                                                                  .containsKey(
                                                                      "cartData")
                                                              ? json.decode(
                                                                  sharedPrefs
                                                                      .getString(
                                                                          "cartData"))
                                                              : hps.cartData);
                                                      if (cart != null &&
                                                          cart != Cart()) {
                                                        if (cart.foods.isEmpty)
                                                          cart.foods.add(
                                                              OrderedFood
                                                                  .fromMap({
                                                            "food_id": widget
                                                                .food.foodID,
                                                            "quantity": hps.a[
                                                                widget.index],
                                                            "name": widget
                                                                .food.foodName,
                                                            "price": widget
                                                                .food.price
                                                          }));
                                                        else {
                                                          OrderedFood of;
                                                          for (OrderedFood cartFood
                                                              in cart.foods)
                                                            if (widget.food
                                                                    .foodID ==
                                                                cartFood
                                                                    .foodID) {
                                                              of = cartFood;
                                                              break;
                                                            }
                                                          if (of == null)
                                                            cart.foods.add(
                                                                OrderedFood
                                                                    .fromMap({
                                                              "food_id": widget
                                                                  .food.foodID,
                                                              "quantity": hps.a[
                                                                  widget.index],
                                                              "name": widget
                                                                  .food
                                                                  .foodName,
                                                              "price": widget
                                                                  .food.price
                                                            }));
                                                          else
                                                            of.quantity += 1;
                                                        }
                                                      } else
                                                        cart = Cart.fromMap({
                                                          "user_id": int.tryParse(
                                                                  sharedPrefs.getString(
                                                                          "spCustomerID") ??
                                                                      "-1") ??
                                                              -1,
                                                          "restaurant_id":
                                                              widget.food.hotel
                                                                  .restID,
                                                          "delivery_address_id":
                                                              3,
                                                          "order_status_id": 1,
                                                          "tax": "10",
                                                          "delivery_fee": "0",
                                                          "foods": [
                                                            {
                                                              "food_id": widget
                                                                  .food.foodID,
                                                              "quantity": hps.a[
                                                                  widget.index],
                                                              "name": widget
                                                                  .food
                                                                  .foodName,
                                                              "price": widget
                                                                  .food.price
                                                            }
                                                          ]
                                                        });
                                                      final p = await sharedPrefs
                                                          .setString(
                                                              "cartData",
                                                              json.encode(
                                                                  cart.json));
                                                      final q =
                                                          await sharedPrefs
                                                              .setString(
                                                                  "itemCount",
                                                                  json.encode(
                                                                      hps.a));
                                                      final r =
                                                          await sharedPrefs
                                                              .setString(
                                                                  "itemPrice",
                                                                  json.encode(
                                                                      hps.b));
                                                      final s = await sharedPrefs
                                                          .setString(
                                                              "spHotelID",
                                                              widget.food.hotel
                                                                  .restID
                                                                  .toString());
                                                      final t =
                                                          await sharedPrefs
                                                              .setString(
                                                                  "items",
                                                                  json.encode(
                                                                      hps.c));
                                                      if (p && q && r && s && t)
                                                        hps.setState(() => hps
                                                                .cartData =
                                                            json.decode(sharedPrefs
                                                                .getString(
                                                                    "cartData")));
                                                    } else
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "You Have Cart Products from another Hotel. Either Remove them or Check them Out please and try again !!!!",
                                                          gravity: ToastGravity
                                                              .BOTTOM);
                                                  }
                                                },
                                                child: Text(hp.loc.add_to_cart,
                                                    style: TextStyle(
                                                        // fontWeight: FontWeight.w500,
                                                        fontSize: 12)),
                                                style: ButtonStyle(
                                                    minimumSize:
                                                        MaterialStateProperty.all(
                                                            Size.square(
                                                                radius / 40)),
                                                    shape: MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(
                                                                Radius.circular(
                                                                    radius / 50)))),
                                                    side: MaterialStateProperty.all(BorderSide(color: Color(0xffa11414))),
                                                    foregroundColor: MaterialStateProperty.all(Color(0xffa11414))))
                                            : hps.a[widget.index] == 0
                                                ? OutlinedButton(
                                                    onPressed: () async {
                                                      if (isopen) {
                                                        final sharedPrefs =
                                                            await _sharedPrefs;
                                                        if (!sharedPrefs
                                                                .containsKey(
                                                                    "spHotelID") ||
                                                            ((int.tryParse(sharedPrefs.getString(
                                                                            "spHotelID") ??
                                                                        "-1") ??
                                                                    -1) ==
                                                                widget
                                                                    .food
                                                                    .hotel
                                                                    .restID)) {
                                                          hps.setState(() {
                                                            hps.c.add(
                                                                widget.index);
                                                            ++hps.a[
                                                                widget.index];
                                                            hps.b[widget
                                                                .index] = hps.a[
                                                                    widget
                                                                        .index] *
                                                                (double.tryParse(widget
                                                                            .food
                                                                            .price ??
                                                                        "0.0") ??
                                                                    0.0);
                                                          });
                                                          Cart cart = Cart.fromMap(sharedPrefs
                                                                  .containsKey(
                                                                      "cartData")
                                                              ? json.decode(
                                                                  sharedPrefs
                                                                      .getString(
                                                                          "cartData"))
                                                              : hps.cartData);
                                                          if (cart != null &&
                                                              cart != Cart()) {
                                                            if (cart
                                                                .foods.isEmpty)
                                                              cart.foods.add(
                                                                  OrderedFood
                                                                      .fromMap({
                                                                "food_id":
                                                                    widget.food
                                                                        .foodID,
                                                                "quantity":
                                                                    hps.a[widget
                                                                        .index],
                                                                "name": widget
                                                                    .food
                                                                    .foodName,
                                                                "price": widget
                                                                    .food.price
                                                              }));
                                                            else {
                                                              OrderedFood of;
                                                              for (OrderedFood cartFood
                                                                  in cart.foods)
                                                                if (widget.food
                                                                        .foodID ==
                                                                    cartFood
                                                                        .foodID) {
                                                                  of = cartFood;
                                                                  break;
                                                                }
                                                              if (of == null)
                                                                cart.foods.add(
                                                                    OrderedFood
                                                                        .fromMap({
                                                                  "food_id":
                                                                      widget
                                                                          .food
                                                                          .foodID,
                                                                  "quantity": hps
                                                                          .a[
                                                                      widget
                                                                          .index],
                                                                  "name": widget
                                                                      .food
                                                                      .foodName,
                                                                  "price":
                                                                      widget
                                                                          .food
                                                                          .price
                                                                }));
                                                              else
                                                                of.quantity +=
                                                                    1;
                                                            }
                                                          } else
                                                            cart =
                                                                Cart.fromMap({
                                                              "user_id": int.tryParse(
                                                                      sharedPrefs
                                                                              .getString("spCustomerID") ??
                                                                          "-1") ??
                                                                  -1,
                                                              "restaurant_id":
                                                                  widget
                                                                      .food
                                                                      .hotel
                                                                      .restID,
                                                              "delivery_address_id":
                                                                  3,
                                                              "order_status_id":
                                                                  1,
                                                              "tax": "10",
                                                              "delivery_fee":
                                                                  "0",
                                                              "foods": [
                                                                {
                                                                  "food_id":
                                                                      widget
                                                                          .food
                                                                          .foodID,
                                                                  "quantity": hps
                                                                          .a[
                                                                      widget
                                                                          .index],
                                                                  "name": widget
                                                                      .food
                                                                      .foodName,
                                                                  "price":
                                                                      widget
                                                                          .food
                                                                          .price
                                                                }
                                                              ]
                                                            });
                                                          final p = await sharedPrefs
                                                              .setString(
                                                                  "cartData",
                                                                  json.encode(
                                                                      cart.json));
                                                          final q = await sharedPrefs
                                                              .setString(
                                                                  "itemCount",
                                                                  json.encode(
                                                                      hps.a));
                                                          final r = await sharedPrefs
                                                              .setString(
                                                                  "itemPrice",
                                                                  json.encode(
                                                                      hps.b));
                                                          final s = await sharedPrefs
                                                              .setString(
                                                                  "spHotelID",
                                                                  widget
                                                                      .food
                                                                      .hotel
                                                                      .restID
                                                                      .toString());
                                                          final t =
                                                              await sharedPrefs
                                                                  .setString(
                                                                      "items",
                                                                      json.encode(
                                                                          hps.c));
                                                          if (p &&
                                                              q &&
                                                              r &&
                                                              s &&
                                                              t) {
                                                            print(sharedPrefs
                                                                .getString(
                                                                    "cartData"));
                                                            hps.setState(() => hps
                                                                    .cartData =
                                                                json.decode(sharedPrefs
                                                                    .getString(
                                                                        "cartData")));
                                                          }
                                                        } else
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "You Have Cart Products from another Hotel. Either Remove them or Check them Out please and try again !!!!",
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM);
                                                      }
                                                    },
                                                    child: Text("ADD",
                                                        style: TextStyle(
                                                            // fontWeight: FontWeight.w500,
                                                            fontSize: 12)),
                                                    style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size.square(radius / 40)), shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius / 50)))), side: MaterialStateProperty.all(BorderSide(color: Color(0xffa11414))), foregroundColor: MaterialStateProperty.all(Color(0xffa11414))))
                                                : Container(
                                                    height: height / 32,
                                                    width: width / 6.4,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Color(
                                                                0xffa11414)),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    radius /
                                                                        10))),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Flexible(
                                                            child: IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                splashRadius:
                                                                    radius / 64,
                                                                icon: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size:
                                                                        radius /
                                                                            50,
                                                                    color: Color(
                                                                        0xffa11414)),
                                                                onPressed:
                                                                    () async {
                                                                  if (isopen) {
                                                                    if (hps.a[widget.index] >
                                                                            0 &&
                                                                        hps.b[widget.index] >
                                                                            0.0)
                                                                      hps.setState(
                                                                          () {
                                                                        --hps.a[
                                                                            widget.index];
                                                                        hps.b[widget
                                                                            .index] = hps.a[widget
                                                                                .index] *
                                                                            (double.tryParse(widget.food.price ?? "0.0") ??
                                                                                0.0);
                                                                      });
                                                                    final sharedPrefs =
                                                                        await _sharedPrefs;
                                                                    Cart cart = Cart.fromMap(sharedPrefs.containsKey(
                                                                            "cartData")
                                                                        ? json.decode(sharedPrefs.getString(
                                                                            "cartData"))
                                                                        : hps
                                                                            .cartData);
                                                                    OrderedFood
                                                                        pcp;
                                                                    for (OrderedFood cp
                                                                        in cart
                                                                            .foods) {
                                                                      if (cp.foodID ==
                                                                          widget
                                                                              .food
                                                                              .foodID) {
                                                                        pcp =
                                                                            cp;
                                                                        break;
                                                                      }
                                                                    }
                                                                    if (pcp !=
                                                                            null &&
                                                                        (pcp.quantity >
                                                                            0)) {
                                                                      if (pcp.quantity ==
                                                                          1) {
                                                                        final p = hps
                                                                            .c
                                                                            .remove(widget.index);
                                                                        final q = cart
                                                                            .foods
                                                                            .remove(pcp);
                                                                        if (p &&
                                                                            q)
                                                                          print(
                                                                              cart.json);
                                                                      } else
                                                                        pcp.quantity -=
                                                                            1;
                                                                    }
                                                                    if (cart
                                                                        .foods
                                                                        .isEmpty) {
                                                                      final p =
                                                                          await sharedPrefs
                                                                              .remove("cartData");
                                                                      final q =
                                                                          await sharedPrefs
                                                                              .remove("itemCount");
                                                                      final r =
                                                                          await sharedPrefs
                                                                              .remove("itemPrice");
                                                                      final s =
                                                                          await sharedPrefs
                                                                              .remove("spHotelID");
                                                                      final t =
                                                                          await sharedPrefs
                                                                              .remove("items");
                                                                      if (p &&
                                                                          q &&
                                                                          r &&
                                                                          s &&
                                                                          t)
                                                                        print(cart
                                                                            .json);
                                                                    } else {
                                                                      final p = await sharedPrefs.setString(
                                                                          "cartData",
                                                                          json.encode(
                                                                              cart.json));
                                                                      final q = await sharedPrefs.setString(
                                                                          "itemCount",
                                                                          json.encode(
                                                                              hps.a));
                                                                      final r = await sharedPrefs.setString(
                                                                          "itemPrice",
                                                                          json.encode(
                                                                              hps.b));
                                                                      final s = await sharedPrefs.setString(
                                                                          "items",
                                                                          json.encode(
                                                                              hps.c));
                                                                      if (p &&
                                                                          q &&
                                                                          r &&
                                                                          s)
                                                                        hps.setState(() =>
                                                                            hps.cartData =
                                                                                json.decode(sharedPrefs.getString("cartData")));
                                                                    }
                                                                  }
                                                                })),
                                                        Text(
                                                            hps.a[widget.index]
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffA11414))),
                                                        Flexible(
                                                            child: IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                splashRadius:
                                                                    radius / 64,
                                                                icon: Icon(
                                                                    Icons.add,
                                                                    size:
                                                                        radius /
                                                                            50,
                                                                    color: Color(
                                                                        0xffa11414)),
                                                                onPressed:
                                                                    () async {
                                                                  if (isopen) {
                                                                    hps.setState(
                                                                        () {
                                                                      ++hps.a[widget
                                                                          .index];
                                                                      hps.b[widget
                                                                          .index] = hps.a[widget
                                                                              .index] *
                                                                          (double.tryParse(widget.food.price ?? "0.0") ??
                                                                              0.0);
                                                                    });
                                                                    final sharedPrefs =
                                                                        await _sharedPrefs;
                                                                    Cart cart = Cart.fromMap(sharedPrefs.containsKey(
                                                                            "cartData")
                                                                        ? json.decode(sharedPrefs.getString(
                                                                            "cartData"))
                                                                        : hps
                                                                            .cartData);
                                                                    OrderedFood
                                                                        pcp;
                                                                    for (OrderedFood cp
                                                                        in cart
                                                                            .foods)
                                                                      if (cp.foodID ==
                                                                          widget
                                                                              .food
                                                                              .foodID) {
                                                                        pcp =
                                                                            cp;
                                                                        break;
                                                                      }
                                                                    if (pcp ==
                                                                        null)
                                                                      cart.foods.add(
                                                                          OrderedFood
                                                                              .fromMap({
                                                                        "food_id": widget
                                                                            .food
                                                                            .foodID,
                                                                        "quantity":
                                                                            hps.a[widget.index],
                                                                        "name": widget
                                                                            .food
                                                                            .foodName,
                                                                        "price": widget
                                                                            .food
                                                                            .price
                                                                      }));
                                                                    else
                                                                      pcp.quantity +=
                                                                          1;
                                                                    final p = await sharedPrefs.setString(
                                                                        "cartData",
                                                                        json.encode(
                                                                            cart.json));
                                                                    final q = await sharedPrefs.setString(
                                                                        "itemCount",
                                                                        json.encode(
                                                                            hps.a));
                                                                    final r = await sharedPrefs.setString(
                                                                        "itemPrice",
                                                                        json.encode(
                                                                            hps.b));
                                                                    if (p &&
                                                                        q &&
                                                                        r)
                                                                      hps.setState(() => hps
                                                                              .cartData =
                                                                          json.decode(
                                                                              sharedPrefs.getString("cartData")));
                                                                  }
                                                                }))
                                                      ],
                                                    ),
                                                  )
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween),
                              height: height / 20,
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween)
                    ],
                  ),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(radius / 9))),
                )),
          );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, assignState);
  }
}
