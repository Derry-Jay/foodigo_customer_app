import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelDetailsPage extends StatefulWidget {
  final RouteArgument rar;
  HotelDetailsPage(this.rar);
  State<StatefulWidget> createState() => HotelDetailsPageState();
}

class HotelDetailsPageState extends StateMVC<HotelDetailsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int index = 0, searchMode = 0;
  HotelController con;
  bool flag;
  bool isloading = true;
  List<int> a = List.empty(growable: true), c = List.empty(growable: true);
  List<double> b = List.empty(growable: true);
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Map<String, dynamic> cartData, addressData;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  var imgbase;
  LatLng userloc;
  HotelDetailsPageState() : super(HotelController()) {
    con = controller;
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    hp.getConnectStatus();
    flag = sharedPrefs.containsKey("cartData");
    addressData = sharedPrefs.containsKey("defaultAddress")
        ? json.decode(sharedPrefs.getString("defaultAddress"))
        : Map<String, dynamic>();
    setState(() {
      imgbase = sharedPrefs.getString("imgBase");
      userloc = LatLng(addressData["latitude"], addressData["longitude"]);
    });
    // hp = Helper.of(context);

    cartData = flag
        ? (sharedPrefs.getString("cartData") == null ||
                sharedPrefs.getString("cartData") == ""
            ? {
                "user_id": int.tryParse(
                        sharedPrefs.getString("spCustomerID") ?? "14") ??
                    14,
                "restaurant_id": sharedPrefs.containsKey("spHotelID")
                    ? sharedPrefs.getString("spHotelID")
                    : widget.rar.param.restID,
                "delivery_address_id": addressData["addressID"],
                "order_status_id": 1,
                "tax": "10",
                "customer_lat": addressData == null || addressData.isEmpty
                    ? 0.0
                    : addressData["latitude"],
                "customer_lang": addressData == null || addressData.isEmpty
                    ? 0.0
                    : addressData["longitude"],
                "delivery_fee": widget.rar.param.deliveryFee.toString(),
                "foods": <Map<String, dynamic>>[]
              }
            : json.decode(sharedPrefs.getString("cartData")))
        : {
            "user_id":
                int.tryParse(sharedPrefs.getString("spCustomerID") ?? "14") ??
                    14,
            "restaurant_id": sharedPrefs.containsKey("spHotelID")
                ? sharedPrefs.getString("spHotelID")
                : widget.rar.param.restID,
            "delivery_address_id": addressData["addressID"],
            "order_status_id": 1,
            "tax": widget.rar.param.totalTax.toString(),
            "customer_lat": addressData == null || addressData.isEmpty
                ? 0.0
                : addressData["latitude"],
            "customer_lang": addressData == null || addressData.isEmpty
                ? 0.0
                : addressData["longitude"],
            "delivery_fee": widget.rar.param.deliveryFee.toString(),
            "foods": <Map<String, dynamic>>[]
          };
    int id = int.tryParse(widget.rar.id ?? "-1") ?? -1;
    hp.lockScreenRotation();
    await con.waitForHotelData(id);
    await con.waitForFoods1(widget.rar.param);
    await con.waitForMenu();
    pickData();

    setState(() {
      isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: con.hotel == null
          ? hp.getPageLoader(size)
          : SafeArea(
              child: Stack(
                //alignment: Alignment.bottomCenter,
                children: [
                  CachedNetworkImage(
                      fit: BoxFit.fill,
                      height: height / 2.8,
                      width: width,
                      imageUrl: imgbase + con.hotel.hotelBg,
                      placeholder: hp.getPlaceHolder,
                      errorWidget: hp.getErrorWidgetNoImage),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                          height: height / (searchMode == 0 ? 6.4 : 8),
                          child: searchMode == 0
                              ? IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  color: Colors.transparent)
                              : Container(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.all(10),
                                          prefixIcon: IconButton(
                                              icon: Icon(
                                                Icons.arrow_back_ios,
                                                size: 22,
                                              ),
                                              onPressed: () => setState(() =>
                                                  searchMode = searchMode - 1)),
                                          filled: true,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black12),
                                            borderRadius: BorderRadius.circular(
                                                radius / 100),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black12),
                                            borderRadius: BorderRadius.circular(
                                                radius / 100),
                                          ))),
                                  margin: EdgeInsets.only(
                                      top: height / 16,
                                      left: width / 40,
                                      right: width / 40,
                                      bottom: height / 400),
                                )),
                      Flexible(
                          child: Container(
                        // padding: EdgeInsets.only(
                        //   top: height / 80,
                        // ),
                        height: height / 1.6,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(radius / 50))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.only(bottom: height / 100),
                                child: Column(
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Row(
                                              children: [
                                                Container(
                                                  width: width / 1.3,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      print(cartData);
                                                      // print(
                                                      //     con.hotel.gstNum);
                                                    },
                                                    child: Text(
                                                      con.hotel.restName,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                    child: Visibility(
                                                        child: Container(
                                                            child: Text(
                                                                con.hotel
                                                                    .foodType
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            radius / 200)),
                                                                color: Color(0xffF6CC8C)),
                                                            padding: EdgeInsets.symmetric(vertical: height / 160, horizontal: width / 64),
                                                            margin: EdgeInsets.only(right: width / 20)),
                                                        visible: con.hotel.foodType != null && con.hotel.foodType != ""),
                                                    flex: 2)
                                                // Expanded(
                                                //     child: Row(
                                                //       children: [
                                                //         Expanded(
                                                //             child: IconButton(
                                                //           icon: Icon(Icons.search),
                                                //           onPressed: () => setState(() =>
                                                //               searchMode = searchMode == 1
                                                //                   ? searchMode - 1
                                                //                   : 1),
                                                //         )),
                                                //         Expanded(
                                                //             child: IconButton(
                                                //                 onPressed: () async {
                                                //                   print(a.indexWhere(
                                                //                       (element) =>
                                                //                           element != 0));
                                                //                 },
                                                //                 icon: Icon(Icons
                                                //                     .favorite_border)))
                                                //       ],
                                                //     ),
                                                //     flex: 2)
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween)),
                                      // Container(
                                      //   child: Row(
                                      //       children: [
                                      //         for (Cuisine i in con.hotel.cuisines)
                                      //           Row(
                                      //             children: [
                                      //               Icon(Icons.circle,
                                      //                   size: 10,
                                      //                   color: Colors.redAccent[700]),
                                      //               SizedBox(width: width / 64),
                                      //               Text(i.cuisineName,
                                      //                   style: TextStyle(
                                      //                       color: Colors.black))
                                      //             ],
                                      //           )
                                      //       ],
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.spaceBetween),
                                      // padding:
                                      //     EdgeInsets.only(bottom: height / 160),
                                      // ),
                                      Container(
                                        child: Text(
                                            "Approx cost for 2: ₹" +
                                                con.hotel.p42.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                        padding: EdgeInsets.only(
                                            bottom: height / 160,
                                            top: height / 256),
                                      ),
                                      Row(
                                          children: [
                                            Container(
                                              color: Colors.white,
                                              child: Row(
                                                  children: [
                                                    Image.asset(
                                                        "assets/images/star.png",
                                                        fit: BoxFit.fill,
                                                        height: height / 64,
                                                        width: width / 32),
                                                    SizedBox(
                                                      width: width / 50,
                                                    ),
                                                    Text(
                                                        con.hotel.rating + ".0",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 14))
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween),
                                              padding: EdgeInsets.only(
                                                  bottom: height / 200),
                                            ),
                                            SizedBox(width: width / 32),
                                            Text("100+ ratings",
                                                style: TextStyle(
                                                    color: Color(0xff1d1707)
                                                    // , fontWeight:
                                                    // FontWeight.w600
                                                    ))
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start),
                                      Row(
                                          children: [
                                            Text(con.hotel.location,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            SizedBox(
                                                width: width *
                                                    con.hotel.location.length /
                                                    80),
                                            Row(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.pink[50],
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                "assets/images/stopwatch.png"))),
                                                    height: height / 40,
                                                    width: width / 20),
                                                SizedBox(width: width / 50),
                                                Text(
                                                    Helper.timecheck(
                                                            con.hotel
                                                                .deliveryTime,
                                                            userloc,
                                                            con.hotel
                                                                .coordinates)
                                                        .toString(),
                                                    // Helper.timeDiff(con
                                                    //     .hotel.deliveryTime),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600))
                                              ],
                                            )
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.start)
                                    ],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start),
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / 32)),
                            isloading
                                ? hp.getCardLoader(dimensions.size, 2.097152, 1)
                                : con.foods.length == 0
                                    ? Center(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20.0),
                                          child: Image.asset(
                                            "assets/images/Empty1.png",
                                            height: height / 8,
                                            width: width / 4,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      )
                                    : hp.getHotelMenu(con.foods, con.menu, a, b,
                                        dimensions, con)
                          ],
                        ),
                      )),
                    ],
                  ),
                  Visibility(
                      child: GestureDetector(
                          onTap: () async {
                            final sharedPrefs = await _sharedPrefs;
                            hp.navigateTo('/cart',
                                arguments: RouteArgument(
                                    id: sharedPrefs.containsKey("itemPrice")
                                        ? sharedPrefs.getString("itemPrice")
                                        : "",
                                    heroTag:
                                        sharedPrefs.containsKey("itemCount")
                                            ? sharedPrefs.getString("cartData")
                                            : "",
                                    param: sharedPrefs.containsKey("cartData")
                                        ? json.decode(
                                            sharedPrefs.getString("cartData"))
                                        : cartData),
                                onGoBack: onGoBack);
                          },
                          child: Card(
                              color: Color(0xffa11414),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(radius / 100))),
                              margin: EdgeInsets.only(top: height / 1.095),
                              // 1.073741824
                              child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                            child: Column(
                                                children: [
                                                  Text(
                                                      hp
                                                              .getSumOfNumList(
                                                                  a)
                                                              .toString() +
                                                          " Item" +
                                                          (hp.getSumOfNumList(
                                                                      a) !=
                                                                  1
                                                              ? "s"
                                                              : ""),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  Text(
                                                      "₹ " +
                                                          hp
                                                              .getSumOfNumList(
                                                                  b)
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600))
                                                ],
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround),
                                            padding: EdgeInsets.only(
                                                left: width / 20))),
                                    Expanded(
                                        child: Row(
                                            children: [
                                          Text("VIEW CART",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600)),
                                          SizedBox(width: width / 40),
                                          Image.asset("assets/images/cart2.png",
                                              fit: BoxFit.fill,
                                              height: height / 32,
                                              width: width / 20),
                                          SizedBox(width: width / 20)
                                        ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.end))
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween))),
                      visible: !hp.hasOnlyZeroes(a))
                ],
              ),
            ),
      // bottomNavigationBar: Visibility(
      //     child: GestureDetector(
      //         onTap: () async {
      //           final sharedPrefs = await _sharedPrefs;
      //           hp.navigateTo(
      //               '/cart',
      //               RouteArgument(
      //                   id: sharedPrefs.containsKey("itemPrice")
      //                       ? sharedPrefs.getString("itemPrice")
      //                       : "",
      //                   heroTag: sharedPrefs.containsKey("itemCount")
      //                       ? sharedPrefs.getString("cartData")
      //                       : "",
      //                   param: sharedPrefs.containsKey("cartData")
      //                       ? json.decode(sharedPrefs.getString("cartData"))
      //                       : cartData),
      //               onGoBack);
      //         },
      //         child: Card(
      //             color: Color(0xffa11414),
      //             shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.vertical(
      //                     top: Radius.circular(radius / 100))),
      //             margin: EdgeInsets.only(top: height / 1.095),
      //             // 1.073741824
      //             child: Row(children: [
      //               Expanded(
      //                   child: Container(
      //                       child: Column(
      //                           children: [
      //                             Text(
      //                                 hp.getSumOfIntList(a).toString() +
      //                                     " Item" +
      //                                     (hp.getSumOfIntList(a) != 1
      //                                         ? "s"
      //                                         : ""),
      //                                 style: TextStyle(
      //                                     color: Colors.white,
      //                                     fontWeight: FontWeight.w600)),
      //                             Text(
      //                                 "₹ " +
      //                                     hp.getSumOfDoubleList(b).toString(),
      //                                 style: TextStyle(
      //                                     color: Colors.white,
      //                                     fontWeight: FontWeight.w600))
      //                           ],
      //                           crossAxisAlignment: CrossAxisAlignment.start,
      //                           mainAxisAlignment:
      //                               MainAxisAlignment.spaceAround),
      //                       padding: EdgeInsets.only(left: width / 20))),
      //               Expanded(
      //                   child: Row(children: [
      //                 Text("VIEW CART",
      //                     style: TextStyle(
      //                         color: Colors.white,
      //                         fontWeight: FontWeight.w600)),
      //                 SizedBox(width: width / 40),
      //                 Image.asset("assets/images/cart2.png",
      //                     fit: BoxFit.fill,
      //                     height: height / 32,
      //                     width: width / 20),
      //                 SizedBox(width: width / 20)
      //               ], mainAxisAlignment: MainAxisAlignment.end))
      //             ], mainAxisAlignment: MainAxisAlignment.spaceBetween))),
      //     visible: !hp.hasOnlyZeroes(a)),
    );
  }

  FutureOr onGoBack(dynamic value) async {
    final sharedPrefs = await _sharedPrefs;
    final f1 = sharedPrefs.containsKey("itemCount");
    final f2 = sharedPrefs.containsKey("itemPrice");
    final f3 = sharedPrefs.containsKey("items");
    final f4 = sharedPrefs.containsKey("cartData");
    addressData = sharedPrefs.containsKey("defaultAddress")
        ? json.decode(sharedPrefs.getString("defaultAddress"))
        : Map<String, dynamic>();
    setState(() {
      a = f1
          ? List.from(json.decode(sharedPrefs.getString("itemCount")))
              .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
              .toList()
          : List.filled(con.foods.length, 0);
      b = f2
          ? List.from(json.decode(sharedPrefs.getString("itemPrice")))
              .map((e) => double.tryParse(e.toString() ?? "0.0") ?? 0.0)
              .toList()
          : List.filled(con.foods.length, 0.0);
      c = f3
          ? List.from(json.decode(sharedPrefs.getString("items")))
              .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
              .toList()
          : List.empty(growable: true);
      cartData = f4
          ? json.decode(sharedPrefs.getString("cartData"))
          : {
              "user_id":
                  int.tryParse(sharedPrefs.getString("spCustomerID")) ?? -1,
              "restaurant_id": int.tryParse(value) ?? -1,
              "delivery_address_id": addressData["addressID"],
              "order_status_id": 1,
              "tax": "",
              "delivery_fee": "",
              "customer_lat": addressData == null || addressData.isEmpty
                  ? 0.0
                  : addressData["latitude"],
              "customer_lang": addressData == null || addressData.isEmpty
                  ? 0.0
                  : addressData["longitude"],
              "foods": []
            };
    });
    print("****");
    print(f1);
    print(f2);
    print(f3);
    print(f4);
    print(value);
    print(cartData);
  }

  void pickData() async {
    final sharedPrefs = await _sharedPrefs;
    final f1 = sharedPrefs.containsKey("itemCount");
    final f2 = sharedPrefs.containsKey("itemPrice");
    final f3 = sharedPrefs.containsKey("items");
    //if (con.menu.isEmpty) con.waitForMenu();
    print("hitting");
    print(a);
    print(b);
    print(c);
    if (a.isEmpty && b.isEmpty && c.isEmpty)
      setState(() {
        a = f1
            ? List.from(json.decode(sharedPrefs.getString("itemCount")))
                .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
                .toList()
            : List.filled(con.foods.length, 0, growable: true);
        b = f2
            ? List.from(json.decode(sharedPrefs.getString("itemPrice")))
                .map((e) => double.tryParse(e.toString() ?? "0.0") ?? 0.0)
                .toList()
            : List.filled(con.foods.length, 0.0, growable: true);
        c = f3
            ? List.from(json.decode(sharedPrefs.getString("items")))
                .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
                .toList()
            : List.empty(growable: true);
      });
    else if (a.isEmpty)
      setState(() => a = f1
          ? List.from(json.decode(sharedPrefs.getString("itemCount")))
              .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
              .toList()
          : List.filled(con.foods.length, 0, growable: true));
    else if (b.isEmpty)
      setState(() => b = f2
          ? List.from(json.decode(sharedPrefs.getString("itemPrice")))
              .map((e) => double.tryParse(e.toString() ?? "0.0") ?? 0.0)
              .toList()
          : List.filled(con.foods.length, 0.0, growable: true));
    else if (c.isEmpty && f3)
      setState(() => c = List.from(json.decode(sharedPrefs.getString("items")))
          .map((e) => int.tryParse(e.toString() ?? "0") ?? 0)
          .toList());
    else {
      print("========");
      print(cartData);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    hp.rollbackOrientations();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
