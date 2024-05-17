import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/address_item_widget.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/pages/addresses_page.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class AddressPageListWidget extends StatefulWidget {
  @override
  AddressPageListWidgetState createState() => AddressPageListWidgetState();
  static AddressesPageState of(BuildContext context) =>
      context.findAncestorStateOfType<AddressesPageState>();
}

class AddressPageListWidgetState extends StateMVC<AddressPageListWidget> {
  UserController con;
  Duration du = Duration(seconds: 1);
  Helper get hp => Helper.of(context);
  AddressesPageState get aps => AddressPageListWidget.of(context);
  AddressPageListWidgetState() : super(UserController()) {
    con = controller;
  }

  Widget getItemBuilder(BuildContext context, int index) {
    return AddressItemWidget(address: con.addresses[index]);
  }

  void getData() async {
    du = await con.waitForDeliveryAddresses();
  }

  FutureOr onGoBack(dynamic value) async {
    print(value);
    aps.setState(pickData);
  }

  void pickData() {
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return con.addresses == null
        ? CircularLoader(
            heightFactor: 10,
            widthFactor: 10,
            color: Color(0xffa11414),
            duration: du,
            loaderType: LoaderType.PouringHourGlass)
        : (con.addresses.isEmpty
            ? Center(child: Text(hp.loc.add_delivery_address))
            : ListView.builder(
                itemBuilder: getItemBuilder, itemCount: con.addresses.length));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  @override
  void didUpdateWidget(AddressPageListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) Future.delayed(Duration.zero, pickData);
  }
}
