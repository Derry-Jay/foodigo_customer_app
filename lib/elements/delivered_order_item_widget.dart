import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'driver_rating_popup.dart';

class DeliveredOrderItemWidget extends StatefulWidget {
  final Order order;
  DeliveredOrderItemWidget({Key key, @required this.order}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DeliveredOrderItemWidgetState();
}

class DeliveredOrderItemWidgetState extends StateMVC<DeliveredOrderItemWidget> {
  HotelController con;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  DeliveredOrderItemWidgetState() : super(HotelController()) {
    con = controller;
  }

  void getData() async {
    await con.waitForHotelData(widget.order.hotelID);
    await con.waitForOrderedFood(widget.order.orderID);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(widget.order.orderID);
    return Card(
        child: Container(
          child: Column(children: <Widget>[
            Container(
                child: Column(
                    children: [
                      Row(children: [
                        Container(
                            child: Row(
                                children: [
                                  Container(
                                    width: width / 2.5,
                                    child: Text(
                                      con.hotel == null
                                          ? ""
                                          : (con.hotel.restName ?? ""),
                                      style: TextStyle(
                                          color: Color(0xff181c02),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: width / 50),
                                  Text(
                                      "(" +
                                          (con.hotel == null
                                              ? ""
                                              : (con.hotel.location ?? "")) +
                                          ")",
                                      style: TextStyle(
                                          color: Color(0xff181c02), fontSize: 10
                                          // , fontWeight: FontWeight.bold
                                          ))
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween),
                            margin: EdgeInsets.only(top: height / 200)),
                        Container(
                            // width: width / 2
                            // height: 200,
                            // color: Colors.amber,
                            margin: EdgeInsets.only(
                                right: width / 32, top: height / 200),
                            child: Text(
                                widget.order.orderStatus
                                    .toString(), //"Delivered",
                                style: TextStyle(
                                    color: Color(0xffA11414),
                                    fontWeight: FontWeight.w600)))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      SizedBox(
                        height: height / 100,
                      ),
                      Text("Order ID: #" + widget.order.orderID.toString(),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                      SizedBox(height: height / 50),
                      con.orderedFoods == null || con.orderedFoods.isEmpty
                          ? hp.getCardLoader(size, 10, 1.25)
                          : Container(
                              child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 3.5,
                                          crossAxisCount: 3),
                                  itemBuilder: (context, int index) => Text(
                                      (con.orderedFoods[index].food.isEmpty
                                              ? "Food"
                                              : con.orderedFoods[index].food) +
                                          "*" +
                                          con.orderedFoods[index].quantity
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                  itemCount: con.orderedFoods.length),
                              height: height / 10),
                      SizedBox(
                        height: height / 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total - ₹ " + widget.order.total.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                          Container(
                            margin: EdgeInsets.only(right: width / 32),
                            child: Row(
                              children: [
                                Text("Payment Method - ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                                Text(
                                    widget.order.payMethod == "cash"
                                        ? "COD"
                                        : "Online",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height / 100),
                      Text(
                          widget.order.dateTime
                              .toString(), //"November 29, 17:15",
                          style: TextStyle(color: Color(0xff676666)
                              // , fontWeight: FontWeight.w600
                              )),
                      SizedBox(
                        height: height / 50,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                padding: EdgeInsets.only(left: width / 25, top: height / 100)),
            Row(children: [
              OutlinedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(radius / 200)))),
                    side: MaterialStateProperty.all(
                        BorderSide(color: Color(0xffa11414))),
                  ),
                  child: Container(
                      height: height / 22.51799813685248,
                      child: Center(
                        child: Text("REORDER",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xffa11414))),
                      ),
                      width: width / 2.62144)),
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DriverReviewFunkyOverlay(
                      order: widget.order,
                    ),
                    barrierDismissible: true,
                  );
                },
                // color: Colors.greenAccent,
                child: Container(
                    height: height / 25,
                    child: Center(
                      child: Text("RATE FOOD",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    width: width / 2.62144),
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(Size.square(radius / 25)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(radius / 200)))),
                    side: MaterialStateProperty.all(
                        BorderSide(color: Color(0xffa11414))),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xffa11414))),
              )
            ], crossAxisAlignment: CrossAxisAlignment.end)
          ], crossAxisAlignment: CrossAxisAlignment.start),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(radius / 100)),
            color: Color(0xfff7f7f7),
          ),
        ),
        elevation: 0,
        margin: EdgeInsets.symmetric(
            horizontal: width / 25, vertical: height / 32));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
}
