import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/address_list_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class AddressesPage extends StatefulWidget {
  @override
  AddressesPageState createState() => AddressesPageState();
}

class AddressesPageState extends StateMVC<AddressesPage> {
  UserController con;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  AddressesPageState() : super(UserController()) {
    con = controller;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white70,
            title: Text(hp.loc.delivery_addresses.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w700))),
        body: Column(children: [
          Container(
              child: Text(hp.loc.delivery_addresses,
                  style: TextStyle(color: Colors.black)),
              color: Colors.grey[100],
              padding: EdgeInsets.only(
                  left: width / 32,
                  right: width / 1.6,
                  bottom: height / 40,
                  top: height / 50)),
          Expanded(child: AddressPageListWidget())
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              hp.navigateTo('/addLocation', onGoBack: onGoBack);
            },
            tooltip: hp.loc.add_delivery_address,
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Color(0xffa11414),
            foregroundColor: Colors.white));
  }

  FutureOr onGoBack(dynamic value) async {
    print(value);
    setState(getData);
  }

  void pickData() async {
    final dt = await con.waitForDeliveryAddresses();
    print(dt);
  }

  void getData() {
    pickData();
  }
}
