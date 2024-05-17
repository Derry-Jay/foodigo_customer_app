import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/elements/coupons_list_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';

class OffersPage extends StatefulWidget {
  @override
  OffersPageState createState() => OffersPageState();
}

class OffersPageState extends State<OffersPage> {
  Helper get hp => Helper.of(context);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xfffbfbfb),
            foregroundColor: Colors.black,
            title: Text("Coupons",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        backgroundColor: Colors.white,
        body: CouponsListWidget());
  }
}
