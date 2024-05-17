import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/saved_cards_list_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/token.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class PaymentMethodItemWidget extends StatefulWidget {
  final Token token;
  final int index;
  PaymentMethodItemWidget({Key key, @required this.token, @required this.index})
      : super(key: key);
  @override
  PaymentMethodItemWidgetState createState() => PaymentMethodItemWidgetState();

  static SavedOnlinePaymentOptionsListWidgetState of(BuildContext context) =>
      context
          .findAncestorStateOfType<SavedOnlinePaymentOptionsListWidgetState>();
}

class PaymentMethodItemWidgetState extends StateMVC<PaymentMethodItemWidget> {
  DateTime dt;
  Duration diff;
  bool vMode;
  UserController con;
  TextEditingController tc = new TextEditingController(),
      nc = new TextEditingController();
  DateTime get cd =>
      DateTime.utc(widget.token.card.expYr, widget.token.card.expMt);
  SavedOnlinePaymentOptionsListWidgetState get spLs =>
      PaymentMethodItemWidget.of(context);
  CardViewMode get viewMode => spLs.viewMode;
  int get cardNoLastFour => widget.token.card.last4;
  int get cardNoLastFourLength => widget.token.card.last4.toString().length;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Helper get hp => Helper.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  PaymentMethodItemWidgetState() : super(UserController()) {
    con = controller;
  }

  @override
  Widget build(BuildContext context) {
    Widget ch;
    switch (viewMode) {
      case CardViewMode.Delete:
        ch = InkWell(
            child: Text(hp.loc.close,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xffa11414))),
            onTap: () {
              con.waitUntilCardDelete(widget.token.tokenID, spLs);
            });
        break;
      case CardViewMode.Verify:
        ch = TextField(
            onChanged: (str) {
              spLs.sps.cvv = str;
            },
            // onTap: () async {
            //   dt = await hp.getDatePicker(tc);
            //   if (dt != null) {
            //     diff = cd.difference(dt);
            //     print("---------------");
            //     print(hp.putDateTimeToString(dt));
            //     print("Hi");
            //     print(diff.inDays);
            //     spLs.setState(() {
            //       vMode = diff.inDays < 31;
            //       if (vMode) {
            //         print("Nakkana");
            //         tc.text = "";
            //         if (spLs.verified.indexOf(vMode) == -1)
            //           spLs.verified[widget.index] = vMode;
            //         else {
            //           spLs.verified[spLs.verified.indexOf(vMode)] = !vMode;
            //           spLs.verified[widget.index] = vMode;
            //         }
            //       }
            //     });
            //     print(hp.compareDates(dt, cd));
            //     print("Success");
            //     print(hp.putDateTimeToString(cd));
            //     print("_______________");
            //   }
            // },
            // readOnly: true,
            cursorColor: Color(0xffa11414),
            obscureText: true,
            maxLength: 3,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            controller: tc,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                hintText: hp.loc.cvv,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffa11414)))),
            style: TextStyle(
                color: Color(0xffa11414), fontWeight: FontWeight.w700));
        break;
    }
    return Container(
        color: Colors.white,
        child: Row(children: [
          Image.asset("assets/images/gear.png"),
          // Flexible(
          //     child: Visibility(
          //         child: TextField(
          //             onChanged: (str) {
          //               spLs.sps.cno = str + cardNoLastFour.toString();
          //             },
          //             controller: nc,
          //             cursorColor: Color(0xffa11414),
          //             obscureText: true,
          //             maxLength: 12,
          //             maxLengthEnforcement: MaxLengthEnforcement.enforced,
          //             keyboardType: TextInputType.phone,
          //             decoration: InputDecoration(
          //                 hintText: hp.loc.card_number,
          //                 focusedBorder: UnderlineInputBorder(
          //                     borderSide:
          //                         BorderSide(color: Color(0xffa11414)))),
          //             style: TextStyle(
          //                 color: Color(0xffa11414),
          //                 fontWeight: FontWeight.w700)),
          //         visible: viewMode == CardViewMode.Verify)),
          Expanded(
              child: Text(
                  viewMode == CardViewMode.Verify
                      ? cardNoLastFour.toString()
                      : ((cardNoLastFourLength < 4
                              ? cardNoLastFour
                                  .toString()
                                  .padLeft(5 - cardNoLastFourLength, "0")
                              : cardNoLastFour.toString())
                          .padLeft(12, 'X')),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black))),
          Flexible(child: ch)
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
        padding: EdgeInsets.symmetric(
            horizontal: width / 32, vertical: height / 50));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vMode = spLs.verified[widget.index];
  }
}
