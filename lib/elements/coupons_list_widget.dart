import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/coupon_item_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'circular_loader.dart';

class CouponsListWidget extends StatefulWidget {
  @override
  CouponsListWidgetState createState() => CouponsListWidgetState();
}

class CouponsListWidgetState extends StateMVC<CouponsListWidget> {
  HotelController con;
  int page = 1;
  Helper get hp => Helper.of(context);
  CouponsListWidgetState() : super(HotelController()) {
    con = controller;
  }

  void getData() async {
    hp.getConnectStatus();
    await con.waitForCoupons(page.toString());
  }

  void endOfPage() async {
    ++page;
    await con.waitForCoupons(page.toString());
  }

  Widget getItemBuilder(BuildContext context, int index) {
    return index == con.coupons.length
        ? (con.coupons.length > 4
            ? CircularLoader(
                widthFactor: 16, color: Color(0xffa11414), heightFactor: 16)
            : Container())
        : CouponItemWidget(coupon: con.coupons[index]);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return con.coupons == null
        ? CircularLoader(
            widthFactor: 10, color: Color(0xffa11414), heightFactor: 10)
        : (con.coupons.isEmpty
            ? Center(
                child: Text("No Coupons Found",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
            : LazyLoadScrollView(
                onEndOfPage: endOfPage,
                child: Scrollbar(
                    child: ListView.builder(
                        itemBuilder: getItemBuilder,
                        itemCount: con.coupons.length + 1))));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, getData);
  }
}
