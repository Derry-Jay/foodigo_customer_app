import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/elements/payment_method_item_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/pages/saved_online_payment_methods_page.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SavedOnlinePaymentOptionsListWidget extends StatefulWidget {
  SavedOnlinePaymentOptionsListWidget({Key key}) : super(key: key);
  @override
  SavedOnlinePaymentOptionsListWidgetState createState() =>
      SavedOnlinePaymentOptionsListWidgetState();

  static SavedOnlinePaymentMethodsPageState of(BuildContext context) =>
      context.findAncestorStateOfType<SavedOnlinePaymentMethodsPageState>();
}

class SavedOnlinePaymentOptionsListWidgetState
    extends StateMVC<SavedOnlinePaymentOptionsListWidget> {
  UserController con;
  List<bool> verified = List<bool>.empty(growable: true);
  Duration du = Duration(seconds: 5);
  Helper get hp => Helper.of(context);
  SavedOnlinePaymentMethodsPageState get sps =>
      SavedOnlinePaymentOptionsListWidget.of(context);
  CardViewMode get viewMode => sps.viewMode;
  MediaQueryData get dimensions => hp.dimensions;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  SavedOnlinePaymentOptionsListWidgetState() : super(UserController()) {
    con = controller;
  }

  void getData() async {
    du = await con.waitForSavedCards(sps);
    verified = List<bool>.filled(con.tokens.length, false);
  }

  void pickData() {
    getData();
  }

  FutureOr<dynamic> onGoBack(dynamic val) {
    sps.setState(pickData);
    print(val);
  }

  void addCardButtonOnPress() async {
    hp.navigateTo('/addCard', onGoBack: onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: con.tokens == null
            ? CircularLoader(
                duration: du,
                loaderType: LoaderType.PouringHourGlass,
                heightFactor: 5,
                widthFactor: 5,
                color: Color(0xffa11414))
            : (con.tokens.isEmpty
                ? GestureDetector(
                    child:
                        Center(child: Text("No Saved Cards.\n Tap to Add one")),
                    onTap: addCardButtonOnPress)
                : ListView.builder(
                    primary: true,
                    itemCount: con.tokens.length + 1,
                    itemBuilder: (context, index) => index == con.tokens.length
                        ? GestureDetector(
                            child: Container(
                                child: Text(
                                    "+ " +
                                        hp.loc.add +
                                        " " +
                                        hp.loc.payment_mode,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                decoration:
                                    BoxDecoration(color: Colors.lightGreen),
                                padding: EdgeInsets.symmetric(
                                    vertical: height / 100,
                                    horizontal: width / 80)),
                            onTap: addCardButtonOnPress)
                        : PaymentMethodItemWidget(
                            token: con.tokens[index], index: index))));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  @override
  void didUpdateWidget(SavedOnlinePaymentOptionsListWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) Future.delayed(Duration.zero, pickData);
  }
}
