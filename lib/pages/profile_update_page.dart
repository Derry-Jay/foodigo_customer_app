import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/my_button.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/customer.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ProfileUpdatePage extends StatefulWidget {
  final Customer user;
  ProfileUpdatePage(this.user);
  ProfileUpdatePageState createState() => ProfileUpdatePageState();
}

class ProfileUpdatePageState extends StateMVC<ProfileUpdatePage> {
  UserController con;
  TextEditingController nc = new TextEditingController(),
      mc = new TextEditingController(),
      pc = new TextEditingController();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  ProfileUpdatePageState() : super(UserController()) {
    con = controller;
  }
  @override
  void initState() {
    super.initState();
    final user = widget.user;
    nc.text = user.customerName;
    mc.text = user.customerEmail;
    pc.text = user.phone;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: Text(hp.loc.edit + hp.loc.profile,
              style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigator.pushNamed(context, '/pages',
              //     arguments: RouteArgument(heroTag: "4"));
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Color(0xffFBFBFB),
          elevation: 0),
      body: SingleChildScrollView(
          child: Center(
              child: Form(
            key: con.loginFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    child: TextFormField(
                        controller: nc,
                        validator: hp.validateName,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: hp.loc.full_name + "*",
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    // decoration: BoxDecoration(
                    //     color: Color(0xfff7f7f7),
                    //     border: Border.all(
                    //         color: Color(
                    //             0xffBAD600))),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25, vertical: height / 50)),
                Container(
                    child: TextFormField(
                        controller: mc,
                        validator: hp.validateEmail,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: hp.loc.email + "*",
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25, vertical: height / 50)),
                Container(
                    child: TextField(
                        controller: pc,
                        style: TextStyle(color: Colors.black),
                        readOnly: true,
                        decoration: InputDecoration(
                            hintText: hp.loc.phone,
                            filled: true,
                            fillColor: Colors.grey[400],
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25, vertical: height / 50)),
                MyButton(
                    label: hp.loc.save.toUpperCase(),
                    dimensions: dimensions,
                    labelSize: 16,
                    heightFactor: 80,
                    widthFactor: 5,
                    elevation: 0,
                    labelWeight: FontWeight.w700,
                    radiusFactor: 160,
                    onPressed: () {
                      if (con.loginFormKey.currentState.validate()) {
                        Map<String, dynamic> body = new Map<String, dynamic>();
                        if (pc.text != null && pc.text.isNotEmpty)
                          body["phone"] = pc.text;
                        if (nc.text != null && nc.text.isNotEmpty)
                          body["name"] = nc.text;
                        if (mc.text != null && nc.text.isNotEmpty)
                          body["email"] = mc.text;
                        if (body.keys.isNotEmpty)
                          con.waitUntilProfileUpdate(body);
                      }
                    })
              ],
            ),
          )),
          padding: EdgeInsets.symmetric(horizontal: width / 50)),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
