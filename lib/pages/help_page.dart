import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HelpPageState();
}

class HelpPageState extends StateMVC<HelpPage> {
  HotelController con;
  Duration du = Duration(seconds: 1);
  int page = 1;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  HelpPageState() : super(HotelController()) {
    con = controller;
  }

  Future<void> getData() async {
    final sharedPrefs = await _sharedPrefs;
    hp.lockScreenRotation();
    hp.getConnectStatus();
    du = await con.waitForCurrentOrders(
        int.tryParse(sharedPrefs.getString("spCustomerID") ?? "-1") ?? -1,
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
        backgroundColor: Colors.white,
        body: hp == null || con.activeOrders == null
            ? CircularLoader(
                duration: du,
                color: Color(0xffa11414),
                heightFactor: 16,
                widthFactor: 16,
                loaderType: LoaderType.PouringHourGlass)
            : (con.activeOrders.isEmpty
                ? RefreshIndicator(
                    onRefresh: getData,
                    child: Center(
                        child: Text(hp.loc.youDontHaveAnyOrder,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))),
                  )
                : LazyLoadScrollView(
                    scrollDirection: Axis.vertical,
                    onEndOfPage: () async {
                      final sharedPrefs = await _sharedPrefs;
                      print("object");
                      page++;
                      await con.waitForCurrentOrders(
                          int.tryParse(sharedPrefs.getString("spCustomerID") ??
                                  "-1") ??
                              -1,
                          page.toString());
                    },
                    child: RefreshIndicator(
                      onRefresh: getData,
                      child: Scrollbar(
                          child:
                              hp.getActiveOrdersList(con.activeOrders, size)),
                    ),
                  )));
  }

  @override
  void dispose() {
    hp.rollbackOrientations();
    super.dispose();
  }
}
