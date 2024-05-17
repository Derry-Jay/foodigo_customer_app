import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OrdersPageState();
}

class OrdersPageState extends StateMVC<OrdersPage> {
  HotelController con;
  Helper get hp => Helper.of(context);
  int page = 1;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  S get loc => S.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  OrdersPageState() : super(HotelController()) {
    con = controller;
  }
  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    hp.getConnectStatus();
    hp.lockScreenRotation();
    await con.waitForDeliveredOrders(
        int.tryParse(sharedPrefs.getString("spCustomerID") ?? "-1") ?? 0,
        page.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          backgroundColor: Color(0xffFBFBFB),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(loc.my_orders, style: TextStyle(color: Colors.black))),
      body: LazyLoadScrollView(
          scrollDirection: Axis.vertical,
          onEndOfPage: () async {
            final sharedPrefs = await _sharedPrefs;
            print("object");
            page++;
            await con.waitForDeliveredOrders(
                int.tryParse(sharedPrefs.getString("spCustomerID") ?? "-1") ??
                    0,
                page.toString());
          },
          child: Scrollbar(
              child: hp.getDeliveredOrdersList(con.deliveredOrders, size))),
    );
  }

  @override
  void dispose() {
    hp.rollbackOrientations();
    super.dispose();
  }

  void showsnackbar() {
    scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Please accept the Terms&Conditions")));
  }
}
