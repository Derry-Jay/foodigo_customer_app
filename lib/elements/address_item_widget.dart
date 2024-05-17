import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/address.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'address_list_widget.dart';

class AddressItemWidget extends StatefulWidget {
  final WhereAbouts address;
  AddressItemWidget({Key key, @required this.address}) : super(key: key);
  @override
  AddressItemWidgetState createState() => AddressItemWidgetState();
  static AddressPageListWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<AddressPageListWidgetState>();
}

class AddressItemWidgetState extends StateMVC<AddressItemWidget> {
  UserController con;
  Helper get hp => Helper.of(context);
  AddressPageListWidgetState get apLS => AddressItemWidget.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  AddressItemWidgetState() : super(UserController()) {
    con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            child: Column(children: <Widget>[
              Expanded(
                  child: Container(
                      child: Column(
                          children: [
                            Expanded(
                                child: Row(
                                    children: [
                                  Container(
                                    child: Text(widget.address.title,
                                        style: TextStyle(
                                            color: Color(0xff181c02),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    // margin:
                                    //     EdgeInsets.only(top: height / 200)
                                  ),
                                  // Container(
                                  //     // width: width / 2
                                  //     // height: 200,
                                  //     // color: Colors.amber,
                                  //     margin: EdgeInsets.only(
                                  //         right: width / 32, top: height / 200),
                                  //     child: Text(
                                  //         widget.address.addressID.toString(),
                                  //         style: TextStyle(
                                  //             color: Color(0xffA11414),
                                  //             fontWeight: FontWeight.w600)))
                                ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween)),
                            Expanded(
                                child: Text(widget.address.fullAddress,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600))),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.only(
                          left: width / 25, top: height / 100))),
              Expanded(
                  child: Row(children: [
                OutlinedButton(
                    onPressed: () {
                      hp
                          .showDialogBox(
                              "Delete this Address",
                              ["No", "Yes"],
                              [
                                () {
                                  Navigator.pop(context);
                                },
                                () {
                                  con.waitUntilDeleteAddress(
                                      widget.address.addressID, apLS);
                                }
                              ],
                              size)
                          .then(apLS.onGoBack);
                    },
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
                          child: Text(hp.loc.close,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffa11414))),
                        ),
                        width: width / 2.62144)),
                OutlinedButton(
                    onPressed: () {
                      hp.navigateTo('/editAddress',
                          arguments: widget.address, onGoBack: apLS.onGoBack);
                    },
                    child: Container(
                        height: height / 40,
                        child: Center(
                          child: Text(hp.loc.edit,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        width: width / 2.7
                        // , margin: EdgeInsets.symmetric(vertical: height/100)
                        ),
                    style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(Size.square(radius / 25)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(radius / 200)))),
                        side: MaterialStateProperty.all(
                            BorderSide(color: Color(0xffa11414))),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xffa11414))))
              ], crossAxisAlignment: CrossAxisAlignment.end))
            ], crossAxisAlignment: CrossAxisAlignment.start),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(radius / 100)),
                color: Color(0xfff7f7f7)),
            height: height / 5),
        margin:
            EdgeInsets.symmetric(horizontal: width / 25, vertical: height / 32),
        elevation: 0);
  }
}
