import 'dart:async';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController con;
  final _sharedPrefs = SharedPreferences.getInstance();
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  Timer timer;

  SplashScreenState() : super(SplashScreenController()) {
    con = controller;
  }

  @override
  void initState() {
    super.initState();
    // timer =
    //     Timer.periodic(Duration(seconds: 5), (Timer t) => getconnect_status());
    getconnect_status();
    loadData();
  }

  void loadData() async {
    final sharedPrefs = await _sharedPrefs;
    // Navigator.of(context).pushReplacementNamed('/pages',
    //     arguments: RouteArgument(
    //         id: sharedPrefs.getString("spCustomerID"), heroTag: "0"));
    con.progress.addListener(() {
      double progress = 0;
      con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        try {
          if (sharedPrefs.containsKey("spCustomerID"))
            Navigator.of(context).pushReplacementNamed('/pages',
                arguments: RouteArgument(
                    id: sharedPrefs.getString("spCustomerID"), heroTag: "0"));
          else
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (Route<dynamic> route) => false);
        } catch (e) {
          print(e);
          print("bye");
        }
      }
    });
  }

  pagemove() async {
    final sharedPrefs = await _sharedPrefs;
    if (sharedPrefs.containsKey("spCustomerID"))
      Navigator.of(context).pushReplacementNamed('/pages',
          arguments: RouteArgument(
              id: sharedPrefs.getString("spCustomerID"), heroTag: "0"));
    else
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void getconnect_status() async {
    print("ConnectivityResult.mobile");
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(ConnectivityResult.mobile);
    if (connectivityResult == ConnectivityResult.none) {
      // I am connected to a mobile network.
      _showalert();
    } else {
      // timer.cancel();
      print("Loaddata");
      pagemove();
    }
  }

  _showalert() async {
    showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
              'Network Status',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            content: new Text(
              'You are not connect with internet',
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  getconnect_status();
                },
                child: new Text('Ok'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: con.scaffoldKey,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/splashscreen.png"),
              fit: BoxFit.cover,
            ),
          ),
        )
        // Container(
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).scaffoldBackgroundColor,
        //   ),
        //   child: Center(
        //     child: Column(
        //       mainAxisSize: MainAxisSize.max,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: <Widget>[
        //         Image.asset(
        //           'assets/images/logo.png',
        //           width: width / 2,
        //           fit: BoxFit.fill,
        //         ),
        //         SizedBox(height: height / 16),
        //         CircularProgressIndicator(
        //           valueColor:
        //               AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        );
  }
}
