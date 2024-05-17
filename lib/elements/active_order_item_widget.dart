import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'active_orders_list_widget.dart';

class ActiveOrderItemWidget extends StatefulWidget {
  final Order order;
  ActiveOrderItemWidget({Key key, @required this.order}) : super(key: key);
  @override
  ActiveOrderItemWidgetState createState() => ActiveOrderItemWidgetState();

  static ActiveOrdersListWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<ActiveOrdersListWidgetState>();
}

class ActiveOrderItemWidgetState extends StateMVC<ActiveOrderItemWidget> {
  bool showBill = false;
  HotelController con;
  String imgBase;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  ActiveOrdersListWidgetState get acwS => ActiveOrderItemWidget.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  ActiveOrderItemWidgetState() : super(HotelController()) {
    con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    await con.waitForDriverDetails(widget.order.driverID);
    await con.waitForHotelData(widget.order.hotelID);
    await con.waitForOrderedFood(widget.order.orderID);
    setState(() {
      imgBase = sharedPrefs.getString("imgBase");
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        margin:
            EdgeInsets.symmetric(horizontal: width / 32, vertical: height / 40),
        child: Column(children: [
          InkWell(
              child: Container(
                  //       margin: EdgeInsets.only(
                  // left: width / 20,
                  // right: width /
                  //     200,
                  // bottom: height / 160,
                  // top: height / 32),
                  child: Row(children: [
                    Container(
                        margin: EdgeInsets.only(right: width / 50),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(radius / 160),
                            image: DecorationImage(
                                image: con.hotel == null
                                    ? AssetImage("assets/images/loading.gif")
                                    : (con.hotel.sthreeurl == "" ||
                                            imgBase == null
                                        ? AssetImage(
                                            "assets/images/noImage.png")
                                        : NetworkImageWithRetry(
                                            imgBase + con.hotel.sthreeurl)),
                                fit: BoxFit.fill)),
                        width: width / 5,
                        height: height / 10),
                    Expanded(
                        child: Column(
                            children: [
                          Row(
                            children: [
                              FittedBox(
                                child: Container(
                                  width: width / 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        con.hotel == null
                                            ? ""
                                            : (con.hotel.restName ?? ""),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                          widget.order.orderID == null
                                              ? ""
                                              : ("#Order ID : ${widget.order.orderID.toString()}" ??
                                                  ""),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700))
                                    ],
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: width,
                              // ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      String str = widget.order.orderStatus;
                                      print(str.length);
                                      print(str);
                                    },
                                    child: Container(
                                      width: width / 3,
                                      child: Center(
                                        child: Text(
                                          // "Restaurant Accepted",
                                          widget.order.orderStatus.isEmpty
                                              ? "Ongoing"
                                              : widget.order.orderStatus,
                                          maxLines: 2,
                                          style: TextStyle(color: Colors.white),
                                          //overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.horizontal(
                                              left: Radius.circular(
                                                  radius / 160)),
                                          color: Color(0xffBAD600)),
                                      padding: const EdgeInsets.all(5),
                                      // padding: EdgeInsets.symmetric(
                                      //     horizontal: width / 30,
                                      //     vertical: height / 500)
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  widget.order.orderStatusID != 1
                                      ? Container()
                                      : InkWell(
                                          onTap: () async {
                                            final sharedPrefs =
                                                await _sharedPrefs;
                                            hp.showDialogBox(
                                                "Cancel this order",
                                                ["No", "Yes"],
                                                [
                                                  () {
                                                    Navigator.pop(context);
                                                  },
                                                  () {
                                                    con.waitForCancelOrders(
                                                        int.tryParse(sharedPrefs
                                                                    .getString(
                                                                        "spCustomerID") ??
                                                                "-1") ??
                                                            -1,
                                                        widget.order.orderID);
                                                  }
                                                ],
                                                size);
                                          },
                                          child: Container(
                                              child: Text("CANCEL",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.horizontal(
                                                          left: Radius.circular(
                                                              radius / 160)),
                                                  color: Color(0xffA11414)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: width / 32,
                                                  vertical: height / 100)),
                                        ),
                                ],
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          SizedBox(height: height / 40),
                          Row(children: [
                            Expanded(
                                child: Row(children: [
                              Icon(Icons.circle,
                                  size: 10, color: Color(0xffBAD600)),
                              SizedBox(
                                width: width / 80,
                              ),
                              Text(
                                  "Order Total : " +
                                      (widget.order.total.isEmpty
                                          ? Helper.getTotalOrderPrice(
                                                  con.orderedFoods)
                                              .toString()
                                          : widget.order.total),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.52921504606846976))
                            ], mainAxisAlignment: MainAxisAlignment.start)),
                            // SizedBox(width: width / 25),
                            Expanded(
                                child: Row(children: [
                              Icon(Icons.circle,
                                  size: 10, color: Color(0xffBAD600)),
                              SizedBox(
                                width: width / 80,
                              ),
                              Text(
                                  "Distance: " +
                                      (widget.order.driverLoc.latitude == 0.0 &&
                                                  widget.order.driverLoc
                                                          .longitude ==
                                                      0.0
                                              ? hp.distanceInKM(
                                                  widget.order.hotelLoc,
                                                  widget.order.customerLoc)
                                              : (hp.distanceInKM(
                                                      widget.order.driverLoc,
                                                      widget.order.hotelLoc) +
                                                  hp.distanceInKM(
                                                      widget.order.hotelLoc,
                                                      widget
                                                          .order.customerLoc)))
                                          .ceil()
                                          .toString() +
                                      " Kms",
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(color: Colors.black))
                            ], mainAxisAlignment: MainAxisAlignment.start)),
                            // SizedBox(width: width / 50)
                          ], mainAxisAlignment: MainAxisAlignment.spaceAround)
                        ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start))
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  padding: EdgeInsets.only(
                      left: width / 40,
                      top: height / 100,
                      bottom: height / 100),
                  decoration: BoxDecoration(
                      color: Color(0xffF6F6F6),
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(radius / 160)))),
              onTap: () async {
                //   final p = await Navigator.pushNamed(context, '/trackOrder',
                //       arguments: widget.order);
                //   print(p);
              }),
          Container(
              child: Row(children: [
                InkWell(
                  child: Row(children: [
                    Icon(Icons.call, color: Colors.white, size: 16),
                    Text("CALL",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 11.52921504606846976))
                  ], mainAxisAlignment: MainAxisAlignment.start),
                  onTap: () async {
                    final p = await launch("tel://" + con.hotel.phone);
                    if (p) print("Hi");
                  },
                ),
                widget.order.driverID == 0
                    ? InkWell(
                        // borderRadius:
                        // BorderRadius.all(
                        //     Radius.circular(
                        //         radius * 2)),
                        child: Row(children: [
                          Icon(
                            Icons.not_listed_location,
                            color: Colors.white,
                          ),
                          Container(
                            child: Text("Driver Not Assigned",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            padding: EdgeInsets.only(right: width / 40),
                          )
                        ], mainAxisAlignment: MainAxisAlignment.start),
                        onTap: () async {
                          print(widget.order.driverID);
                        })
                    : InkWell(
                        // borderRadius:
                        // BorderRadius.all(
                        //     Radius.circular(
                        //         radius * 2)),
                        child: Row(children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                          Container(
                            child: Text("TRACK ORDER",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            padding: EdgeInsets.only(right: width / 40),
                          )
                        ], mainAxisAlignment: MainAxisAlignment.start),
                        onTap: () async {
                          final p = await Navigator.pushNamed(
                              context, '/trackOrder',
                              arguments: widget.order);
                          print(p);
                        }),
                GestureDetector(
                  child: Text(
                    "VIEW BILLING",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 11.52921504606846976),
                  ),
                  onTap: () async {
                    final p = await Navigator.pushNamed(
                        context, '/orderDetails',
                        arguments: widget.order);
                    print(p);
                  },
                )
              ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
              padding: EdgeInsets.symmetric(horizontal: width / 40
                  // , vertical: height / 500
                  ),
              decoration: BoxDecoration(
                  color: Color(0xffA11414),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radius / 200))),
              height: height / 20)
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        elevation: 0,
        borderOnForeground: true);
  }
}
