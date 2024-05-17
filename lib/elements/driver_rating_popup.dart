import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:foodigo_customer_app/pages/orders_page.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class DriverReviewFunkyOverlay extends StatefulWidget {
  final Order order;

  const DriverReviewFunkyOverlay({Key key, this.order}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DriverReviewFunkyOverlayState();
}

class DriverReviewFunkyOverlayState extends StateMVC<DriverReviewFunkyOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController animiController;
  Animation<double> scaleAnimation;
  HotelController con;
  Helper hp;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  OrdersPageState orp;
  DriverReviewFunkyOverlayState() : super(HotelController()) {
    con = controller;
  }
  TextEditingController review = new TextEditingController();

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    con.waitForHotelData(widget.order.hotelID);
    animiController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: animiController, curve: Curves.elasticInOut);

    animiController.addListener(() {
      setState(() {});
    });

    animiController.forward();
  }

  @override
  Widget build(BuildContext context) {
    var ph = MediaQuery.of(context).size.height;
    var pw = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50.0),
              child: Material(
                color: Colors.transparent,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    height: ph / 1.6,
                    width: pw / 1.5,
                    padding:
                        const EdgeInsets.only(top: 20.0, left: 8, right: 8),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rate your review".toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            "And you statisfied with the service".toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 12)),
                        SizedBox(
                          height: ph / 15,
                        ),
                        RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        ),
                        SizedBox(
                          height: ph / 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                              cursorColor: Color(0xffbad600),
                              validator: hp.validatePhoneNumber,
                              decoration: InputDecoration(
                                // hintText: "Give Your Feedbacks",
                                hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                                contentPadding:
                                    const EdgeInsets.only(left: 15.0),
                                prefixStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.179869184),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                // focusedBorder: UnderlineInputBorder(
                                //   borderSide:
                                //       BorderSide(color: Color(0xffBAD600)),
                                //   borderRadius:
                                //       BorderRadius.circular(radius / 200),
                                // ),
                                // enabledBorder: UnderlineInputBorder(
                                //   borderSide:
                                //       BorderSide(color: Color(0xffBAD600)),
                                //   borderRadius:
                                //       BorderRadius.circular(radius / 200),
                                // )
                              ),
                              controller: review,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17.179869184)),
                        ),
                        DottedLine(
                            lineLength: pw / 1.7,
                            // height: height / 1000,
                            // width: width / 400,
                            direction: Axis.horizontal,
                            dashColor: Colors.black),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Tell us what can be improved".toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        SizedBox(
                          height: 10,
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.grey.shade100),
                                child: Text("Overall Service".toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.grey.shade100),
                                child: Text("Fast Delivery".toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.grey.shade100),
                                child: Text("Timing".toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.grey.shade100),
                                child: Text("More Coupon offer".toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.grey.shade100),
                                child: Text("Packing Quality".toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade100),
                          child: TextFormField(
                              cursorColor: Color(0xffbad600),
                              validator: hp.validatePhoneNumber,
                              decoration: InputDecoration(
                                hintText: "Tell us how to improve...",
                                hintStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey),
                                contentPadding:
                                    const EdgeInsets.only(left: 15.0),
                                prefixStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.179869184),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                // focusedBorder: UnderlineInputBorder(
                                //   borderSide:
                                //       BorderSide(color: Color(0xffBAD600)),
                                //   borderRadius:
                                //       BorderRadius.circular(radius / 200),
                                // ),
                                // enabledBorder: UnderlineInputBorder(
                                //   borderSide:
                                //       BorderSide(color: Color(0xffBAD600)),
                                //   borderRadius:
                                //       BorderRadius.circular(radius / 200),
                                // )
                              ),
                              controller: review,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17.179869184)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            // color: Colors.greenAccent,
                            child: Container(
                                height: height / 25,
                                child: Center(
                                  child: Text("Submit".toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                                width: width / 2.62144),
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    Size.square(radius / 25)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(
                                                radius / 200)))),
                                side: MaterialStateProperty.all(
                                    BorderSide(color: Color(0xffa11414))),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xffa11414))),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: ButtonTheme(
          //     height: 40.0,
          //     minWidth: pw / 1.5,
          //     child: RaisedButton(
          //       child: Text(
          //         'NEXT'.toString(),
          //         textScaleFactor: 1.0,
          //         style: TextStyle(
          //             decoration: TextDecoration.none, fontSize: 20.0),
          //       ),
          //       color: Colors.yellow.shade800,
          //       textColor: Colors.white,
          //       shape: new RoundedRectangleBorder(
          //         borderRadius: new BorderRadius.circular(10.0),
          //       ),
          //       splashColor: Colors.grey,
          //       onPressed: () async {
          //         print("object");
          //       },
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
