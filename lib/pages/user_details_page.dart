import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/my_button.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
// import 'package:foodigo_customer_app/models/customer.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class UserDetailsPage extends StatefulWidget {
  final RouteArgument rar;
  UserDetailsPage(this.rar);
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends StateMVC<UserDetailsPage> {
  UserController con;
  DateTime selectedDate = DateTime.now();
  TextEditingController nc = new TextEditingController(),
      mc = new TextEditingController(),
      pc = new TextEditingController();
  Helper get hp => Helper.of(context);
  S get loc => S.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  UserDetailsPageState() : super(UserController()) {
    con = controller;
  }
  @override
  void initState() {
    super.initState();
    // nc.text = user.customerName;
    // mc.text = user.customerEmail;
    // pc.text = user.phone;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.black,
          title: Text(loc.add + loc.details),
          backgroundColor: Color(0xffFBFBFB),
          elevation: 0),
      body: SingleChildScrollView(
          child: Form(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                      child: TextFormField(
                          validator: (str) => str.isEmpty || str.length < 3
                              ? loc.not_a_valid_full_name
                              : null,
                          controller: nc,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: loc.full_name,
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.circular(radius / 100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.circular(radius / 100),
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
                          validator: hp.validateEmail,
                          controller: mc,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: loc.email,
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.circular(radius / 100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12),
                                borderRadius:
                                    BorderRadius.circular(radius / 100),
                              ))),
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 25, vertical: height / 50)),
                  // Container(
                  //     child: TextFormField(
                  //         maxLength: 12,
                  //         validator: hp.validatePassword,
                  //         obscuringCharacter: "*",
                  //         obscureText: con.hidePassword,
                  //         controller: pc,
                  //         style: TextStyle(color: Colors.black),
                  //         decoration: InputDecoration(
                  //             suffixIcon: IconButton(
                  //                 icon: Icon(Icons.remove_red_eye,
                  //                     color: con.hidePassword
                  //                         ? Color(0xff676666)
                  //                         : Color(0xffa11414)),
                  //                 onPressed: () => setState(() =>
                  //                     con.hidePassword = !con.hidePassword)),
                  //             hintText: "Password",
                  //             filled: true,
                  //             fillColor: Colors.white,
                  //             focusedBorder: OutlineInputBorder(
                  //               borderSide: BorderSide(color: Colors.black12),
                  //               borderRadius:
                  //                   BorderRadius.circular(radius / 100),
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderSide: BorderSide(color: Colors.black12),
                  //               borderRadius:
                  //                   BorderRadius.circular(radius / 100),
                  //             ))),
                  //     padding: EdgeInsets.symmetric(
                  //         horizontal: width / 25, vertical: height / 50)),
                  MyButton(
                      label: loc.confirmation.toUpperCase(),
                      dimensions: dimensions,
                      labelSize: 16,
                      heightFactor: 80,
                      widthFactor: 5,
                      elevation: 0,
                      labelWeight: FontWeight.w700,
                      radiusFactor: 160,
                      onPressed: () async {
                        if (con.loginFormKey.currentState.validate()) {
                          Map<String, dynamic> body = {
                            "name": nc.text,
                            "email": mc.text,
                            "password":
                                selectedDate.toString() + widget.rar.heroTag,
                            "mobileno": widget.rar.heroTag
                          };
                          final p = await Navigator.pushNamed(
                              context, '/registerAddress',
                              arguments: RouteArgument(param: body));
                          print(p);
                        }
                      })
                ],
              )),
              key: con.loginFormKey),
          padding: EdgeInsets.symmetric(horizontal: width / 50)),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
