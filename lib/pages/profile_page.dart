import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:foodigo_customer_app/models/setting.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends StateMVC<ProfilePage> {
  UserController con;
  Helper get hp => Helper.of(context);
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  ProfilePageState() : super(UserController()) {
    con = controller;
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    con.waitForCustomerDetails(
        int.tryParse(sharedPrefs.getString("spCustomerID") ?? "-1") ?? -1);
    if (mounted) {
      hp.getConnectStatus();
      hp.lockScreenRotation();
    }
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
    return ScopedModel<Setting>(
        model: Setting(),
        child: ScopedModelDescendant<Setting>(builder: pageBuilder));
  }

  Widget pageBuilder(BuildContext context, Widget child, Setting setting) {
    final loc = S.of(context);
    if (setting.mobileLanguage == null) setting.getLang();
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
      con.customer == null
          ? Image.asset("assets/images/loading_card.gif",
              width: hp.width, height: hp.height / 5, fit: BoxFit.fill)
          : Card(
              margin: EdgeInsets.only(bottom: hp.height / 50),
              child: Container(
                  child: Column(children: [
                    Container(
                        child: Text(
                          loc.profile,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: hp.height / 80)),
                    Row(children: [
                      Column(
                          children: [
                            Text(
                                con.customer.customerName == null ||
                                        con.customer.customerName == ""
                                    ? loc.not_a_valid_full_name
                                    : con.customer.customerName,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.black)),
                            Text(
                                (con.customer.phone == null ||
                                            con.customer.phone.isEmpty
                                        ? loc.not_a_valid_phone
                                        : con.customer.phone) +
                                    "                        ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black))
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      GestureDetector(
                          child: Image.asset("assets/images/edit_icon.png"),
                          onTap: () {
                            hp.navigateTo('/profileEdit',
                                arguments: con.customer);
                          })
                    ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  padding: EdgeInsets.symmetric(
                      horizontal: hp.width / 32, vertical: hp.height / 50),
                  width: double.infinity),
              elevation: 0),
      Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(hp.radius / 80))),
          margin: EdgeInsets.symmetric(horizontal: hp.width / 25),
          child: Column(
            children: [
              InkWell(
                  child: Container(
                      child: Row(children: [
                        Image.asset("assets/images/gear.png"),
                        Flexible(
                            child: Text(loc.delivery_addresses,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black))),
                        Flexible(child: Icon(Icons.arrow_forward_ios, size: 16))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.symmetric(
                          horizontal: hp.width / 32, vertical: hp.height / 50)),
                  onTap: () {
                    hp.navigateTo('/addresses');
                  }),
              InkWell(
                  child: Container(
                      child: Row(children: [
                        Image.asset("assets/images/gear.png"),
                        Flexible(
                            child: Text(loc.my_orders,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black))),
                        Flexible(child: Icon(Icons.arrow_forward_ios, size: 16))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.symmetric(
                          horizontal: hp.width / 32, vertical: hp.height / 50)),
                  onTap: () {
                    hp.navigateTo("/orders");
                  }),
              InkWell(
                  child: Container(
                      child: Row(children: [
                        Image.asset("assets/images/gear.png"),
                        Flexible(
                            child: Text(loc.recent_orders,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black))),
                        Flexible(child: Icon(Icons.arrow_forward_ios, size: 16))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.symmetric(
                          horizontal: hp.width / 32, vertical: hp.height / 50)),
                  onTap: () {
                    hp.navigateTo('/currentOrders');
                  }),
              InkWell(
                  // borderRadius: BorderRadius.all(Radius.circular(hp.radius * 2)),
                  onTap: () {
                    hp.navigateTo('/offers');
                  },
                  child: Container(
                      child: Row(children: [
                        Image.asset("assets/images/gear.png"),
                        Flexible(
                            child: Text("Coupons",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black))),
                        Flexible(child: Icon(Icons.arrow_forward_ios, size: 16))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.symmetric(
                          horizontal: hp.width / 32,
                          vertical: hp.height / 50))),
              InkWell(
                  // borderRadius: BorderRadius.all(Radius.circular(hp.radius * 2)),
                  onTap: () {
                    hp.navigateTo('/help');
                  },
                  child: Container(
                      child: Row(children: [
                        Image.asset("assets/images/gear.png"),
                        Flexible(
                            child: Text(loc.help_support,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black))),
                        Flexible(child: Icon(Icons.arrow_forward_ios, size: 16))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.symmetric(
                          horizontal: hp.width / 32, vertical: hp.height / 50)))
            ],
          ),
          elevation: 0),
      Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(hp.radius / 80))),
          margin: EdgeInsets.symmetric(
              horizontal: hp.width / 25, vertical: hp.height / 80),
          child: Column(
            children: [
              Container(
                  child: Row(children: [
                    Image.asset("assets/images/gear.png"),
                    Flexible(
                        child: Text(loc.app_language,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black))),
                    Flexible(
                        child: DropdownButton<Locale>(
                            onChanged: setting.setLanguage,
                            value: setting.mobileLanguage == null
                                ? Locale('en', '')
                                : setting.mobileLanguage.value,
                            items:
                                List<Locale>.from(S.delegate.supportedLocales)
                                    .map((e) => DropdownMenuItem<Locale>(
                                        child: Text(e.toLanguageTag()),
                                        value: e,
                                        onTap: () {
                                          setting.setLanguage(e);
                                        }))
                                    .toList())),
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  padding: EdgeInsets.symmetric(
                      horizontal: hp.width / 32, vertical: hp.height / 50)),
              // InkWell(
              //     child: Container(
              //         child: Row(
              //             children: [
              //               Image.asset("assets/images/gear.png"),
              //               Text(loc.help_supports,
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.w600,
              //                       fontSize: 14,
              //                       color: Colors.black)),
              //               Icon(Icons.arrow_forward_ios, size: 16)
              //             ],
              //             mainAxisAlignment:
              //                 MainAxisAlignment.spaceBetween),
              //         padding: EdgeInsets.symmetric(
              //             horizontal: width / 32,
              //             vertical: height / 50)),
              //     onTap: () {}),
              // InkWell(
              //     child: Container(
              //         child: Row(
              //             children: [
              //               Image.asset("assets/images/gear.png"),
              //               Text(loc.settings,
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.w600,
              //                       fontSize: 14,
              //                       color: Colors.black)),
              //               Icon(Icons.arrow_forward_ios, size: 16)
              //             ],
              //             mainAxisAlignment:
              //                 MainAxisAlignment.spaceBetween),
              //         padding: EdgeInsets.symmetric(
              //             horizontal: width / 32,
              //             vertical: height / 50)),
              //     onTap: () {}),
              InkWell(
                  child: Container(
                      child: Row(children: [
                        Image.asset("assets/images/gear.png"),
                        Flexible(
                            child: Text(loc.payment_options,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black))),
                        Flexible(child: Icon(Icons.arrow_forward_ios, size: 16))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.symmetric(
                          horizontal: hp.width / 32, vertical: hp.height / 50)),
                  onTap: () {
                    hp.navigateTo('/savedOnlinePaymentMethods',
                        arguments: RouteArgument(param: CardViewMode.Delete));
                  })
              // ,
              // InkWell(
              //     child: Container(
              //         child: Row(
              //             children: [
              //               Image.asset("assets/images/gear.png"),
              //               Text(loc.about,
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.w600,
              //                       fontSize: 14,
              //                       color: Colors.black)),
              //               Icon(Icons.arrow_forward_ios, size: 16)
              //             ],
              //             mainAxisAlignment:
              //                 MainAxisAlignment.spaceBetween),
              //         padding: EdgeInsets.symmetric(
              //             horizontal: width / 32,
              //             vertical: height / 50)),
              //     onTap: () {}),
            ],
          ),
          elevation: 0),
      Card(
          margin: EdgeInsets.symmetric(horizontal: hp.width / 25),
          child: InkWell(
              child: Container(
                  child: Row(children: [
                    Image.asset("assets/images/logout.png"),
                    Flexible(
                        child: Text(loc.log_out,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black))),
                    Flexible(child: Icon(Icons.arrow_forward_ios, size: 16))
                  ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  padding: EdgeInsets.symmetric(
                      horizontal: hp.width / 26.2144,
                      vertical: hp.height / 50)),
              onTap: con.logout),
          elevation: 0),
    ], mainAxisAlignment: MainAxisAlignment.spaceBetween)));
  }

  @override
  void dispose() {
    super.dispose();
    // hp.rollbackOrientations();
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   final p = context.dependOnInheritedWidgetOfExactType();
  //   print(p);
  // }
}
