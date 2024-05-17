import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpPage extends StatefulWidget {
  final RouteArgument rar;
  OtpPage(this.rar);
  @override
  State<StatefulWidget> createState() => OtpPageState();
}

class OtpPageState extends StateMVC<OtpPage> {
  UserController con;
  final saf = SmsAutoFill();
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  List<TextEditingController> tec = <TextEditingController>[];
  S get loc => S.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  OtpPageState() : super(UserController()) {
    con = controller;
  }
  bool isotp = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            backwardsCompatibility: false,
            foregroundColor: Colors.black,
            title: Text(loc.verify + "OTP",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            backgroundColor: Color(0xffFBFBFB),
            elevation: 0),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: height / 20),
            Container(
              child: Text("Please type the verification code sent to your",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.4115188075855872,
                      fontWeight: FontWeight.w400)),
              padding: EdgeInsets.symmetric(horizontal: width / 20),
            ),
            Row(children: [
              Text("phone number ",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.4115188075855872)),
              Text("+91 " + widget.rar.heroTag,
                  style: TextStyle(
                      color: Color(0xffa11414),
                      fontWeight: FontWeight.w500,
                      fontSize: 14.4115188075855872))
            ], mainAxisAlignment: MainAxisAlignment.center),
            Container(
              child: generateTextBox(6),
              padding: EdgeInsets.symmetric(
                  horizontal: width / 16, vertical: height / 40),
            ),
            Container(
                child: InkWell(
                    child: Row(children: [
                      Text("Didn't get OTP? ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.4115188075855872)),
                      Text("Resend Code",
                          style: TextStyle(
                              color: Color(0xffa11414),
                              fontWeight: FontWeight.w700,
                              fontSize: 14.4115188075855872))
                    ], mainAxisAlignment: MainAxisAlignment.center),
                    onTap: () {
                      con.user.phone = widget.rar.heroTag;
                      con.resendOTP();
                    }),
                // color: Color(0x996dbbe8),
                padding: EdgeInsets.only(
                    right: width / 8,
                    top: height / 20,
                    bottom: height / 16,
                    left: width / 8)),
            TextButton(
                onPressed: () async {
                  final sharedPrefs = await _sharedPrefs;
                  String otp = "";
                  tec.forEach((element) {
                    otp += element.text;
                  });
                  Map<String, dynamic> body = {
                    "mobileno": widget.rar.heroTag,
                    "otp": int.tryParse(otp) == widget.rar.param
                        ? widget.rar.param.toString()
                        : otp,
                    "device_token": sharedPrefs.getString("spDeviceToken")
                  };
                  print(body);
                  isotp ? await con.checkOTP(body) : print("Hi");
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                        horizontal: width / 5, vertical: height / 80)),
                    foregroundColor:
                        MaterialStateProperty.all(Color(0xffFFFFFF)),
                    backgroundColor: MaterialStateProperty.all(
                        isotp ? Color(0xffA11414) : Color(0xff817C7C))),
                child: Text(
                  "VERIFY",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ))
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
        ));
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget generateTextBox(int c) {
    return Row(
      children: [
        for (int i = 1; i <= c; i++)
          Expanded(
              child: Container(
                  child: TextField(
                      textInputAction:
                          i == c ? TextInputAction.done : TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      onChanged: (str) {
                        if (str.length == 1 && i != c) {
                          final n = FocusScope.of(context).nextFocus();
                          if (n) print(str);
                        } else if (str.isEmpty && i != 1) {
                          final p = FocusScope.of(context).previousFocus();
                          setState(() {
                            isotp = false;
                          });
                          if (p) print(str);
                        } else if (i == c) {
                          setState(() {
                            isotp = true;
                          });
                        }
                      },
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.6,
                          fontWeight: FontWeight.w600),
                      cursorColor: Color(0xffBAD600),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(radius / 80),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffBAD600)),
                            borderRadius: BorderRadius.circular(radius / 200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffBAD600)),
                            borderRadius: BorderRadius.circular(radius / 200),
                          )),
                      controller: tec[i - 1]),
                  margin: EdgeInsets.symmetric(horizontal: width / 64)))
      ],
    );
  }

  void getTEC(int n) {
    for (int i = 1; i <= n; i++) tec.add(new TextEditingController());
  }

  void getData() async {
    getTEC(6);
    await saf.listenForCode;
    print("===========");
    print(await saf.code.first);
    print("+++++++++++++");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    saf.unregisterListener();
  }
}
