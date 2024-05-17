import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/pages/current_orders_page.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'active_order_item_widget.dart';
import 'circular_loader.dart';

class ActiveOrdersListWidget extends StatefulWidget {
  @override
  ActiveOrdersListWidgetState createState() => ActiveOrdersListWidgetState();

  static CurrentOrdersPageState of(BuildContext context) =>
      context.findAncestorStateOfType<CurrentOrdersPageState>();
}

class ActiveOrdersListWidgetState extends StateMVC<ActiveOrdersListWidget> {
  int page = 1;
  HotelController con;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  CurrentOrdersPageState get copS => ActiveOrdersListWidget.of(context);
  ActiveOrdersListWidgetState() : super(HotelController()) {
    con = controller;
  }

  Future<void> pickData() async {
    try {
      final sharedPrefs = await _sharedPrefs;
      await con.waitForCurrentOrders(
          int.tryParse(sharedPrefs.getString("spCustomerID") ?? "-1") ?? -1,
          "1");
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void loadMore() async {
    page++;
    print(page);
    await pickData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return con.activeOrders == null
        ? CircularLoader(
            duration: Duration(seconds: 5),
            heightFactor: 8,
            widthFactor: 8,
            color: Color(0xffa11414),
            loaderType: LoaderType.PouringHourGlass)
        : (con.activeOrders.isEmpty
            ? Center(
                child: Text(hp.loc.youDontHaveAnyOrder,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
            : LazyLoadScrollView(
                scrollDirection: Axis.vertical,
                onEndOfPage: loadMore,
                child: RefreshIndicator(
                    color: Color(0xffa11414),
                    onRefresh: pickData,
                    child: Scrollbar(
                        child: ListView.builder(
                            itemBuilder: (context, int index) => Center(
                                child: index == con.activeOrders.length
                                    ? (con.activeOrders.length > 4
                                        ? CircularLoader(
                                            heightFactor: 16,
                                            widthFactor: 16,
                                            color: Color(0xffa11414))
                                        : Container(height: 0, width: 0))
                                    : ActiveOrderItemWidget(
                                        order: con.activeOrders[index])),
                            itemCount: con.activeOrders.length + 1,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics())))));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(AppLifecycleState.values);
    print(con.activeOrders.isEmpty && state == AppLifecycleState.paused);
    if (state == AppLifecycleState.resumed)
      Future.delayed(Duration.zero, pickData);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, pickData);
  }
}
