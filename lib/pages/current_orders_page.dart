import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/active_orders_list_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentOrdersPage extends StatefulWidget {
  final String routePath;

  const CurrentOrdersPage({Key key, this.routePath}) : super(key: key);
  @override
  StateMVC<StatefulWidget> createState() => CurrentOrdersPageState();
}

class CurrentOrdersPageState extends StateMVC<CurrentOrdersPage> {
  HotelController con;
  int page = 1;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  final firebaseMessaging = FirebaseMessaging.instance;
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Foodigo2021', // id
    'Foodigo', // title
    'Foodigo food delivery app', // description
    importance: Importance.high,
    enableVibration: true,
    // priority: Priority.Max,
    enableLights: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('loud_notification'),
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  CurrentOrdersPageState() : super(HotelController()) {
    con = controller;
  }

  void fireBaseListener(RemoteMessage message) async {
    print("Firebase Push Notification Arrived");
    final sharedPrefs = await _sharedPrefs;
    final notification = message.notification;
    final android = message.notification?.android;
    final ios = notification.apple;
    final androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channel.description,
      icon: android?.smallIcon,
      playSound: true,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('loud_notification'),
    );
    final iosNotificationDetails = IOSNotificationDetails(
        threadIdentifier: ios.subtitleLocKey,
        sound: ios.sound.name,
        subtitle: ios.subtitle,
        presentAlert: ios.sound.critical,
        presentBadge: true,
        presentSound: true);
    final notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    if (!(notification == null || android == null || ios == null)) {
      await flutterLocalNotificationsPlugin.show(notification.hashCode,
          notification.title, notification.body, notificationDetails);
      await con.waitForCurrentOrders(
          int.tryParse(sharedPrefs.getString("spCustomerID") ?? "-1") ?? -1,
          "1");
    }
  }

  Future notificationSelected(String payload) async {
    print(payload);
    return Navigator.of(context).pushNamed('/currentOrders');
  }

  Future onDidReceiveLocalNotification(
      int n, String str1, String str2, String str3) {
    print(n);
    print(str1);
    print(str2);
    print(str3);
    return notificationSelected(str1 + str2 + str3);
  }

  Future<bool> onWillPop() async {
    final sharedPrefs = await _sharedPrefs;
    print(widget.routePath);
    if (widget.routePath == "Home")
      hp.popAndPush('/pages',
          arguments: RouteArgument(
              id: sharedPrefs.getString("spCustomerID"), heroTag: "0"));
    else
      hp.goBack();
    return false;
  }

  void backButtonPress() async {
    final sharedPrefs = await _sharedPrefs;
    if (widget.routePath == "Home")
      hp.popAndPush('/pages',
          arguments: RouteArgument(
              id: sharedPrefs.getString("spCustomerID"), heroTag: "0"));
    else
      hp.goBack();
  }

  void getData() async {
    try {
      if (mounted) {
        hp.getConnectStatus();
        hp.lockScreenRotation();
      }
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
          sound: true, badge: true, alert: true);
      final b = await firebaseMessaging.requestPermission(
          sound: true, badge: true, alert: true);
      final initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/logo');
      final initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      final initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      final c = await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onSelectNotification: notificationSelected);
      FirebaseMessaging.onMessage.listen(fireBaseListener);
      if (c)
        setState(() {
          print(b);
        });
    } catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
            key: con.scaffoldKey,
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Color(0xffFBFBFB),
                centerTitle: true,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: backButtonPress),
                title: Text(hp.loc.recent_orders,
                    style: TextStyle(color: Colors.black))),
            body: ActiveOrdersListWidget(),
            backgroundColor: Color(0xfff3f2f2)));
  }

  @override
  void dispose() {
    // hp.rollbackOrientations();
    super.dispose();
  }
}
