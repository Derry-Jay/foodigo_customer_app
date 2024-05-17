import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/elements/active_order_menu_widget.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/models/order.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;
  OrderDetailsPage(this.order);
  @override
  State<StatefulWidget> createState() => OrderDetailsPageState();
}

class OrderDetailsPageState extends State<OrderDetailsPage> {
  S get loc => S.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get width => size.width;
  double get height => size.height;
  double get pixelRatio => dimensions.devicePixelRatio;
  double get textScaleFactor => dimensions.textScaleFactor;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xffa11414),
        title: Text(loc.order + " #" + widget.order.orderID.toString()),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(children: [
        SizedBox(
          height: height / 10,
        ),
        SizedBox(
          child: ActiveOrderBillingWidget(
            order: widget.order,
          ),
          height: height / 1.5,
          width: width,
        )
      ]),
    );
  }
}
