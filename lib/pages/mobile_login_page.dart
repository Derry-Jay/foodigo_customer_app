import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/my_button.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repos/user_repos.dart' as userRepo;

class MobileLoginPage extends StatefulWidget {
  @override
  MobileLoginPageState createState() => MobileLoginPageState();
}

class MobileLoginPageState extends StateMVC<MobileLoginPage> {
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  TextEditingController tc = new TextEditingController();
  UserController con;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  bool isloading = false;
  MobileLoginPageState() : super(UserController()) {
    con = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
            child: Stack(
              children: [
                Stack(
                  children: [
                    Image.asset("assets/images/Background@2x.png",
                        fit: BoxFit.fill, height: height / 3, width: width),
                    Padding(
                      padding: const EdgeInsets.only(top: 70.0),
                      child: Image.asset("assets/images/Elements.png",
                          fit: BoxFit.fill, height: height / 3, width: width),
                    )
                  ],
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        child: Column(children: [
                          Container(
                              child: TextFormField(
                                  onSaved: (str) {
                                    if (int.tryParse(str) != null)
                                      con.user.phone = str;
                                  },
                                  cursorColor: Color(0xffbad600),
                                  validator: hp.validatePhoneNumber,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                      // prefixStyle: TextStyle(
                                      //     color: Colors.black,
                                      //     fontWeight: FontWeight.w600,
                                      //     fontSize: 17.179869184),
                                      // prefix: IntrinsicHeight(
                                      //   child: Row(
                                      //     children: [
                                      //       // Text("+91"),
                                      //       Flexible(
                                      //           child: Text("+91",
                                      //               style: TextStyle(
                                      //                   color: Colors.black,
                                      //                   fontSize: 17.179869184,
                                      //                   fontWeight:
                                      //                       FontWeight.w600))),
                                      //       VerticalDivider(
                                      //           thickness: 1,
                                      //           color: Color(0xff707070),
                                      //           indent: 0,
                                      //           endIndent: 0,
                                      //           width: 1)
                                      //     ],
                                      //   ),
                                      // ),
                                      // ,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          "+91",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17.179869184),
                                        ),
                                      ),
                                      // prefixText: "+91",
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffBAD600)),
                                        borderRadius:
                                            BorderRadius.circular(radius / 200),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffBAD600)),
                                        borderRadius:
                                            BorderRadius.circular(radius / 200),
                                      )),
                                  controller: tc,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17.179869184)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: width / 25,
                                  vertical: height / 16)),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: FittedBox(
                                child: Row(children: [
                              Text("We will Send a ",
                                  style: TextStyle(
                                      color: Color(0xff1D1707),
                                      fontSize: 13.1072,
                                      fontWeight: FontWeight.w500)),
                              Text("One Time Password",
                                  style: TextStyle(
                                      fontSize: 13.1072,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffa11414))),
                              Text(" to your",
                                  style: TextStyle(
                                      color: Color(0xff1D1707),
                                      fontSize: 13.1072,
                                      fontWeight: FontWeight.w500))
                            ], mainAxisAlignment: MainAxisAlignment.center)),
                          ),
                          Container(
                            child: Text("Mobile Number",
                                style: TextStyle(
                                    color: Color(0xff1D1707),
                                    fontSize: 13.1072,
                                    fontWeight: FontWeight.w500)),
                            padding: EdgeInsets.only(bottom: height / 40),
                            // height: height / 4,
                            // decoration: BoxDecoration(),
                          ),
                          MyButton(
                              dimensions: dimensions,
                              radiusFactor: 0,
                              label: isloading ? "Sending..." : "SEND OTP",
                              labelSize: 20,
                              labelWeight: FontWeight.w700,
                              elevation: 0,
                              heightFactor: 80,
                              widthFactor: 2.88230376151711744,
                              color: isloading ? 0xff817C7C : 0xffa11414,
                              onPressed: () async {
                                isloading ? null : putData();
                                setState(() {
                                  isloading = true;
                                });
                              })
                        ], mainAxisAlignment: MainAxisAlignment.spaceAround),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(radius / 50))),
                        height: height / 2.4 //2.88230376151711744
                        ))
              ],
            ),
            key: con.loginFormKey),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getData();
  }

  void putData() async {
    setState(() {
      isloading = true;
    });
    if (tc.text.isNotEmpty &&
        tc.text.length == 10 &&
        int.tryParse(tc.text) != null &&
        con.loginFormKey.currentState.validate()) {
      con.user.phone = tc.text;
      await con.getOTP();
      setState(() {
        isloading = false;
      });
    } else {
      final p =
          await Fluttertoast.showToast(msg: "Please Enter Valid Phone No");
      if (p) print("Hi");
    }
    setState(() {
      isloading = false;
    });
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    if (sharedPrefs.containsKey("spCustomerID")) {
      final p = await Navigator.of(context).pushNamedAndRemoveUntil(
          '/pages', hp.predicate,
          arguments: RouteArgument(heroTag: "0"));
      print(p);
    }
  }
}
