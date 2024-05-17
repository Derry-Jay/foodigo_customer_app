import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponsPage extends StatefulWidget {
  final Cart cart;

  const CouponsPage(this.cart, {Key key}) : super(key: key);
  @override
  CouponsPageState createState() => CouponsPageState();
}

class CouponsPageState extends StateMVC<CouponsPage> {
  HotelController con;
  Helper get hp => Helper.of(context);
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  CouponsPageState() : super(HotelController()) {
    con = controller;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xfffbfbfb),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            foregroundColor: Colors.black,
            title: Text("Coupons",
                style: TextStyle(
                    // color: ,
                    fontSize: 16,
                    fontWeight: FontWeight.w700))),
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              child: hp.getCouponsList(con.coupons, "", widget.cart),
              height: constraints.maxHeight,
              width: constraints.maxWidth,
            );
          },
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // con.waitForCoupons();
    print("widget.cart.itemTotal");
    print(widget.cart.itemTotal);
    getData();
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    con.waitForCouponsbyHotel(sharedPrefs.getString("spHotelID"),
        sharedPrefs.getString("spCustomerID"));
  }
}
