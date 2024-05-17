import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/saved_cards_list_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SavedOnlinePaymentMethodsPage extends StatefulWidget {
  final RouteArgument rar;
  SavedOnlinePaymentMethodsPage({Key key, @required this.rar})
      : super(key: key);
  @override
  SavedOnlinePaymentMethodsPageState createState() =>
      SavedOnlinePaymentMethodsPageState();
}

class SavedOnlinePaymentMethodsPageState
    extends StateMVC<SavedOnlinePaymentMethodsPage> {
  String cno, cvv;
  UserController con;
  Map<String, dynamic> paymentData;
  Helper get hp => Helper.of(context);
  CardViewMode get viewMode => widget.rar.param as CardViewMode;
  SavedOnlinePaymentMethodsPageState() : super(UserController()) {
    con = controller;
  }

  void addCard() {
    hp.navigateTo('/addCard', onGoBack: getData);
  }

  FutureOr<dynamic> getData(dynamic value) async {
    final val = await con.waitForSavedCards(widget.createState());
    setState(() {
      print("Gummaning");
      print(value);
      print(val);
      print("Gud Eve");
    });
  }

  void assignState() {
    hp.getConnectStatus();
    if (viewMode == CardViewMode.Verify)
      paymentData = json.decode(widget.rar.heroTag);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // Widget bc;
    // switch (viewMode) {
    //   case CardViewMode.Verify:
    //     bc = MyButton(
    //         label: hp.loc.confirm_payment,
    //         dimensions: hp.dimensions,
    //         labelSize: 32,
    //         heightFactor: 20,
    //         widthFactor: 1,
    //         elevation: 8,
    //         labelWeight: FontWeight.w600,
    //         radiusFactor: 160,
    //         onPressed: () async {
    //           final cd = {"cno": cno, "cvv": cvv};
    //           con.waitUntilUploadOrder(paymentData, cd);
    //         });
    //     break;
    //   case CardViewMode.Delete:
    //   default:
    //     bc = Container();
    //     break;
    // }
    return Scaffold(
        // bottomNavigationBar: bc,
        floatingActionButton: FloatingActionButton(
            onPressed: addCard,
            tooltip: hp.loc.add + " " + hp.loc.payment_mode,
            child: Icon(Icons.add),
            backgroundColor: Color(0xffa11414),
            foregroundColor: Colors.white),
        body: SavedOnlinePaymentOptionsListWidget(),
        appBar: AppBar(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            title: Text(hp.loc.payment_options,
                style: TextStyle(fontWeight: FontWeight.w700))));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, assignState);
  }
}
