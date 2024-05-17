import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foodigo_customer_app/helpers/custom_trace.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/pages/splash_screen.dart';
import 'package:foodigo_customer_app/route_generator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/l10n.dart';
import 'models/setting.dart';
import 'repos/user_repos.dart' as userRepo;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final q = await Firebase.initializeApp();
  await flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          androidChannel.description,
          playSound: true,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('loud_notification'),
        ),
      ));
  print('worked');
  print('Handling a background message ${message.messageId}');
  print(message.notification.title);
  print(q.name);
  print(q.options);
}

const sound = RawResourceAndroidNotificationSound('loud_notification');

const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
    'Foodigo2021', // id
    'Foodigo', // title
    'Foodigo food delivery app', // description
    importance: Importance.high,
    enableVibration: true,
    // priority: Priority.Max,
    enableLights: true,
    playSound: true,
    sound: sound);

const androidPlatformChannel = AndroidNotificationDetails(
    'Foodigo2021', // id
    'Foodigo', // title
    'Foodigo food delivery app', // description
    // color: Color.fromARGB(255, 0, 0, 0),
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    sound: sound,
    showWhen: false);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final p = await GlobalConfiguration().loadFromAsset("configurations");
    final q = await Firebase.initializeApp();
    HttpOverrides.global = new MyHttpOverrides();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    print(q);
    print(CustomTrace(StackTrace.current,
        message: "base_url: ${p.getValue('base_url')}"));
    print(CustomTrace(StackTrace.current,
        message: "api_base_url: ${p.getValue('api_base_url')}"));
    runApp(MyApp());
  } catch (e) {
    print(e);
    throw e;
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final firebaseMessaging = FirebaseMessaging.instance;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);

  @override
  void initState() {
    super.initState();
    hp.lockScreenRotation();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    initFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Setting>(
        model: Setting(),
        child: ScopedModelDescendant<Setting>(builder: appBuilder));
  }

  Widget appBuilder(BuildContext context, Widget child, Setting setting) {
    setting.getLang();
    return MaterialApp(
      title: setting.appName,
      home: SplashScreen(),
      // home: AddATMCardPage(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      locale: setting.mobileLanguage == null
          ? Locale('en', '')
          : setting.mobileLanguage.value,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(
          fontFamily: "Montserrat", brightness: setting.brightness.value
          // ,
          // accentColor: config.Colors().mainColor(1),
          // dividerColor: config.Colors().accentColor(0.1),
          // focusColor: config.Colors().accentColor(1),
          // hintColor: config.Colors().secondColor(1),
          // textTheme: TextTheme(
          //   headline5: TextStyle(
          //       fontSize: 20.0,
          //       color: config.Colors().secondColor(1),
          //       height: 1.35),
          //   headline4: TextStyle(
          //       fontSize: 18.0,
          //       fontWeight: FontWeight.w600,
          //       color: config.Colors().secondColor(1),
          //       height: 1.35),
          //   headline3: TextStyle(
          //       fontSize: 20.0,
          //       fontWeight: FontWeight.w600,
          //       color: config.Colors().secondColor(1),
          //       height: 1.35),
          //   headline2: TextStyle(
          //       fontSize: 22.0,
          //       fontWeight: FontWeight.w700,
          //       color: config.Colors().mainColor(1),
          //       height: 1.35),
          //   headline1: TextStyle(
          //       fontSize: 22.0,
          //       fontWeight: FontWeight.w300,
          //       color: config.Colors().secondColor(1),
          //       height: 1.5),
          //   subtitle1: TextStyle(
          //       fontSize: 15.0,
          //       fontWeight: FontWeight.w500,
          //       color: config.Colors().secondColor(1),
          //       height: 1.35),
          //   headline6: TextStyle(
          //       fontSize: 16.0,
          //       fontWeight: FontWeight.w600,
          //       color: config.Colors().mainColor(1),
          //       height: 1.35),
          //   bodyText2: TextStyle(
          //       fontSize: 12.0,
          //       color: config.Colors().secondColor(1),
          //       height: 1.35),
          //   bodyText1: TextStyle(
          //       fontSize: 14.0,
          //       color: config.Colors().secondColor(1),
          //       height: 1.35),
          //   caption: TextStyle(
          //       fontSize: 12.0,
          //       color: config.Colors().accentColor(1),
          //       height: 1.35),
          // ),
          // primarySwatch: Colors.blue,
          ),
    );
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

  void initFirebase() async {
    try {
      final sharedPrefs = await _sharedPrefs;
      // final conSet = await settingRepo.initSettings();
      // final loc = await settingRepo.getCurrentLocation();
      // print(conSet.mobileLanguage.value.languageCode);
      // print(loc.toMap());
      final pers = await userRepo.getCurrentUser();
      final perms = await firebaseMessaging.requestPermission(
          sound: true, badge: true, alert: true);
      final initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/logo');
      final initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      final initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      final fl = await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onSelectNotification: notificationSelected);
      final fl1 = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
      final str = sharedPrefs.containsKey("spCustomerID")
          ? sharedPrefs.getString("spCustomerID")
          : "";
      final fl2 = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
      final fl3 = pers.id == str &&
          perms.authorizationStatus == AuthorizationStatus.authorized;
      final p = FirebaseMessaging.onMessage.listen(onData);
      FirebaseMessaging.onBackgroundMessage(handler);
      if (fl) {
        await firebaseMessaging.setForegroundNotificationPresentationOptions(
            sound: true, badge: true, alert: true);
        if (!(fl1 || fl2 || fl3)) {
          await p.cancel();
          final q = await p.asFuture();
          print("Hi");
          print(q);
          print("Bye");
        } else {
          print('work');
          print(fl3);
          print('done');
        }
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void onData(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final android = notification?.android;
      final ios = notification.apple;
      final androidNotificationDetails = AndroidNotificationDetails(
          androidChannel.id, androidChannel.name, androidChannel.description,
          icon: android?.smallIcon,
          playSound: true,
          priority: Priority.high,
          sound: sound);
      final iosNotificationDetails = IOSNotificationDetails(
          threadIdentifier: ios.subtitleLocKey,
          sound: ios.sound.name,
          subtitle: ios.subtitle,
          presentAlert: ios.sound.critical,
          presentBadge: true,
          presentSound: true);
      final notificationDetails = NotificationDetails(
          android: androidNotificationDetails, iOS: iosNotificationDetails);
      if (!(notification == null || android == null || ios == null))
        await flutterLocalNotificationsPlugin.show(notification.hashCode,
            notification.title, notification.body, notificationDetails);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> handler(RemoteMessage message) async {
    return message.notification.title == 'Order Accepted'
        ? null
        : firebaseMessagingBackgroundHandler(message);
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
