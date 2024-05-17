import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../helpers/custom_trace.dart';
import '../repos/settings_repos.dart' as settingRepo;
import '../repos/user_repos.dart' as userRepo;

class SplashScreenController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());

  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  void putData() async {
    configureFirebase();
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        setState(() => progress.value["User"] = 59);
        progress.notifyListeners();
      }
    });
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null &&
          settingRepo.setting.value.appName != '' &&
          settingRepo.setting.value.mainColor != null) {
        setState(() => progress.value["Setting"] = 41);
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        progress?.notifyListeners();
      }
    });
    Timer(Duration(seconds: 20), () {
      // ScaffoldMessenger.of(stateMVC.context).showSnackBar(SnackBar(
      //   content: Text(S.of(stateMVC.context).verify_your_internet_connection),
      // ));
    });
  }

  @override
  void initState() {
    super.initState();
    putData();
  }

  void configureFirebase() async {
    try {
      final fireApp = await Firebase.initializeApp(
          name: "com.foodigo.customer",
          options: FirebaseOptions(
              apiKey: "AIzaSyABlBPa8TkwMW6FQrkCMyZ_Whzk4gMnFHE",
              appId: "1:649931483249:android:9ec097bfcba0cf822113d0",
              messagingSenderId: "Foodigo",
              projectId: "customer-537ad"));
      final firebaseMessaging = FirebaseMessaging.instance;
      final sharedPrefs = await SharedPreferences.getInstance();
      final perms = await firebaseMessaging.requestPermission(
          sound: true, badge: true, alert: true);
      final notSet = await firebaseMessaging.getNotificationSettings();
      final token1 = await firebaseMessaging.getAPNSToken();
      final token2 = await firebaseMessaging.getToken();
      final flag = await sharedPrefs.setString("spDeviceToken", token2);
      if (flag) {
        print(perms);
        print("Device Token: " + token2);
        print(token1);
        print("Token 1:" + token2);
        print(notSet);
        getData(fireApp);
      }
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        final fireApp = Firebase.app('com.foodigo.customer');
        getData(fireApp);
      } else {
        print(e);
        throw e;
      }
    } catch (e) {
      print("Hi");
      print(e);
      print("Delivered");
      print(CustomTrace(StackTrace.current, message: e.toString()));
      print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
    }
  }

  Future notificationOnResume(Map<String, dynamic> message) async {
    print(CustomTrace(StackTrace.current, message: message['data']['id']));
    try {
      if (message['data']['id'] == "orders") {
        settingRepo.navigatorKey.currentState
            .pushReplacementNamed('/Pages', arguments: 3);
      } else if (message['data']['id'] == "messages") {
        settingRepo.navigatorKey.currentState
            .pushReplacementNamed('/Pages', arguments: 4);
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    String messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message['google.message_id']) {
        await settingRepo.saveMessageId(message['google.message_id']);
        if (message['data']['id'] == "orders") {
          settingRepo.navigatorKey.currentState
              .pushReplacementNamed('/Pages', arguments: 3);
        } else if (message['data']['id'] == "messages") {
          settingRepo.navigatorKey.currentState
              .pushReplacementNamed('/Pages', arguments: 4);
        }
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
    Fluttertoast.showToast(
      msg: message['notification']['title'],
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 6,
    );
  }

  void getData(FirebaseApp app) async {
    try {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      final initializationSettingsAndroid =
          AndroidInitializationSettings('launcher_icon');
      final initializationSettingsIOS = IOSInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
            final p = await Navigator.pushReplacementNamed(
                stateMVC.context, '/currentOrders');
            print(payload);
            print(title);
            print(app);
            print(body);
            print(p);
          });
      final initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      final p = await flutterLocalNotificationsPlugin.initialize(
          initializationSettings, onSelectNotification: (String payload) async {
        print(payload);
        print(app);
      });
      if (p) print("Hi");
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
