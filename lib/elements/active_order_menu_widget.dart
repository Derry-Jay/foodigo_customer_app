import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:foodigo_customer_app/models/restaurant.dart';

class ActiveOrderBillingWidget extends StatefulWidget {
  final Order order;
  ActiveOrderBillingWidget({Key key, @required this.order}) : super(key: key);

  @override
  ActiveOrderBillingWidgetState createState() =>
      ActiveOrderBillingWidgetState();
}

class ActiveOrderBillingWidgetState extends StateMVC<ActiveOrderBillingWidget> {
  HotelController con;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get width => size.width;
  double get height => size.height;
  double get pixelRatio => dimensions.devicePixelRatio;
  double get textScaleFactor => dimensions.textScaleFactor;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  ActiveOrderBillingWidgetState() : super(HotelController()) {
    con = controller;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(widget.order.total);
    return GestureDetector(
        child: Card(
            color: Color(0xffF6F6F6),
            elevation: 0,
            child: Container(
                child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          print(widget.order.couponamount);
                        },
                        child: Text(
                            "Order ID: #" + widget.order.orderID.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                      ),
                      Flexible(
                          child: Row(
                              children: [
                            Container(
                              width: width / 1.5,
                              child: Text(
                                (con.hotel == null
                                    ? ""
                                    : (con.hotel.restName ?? "")),
                                style: TextStyle(
                                    color: Color(0xff181c02),
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                                (con.hotel == null
                                    ? ""
                                    : (con.hotel.location ?? "")),
                                style: TextStyle(
                                    color: Color(0xff181c02),
                                    fontWeight: FontWeight.w500))
                          ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start)),
                      Divider(
                          height: 0,
                          color: Color(0xffE2E0E0),
                          indent: 1,
                          endIndent: 1),
                      con.orderedFoods == null
                          ? hp.getCardLoader(size, 6.4, 1)
                          : hp.getOrderedFoodList(con.orderedFoods, size),
                      Divider(),
                      Column(
                        children: [
                          widget.order.tax.isEmpty
                              ? Container()
                              : Row(
                                  children: [
                                      Text("TAX",
                                          style: TextStyle(
                                              color: Color(0xff181c02),
                                              fontWeight: FontWeight.w500)),
                                      Text("₹ " + widget.order.tax.toString(),
                                          style: TextStyle(
                                              color: Color(0xff181c02),
                                              fontWeight: FontWeight.w500))
                                    ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                              children: [
                                Text("Delivery Fee",
                                    style: TextStyle(
                                        color: Color(0xff181c02),
                                        fontWeight: FontWeight.w500)),
                                Text("₹ " + widget.order.deliveryFee.toString(),
                                    style: TextStyle(
                                        color: Color(0xff181c02),
                                        fontWeight: FontWeight.w500))
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start),
                          SizedBox(
                            height: widget.order.couponamount == "" ? 0 : 5.0,
                          ),
                          widget.order.couponamount == ""
                              ? Container()
                              : Row(
                                  children: [
                                      Text("Coupon Amount",
                                          style: TextStyle(
                                              color: Color(0xff181c02),
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                          "₹  - " +
                                              widget.order.couponamount
                                                  .toString(),
                                          style: TextStyle(
                                              color: Color(0xff181c02),
                                              fontWeight: FontWeight.w500))
                                    ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                              children: [
                                Text("Payment Method",
                                    style: TextStyle(
                                        color: Color(0xff181c02),
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    widget.order.payMethod == "cash"
                                        ? "COD"
                                        : "Online",
                                    style: TextStyle(
                                        color: Color(0xff181c02),
                                        fontWeight: FontWeight.w500))
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start),
                          SizedBox(
                            height: widget.order.hint == "null" ? 0 : 5.0,
                          ),
                          widget.order.hint == "null"
                              ? Container()
                              : Row(
                                  children: [
                                      Text("Note",
                                          style: TextStyle(
                                              color: Color(0xff181c02),
                                              fontWeight: FontWeight.w500)),
                                      Text(widget.order.hint.toString(),
                                          style: TextStyle(
                                              color: Color(0xff181c02),
                                              fontWeight: FontWeight.w500))
                                    ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start),
                        ],
                      ),
                      DottedLine(dashColor: Color(0xffE2E0E0)),
                      Flexible(
                          child: Row(
                              children: [
                            Text("GRAND TOTAL",
                                style: TextStyle(
                                    color: Color(0xff181c02),
                                    fontWeight: FontWeight.w600)),
                            Text("₹ " + widget.order.total,
                                //  +
                                //     (widget.order.total.isEmpty
                                //         ? (Helper.getTotalOrderPrice(
                                //                     con.orderedFood) +
                                //                 (double.tryParse(
                                //                         widget.order.tax ??
                                //                             "0.0") ??
                                //                     0.0))
                                //             .toString()
                                //         : widget.order.total),
                                style: TextStyle(
                                    color: Color(0xff181c02),
                                    fontWeight: FontWeight.w600))
                          ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end))
                    ],
                    // shrinkWrap: true,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround),
                //height: height,
                padding: EdgeInsets.symmetric(
                    horizontal: width / 25, vertical: height / 128)),
            margin: EdgeInsets.symmetric(
                horizontal: width / 20, vertical: height / 80)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    con.waitForHotelData(widget.order.hotelID);
    con.waitForOrderedFood(widget.order.orderID);
  }
}
