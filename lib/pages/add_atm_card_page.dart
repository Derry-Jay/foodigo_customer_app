import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/my_button.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class AddATMCardPage extends StatefulWidget {
  @override
  AddATMCardPageState createState() => AddATMCardPageState();
}

class AddATMCardPageState extends StateMVC<AddATMCardPage> {
  DateTime dt;
  TextEditingController cn = new TextEditingController(),
      cvn = new TextEditingController(),
      nc = new TextEditingController(),
      expDtc = new TextEditingController();
  UserController con;
  Helper get hp => Helper.of(context);
  S get loc => S.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  AddATMCardPageState() : super(UserController()) {
    con = controller;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
              Container(
                  child: Text(loc.card_number,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.1072)),
                  padding: EdgeInsets.symmetric(vertical: height / 50)),
              TextField(
                  controller: cn,
                  maxLength: 16,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced),
              Container(
                  child: Text(loc.full_name,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.1072)),
                  padding: EdgeInsets.symmetric(vertical: height / 50)),
              TextField(
                controller: nc,
              ),
              Container(
                  child: Text(loc.expiry_date,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.1072)),
                  padding: EdgeInsets.symmetric(vertical: height / 50)),
              TextField(
                controller: expDtc,
                onTap: () async {
                  final pd = await hp.getDatePicker(expDtc);
                  dt = pd;
                },
              ),
              Container(
                  child: Text(loc.cvv + " / " + loc.cvv,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.1072)),
                  padding: EdgeInsets.symmetric(vertical: height / 50)),
              TextField(
                controller: cvn,
              ),
              Center(
                  child: MyButton(
                      label: loc.add,
                      dimensions: dimensions,
                      labelSize: 12,
                      heightFactor: 50,
                      widthFactor: 10,
                      elevation: 8,
                      labelWeight: FontWeight.w600,
                      radiusFactor: 160,
                      onPressed: () async {
                        final body = {
                          "method": "card",
                          "card": {
                            "number": hp.getCreditCardNumber(cn.text),
                            "expiry_month":
                                dt == null ? "0" : dt.month.toString(),
                            "expiry_year":
                                dt == null ? "0" : dt.year.toString(),
                            "cvv": cvn.text,
                            "name": nc.text
                          }
                        };
                        if (cn.text.isNotEmpty &&
                            dt != null &&
                            cvn.text.isNotEmpty &&
                            nc.text.isNotEmpty &&
                            nc.text.length > 2 &&
                            cvn.text.length == 3 &&
                            cn.text.length == 16)
                          con.waitUntilAddCard(body);
                        else {
                          final f = await Fluttertoast.showToast(
                              msg: ((cn.text.isEmpty || cn.text.length != 16) &&
                                      (dt != null &&
                                          cvn.text.isNotEmpty &&
                                          nc.text.isNotEmpty &&
                                          nc.text.length > 2 &&
                                          cvn.text.length == 3))
                                  ? loc.your_credit_card_not_valid
                                  : ((cn.text.isNotEmpty &&
                                          (dt == null ||
                                              DateTime.now()
                                                      .difference(dt)
                                                      .inDays <
                                                  0) &&
                                          cvn.text.isNotEmpty &&
                                          nc.text.isNotEmpty &&
                                          nc.text.length > 2 &&
                                          cvn.text.length == 3 &&
                                          cn.text.length == 16)
                                      ? loc.not_a_valid_date
                                      : ((cn.text.isNotEmpty &&
                                              dt != null &&
                                              cvn.text.isNotEmpty &&
                                              (nc.text.isEmpty ||
                                                  nc.text.length < 3) &&
                                              cvn.text.length == 3 &&
                                              cn.text.length == 16)
                                          ? loc.not_a_valid_full_name
                                          : ((cn.text.isNotEmpty &&
                                                  dt != null &&
                                                  (cvn.text.isEmpty ||
                                                      cvn.text.length != 3) &&
                                                  nc.text.isNotEmpty &&
                                                  nc.text.length > 2 &&
                                                  cn.text.length == 16)
                                              ? loc.not_a_valid_cvc
                                              : loc
                                                  .your_credit_card_not_valid))));
                          if (f) print(body);
                        }
                      }),
                  heightFactor: height / width)
            ], crossAxisAlignment: CrossAxisAlignment.start),
            padding: EdgeInsets.symmetric(horizontal: width / 40)),
        appBar: AppBar(
            backwardsCompatibility: false,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            title: Text(loc.add + " " + loc.default_credit_card,
                style: TextStyle(fontWeight: FontWeight.w700))));
  }
}
