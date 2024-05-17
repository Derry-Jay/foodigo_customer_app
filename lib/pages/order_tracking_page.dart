import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingPage extends StatefulWidget {
  final Order order;
  OrderTrackingPage(this.order);
  @override
  State<StatefulWidget> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends StateMVC<OrderTrackingPage>
    with AutomaticKeepAliveClientMixin {
  HotelController con;
  Helper get hp => Helper.of(context);
  Location location = Location();
  LocationData customerLocation, driverLocation, hotelLocation;
  BitmapDescriptor driverIcon, customerIcon, hotelIcon;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  Timer timer;
  var imgBase, customerID;
  OrderTrackingPageState() : super(HotelController()) {
    con = controller;
  }

  void updatePinOnMap() {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    // final currentLocation = await location.getLocation();
    final GoogleMapController controller = con.controller;
    final pinPosition = con.driverLoction; //widget.order.driverLoc;
    CameraPosition cPosition = CameraPosition(zoom: 17.0, target: pinPosition);
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      con.markers.removeWhere((m) => m.markerId.value == "driverPin");
      con.markers.add(Marker(
          rotation: driverLocation.heading,
          markerId: MarkerId("driverPin"),
          position: pinPosition, // updated position
          icon: driverIcon));
    });
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    final pinPosition = widget.order.driverLoc;
    final hotelPosition = widget.order.hotelLoc;
    final destPosition = widget.order.customerLoc;
    // add the initial source location pin
    setState(() {
      con.markers.add(Marker(
          rotation: LocationData.fromMap(hp.locationToMap(pinPosition)).heading,
          markerId: MarkerId('driverPin'),
          position: pinPosition,
          icon: driverIcon));
      con.markers.add(Marker(
          markerId: MarkerId('hotelPin'),
          position: hotelPosition,
          icon: hotelIcon));
      con.markers.add(Marker(
          markerId: MarkerId('customerPin'),
          position: destPosition,
          icon: customerIcon));
    });
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setLines(driverLocation, hotelLocation);
    setLines(hotelLocation, customerLocation);
  }

  void setSourceAndDestinationIcons() async {
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: height / width),
        'assets/images/driver_marker.png');
    hotelIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: height / width),
        'assets/images/restaurant_marker.png');
    customerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: height / width),
        'assets/images/customer_marker.png');
  }

  void setInitialLocation() {
    final pinPosition = widget.order.driverLoc;
    final hotelPosition = widget.order.hotelLoc;
    final destPosition = widget.order.customerLoc;
    customerLocation = LocationData.fromMap(hp.locationToMap(pinPosition));
    hotelLocation = LocationData.fromMap(hp.locationToMap(hotelPosition));
    driverLocation = LocationData.fromMap(hp.locationToMap(destPosition));
    con.initialCameraPosition = CameraPosition(target: pinPosition, zoom: 25);
  }

  void setLines(LocationData l1, LocationData l2) async {
    final result = await con.polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyA8LY3WgnfY0_FVP1ZwgLPibpOM_qk5X5Q",
        PointLatLng(l1.latitude, l1.longitude),
        PointLatLng(l2.latitude, l2.longitude));
    List<PointLatLng> points = result.points;
    if (points.isNotEmpty) {
      points.forEach((PointLatLng point) {
        con.polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        con.polyLines.add(Polyline(
            width: 1, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color(0xffA11414),
            points: con.polylineCoordinates,
            patterns: <PatternItem>[PatternItem.dash(10), PatternItem.gap(5)]));
      });
    }
  }

  void onMapCreated(GoogleMapController controller) {
    con.controller = controller;
    //_controller = controller;
    showPinsOnMap();
  }

  getimgbase() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    setState(() {
      imgBase = sharedPrefs.getString("imgBase");
      customerID = sharedPrefs.getString("spCustomerID");
    });
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, assignState);
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => setDriverPin());
  }

  void assignState() async {
    final b = await firebaseMessaging.requestPermission(
        sound: true, badge: true, alert: true);
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo');
    final initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    final f = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: notificationSelected);
    if (f) {
      getimgbase();
      hp.getConnectStatus();
      con.waitForHotelData(widget.order.hotelID);
      con.waitForOrderedFood(widget.order.orderID);
      con.waitForDriverDetails(widget.order.driverID);
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
          sound: true, badge: true, alert: true);
      FirebaseMessaging.onMessage.listen(fcmListener);
      hp.lockScreenRotation();
      setSourceAndDestinationIcons();
      // set the initial location
      setInitialLocation();
      print(b);
      //onMapCreated(GoogleMapController controller);
      // set custom marker pins
      // location.onLocationChanged.listen((LocationData cLoc) {
      //   // cLoc contains the lat and long of the
      //   // current user's position in real time,
      //   // so we're holding on to it
      //   driverLocation = cLoc;
      //updatePinOnMap();
      // });
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

  void setDriverPin() async {
    await con.waitForgetdriverLoc(widget.order.orderID);
    updatePinOnMap();
  }

  void fcmListener(RemoteMessage message) async {
    print("Firebase Push Notification Arrived");
    RemoteNotification notification = message.notification;
    AndroidNotification android = notification?.android;
    AppleNotification apple = notification.apple;
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id, channel.name, channel.description,
            icon: android?.smallIcon,
            playSound: true,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('loud_notification'));
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails(
        threadIdentifier: apple.subtitleLocKey,
        sound: apple.sound.name,
        subtitle: apple.subtitle,
        presentAlert: apple.sound.critical,
        presentBadge: true,
        presentSound: true);
    final notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    if (!(notification == null || android == null || apple == null))
      await flutterLocalNotificationsPlugin.show(notification.hashCode,
          notification.title, notification.body, notificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return Scaffold(
        body:
            widget.order.driverLoc.latitude == 0.0 &&
                    widget.order.driverLoc.longitude == 0.0
                ? hp.getPageLoader(size)
                : Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: con.initialCameraPosition,
                        onMapCreated: onMapCreated,
                        markers: con.markers,
                        polylines: con.polyLines,
                      ),
                      Align(
                          child: Container(
                              height: height / 3.2,
                              child: Column(
                                  children: [
                                    Expanded(
                                        child: Container(
                                            child: Row(
                                                children: [
                                                  Text(
                                                      "Estimated Arrival : " +
                                                          (hp.travelTime2(
                                                                  widget.order
                                                                      .customerLoc,
                                                                  widget.order
                                                                      .driverLoc,
                                                                  widget.order
                                                                      .driverLoc,
                                                                  widget.order
                                                                      .hotelLoc))
                                                              .ceil()
                                                              .toString() +
                                                          "Mins",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff200303),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12)),
                                                  Text(
                                                      "Distance : " +
                                                          (hp.distanceInKM(
                                                                      widget
                                                                          .order
                                                                          .customerLoc,
                                                                      widget
                                                                          .order
                                                                          .driverLoc) +
                                                                  hp.distanceInKM(
                                                                      widget
                                                                          .order
                                                                          .driverLoc,
                                                                      widget
                                                                          .order
                                                                          .hotelLoc))
                                                              .ceil()
                                                              .toString() +
                                                          " Kms",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff200303),
                                                          fontWeight:
                                                              FontWeight.w400))
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween),
                                            decoration: BoxDecoration(
                                                color: Color(0xffBAD600),
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            radius / 160))),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 32,
                                                vertical: height / 1000),
                                            margin: EdgeInsets.only(
                                                bottom: height / 50))),
                                    Expanded(
                                        child: Row(
                                            children: [
                                          Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: width / 25,
                                                      left: width / 25),
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: con.hotel == null
                                                              ? AssetImage(
                                                                  "assets/images/loading.gif")
                                                              : (con.hotel.imageLink == null ||
                                                                      con
                                                                          .hotel
                                                                          .imageLink
                                                                          .isEmpty
                                                                  ? AssetImage(
                                                                      "assets/images/loading.gif")
                                                                  : NetworkImage(
                                                                      imgBase +
                                                                          con.hotel
                                                                              .sthreeurl)),
                                                          fit: BoxFit.fill),
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(radius / 160))))),
                                          // SizedBox(
                                          //   width: width / 16
                                          // ),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Text(
                                                            "Order ID: #" +
                                                                widget.order
                                                                    .orderID
                                                                    .toString(),
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff200303),
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))),
                                                    Expanded(
                                                        child: Text(
                                                            con.hotel == null
                                                                ? ""
                                                                : (con.hotel.restName ==
                                                                            null ||
                                                                        con
                                                                            .hotel
                                                                            .restName
                                                                            .isEmpty
                                                                    ? ""
                                                                    : con.hotel
                                                                        .restName),
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff1D1707),
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500))),
                                                    Expanded(
                                                        child: Text(
                                                            (con.orderedFoods ==
                                                                        null
                                                                    ? "0"
                                                                    : con
                                                                        .orderedFoods
                                                                        .length
                                                                        .toString()) +
                                                                " ITEMS",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff676666),
                                                                fontSize: 8,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500))),
                                                    // SizedBox(
                                                    //   width: width / 32
                                                    // ),
                                                    Expanded(
                                                        child: Text(
                                                            "Amount Paid: ₹ " +
                                                                widget.order
                                                                    .total,
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xff200303))))
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly)),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                            "OTP: " +
                                                                widget.order.otp
                                                                    .toString(),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .white)),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                                vertical:
                                                                    height /
                                                                        160,
                                                                horizontal:
                                                                    width / 50),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xffA11414),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(radius)))),
                                                    // Text("View More",
                                                    //     style: TextStyle(
                                                    //         fontSize: 10,
                                                    //         color: Color(0xffA11414),
                                                    //         fontWeight: FontWeight.w600))
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween))
                                        ],
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween)),
                                    Expanded(
                                        child: Container(
                                            child: Row(
                                                children: [
                                                  Text(widget.order.orderStatus,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff181C02),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12)),
                                                  // Text("Track Order",
                                                  //     style: TextStyle(
                                                  //         fontWeight: FontWeight.w600,
                                                  //         fontSize: 10))
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween),
                                            decoration: BoxDecoration(
                                              color: Color(0xffFCEAEA),
                                              // borderRadius: BorderRadius.all(Radius.circular(radius / 100)),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                vertical: height / 64),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 25))),
                                    Expanded(
                                      child: Row(
                                          children: [
                                            Padding(
                                                child: ClipRRect(
                                                    child: CachedNetworkImage(
                                                        imageUrl: con.driver ==
                                                                null
                                                            ? ""
                                                            : con.driver.image
                                                                .thumb,
                                                        errorWidget:
                                                            hp.getErrorWidget,
                                                        placeholder:
                                                            hp.getPlaceHolder,
                                                        fit: BoxFit.fill,
                                                        height: height / 5,
                                                        width: width / 6.4),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                radius / 160))),
                                                padding: EdgeInsets.only(
                                                    right: width / 50,
                                                    bottom: height / 128,
                                                    left: width / 40)),
                                            Expanded(
                                                child: Column(
                                                    children: <Widget>[
                                                  Expanded(
                                                      child: Text(
                                                          con.driver == null
                                                              ? "Driver Name Unavailable"
                                                              : (con.driver.name ==
                                                                          null ||
                                                                      con
                                                                          .driver
                                                                          .name
                                                                          .isEmpty
                                                                  ? "Driver Name Unavailable"
                                                                  : con.driver
                                                                      .name),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))),
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 15.0),
                                                    child: Row(
                                                        children: [
                                                          Row(
                                                              children: [
                                                                Image.asset(
                                                                    "assets/images/star.png",
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    height:
                                                                        height /
                                                                            64,
                                                                    width:
                                                                        width /
                                                                            32),
                                                                Text(
                                                                    con.hotel ==
                                                                            null
                                                                        ? "0.0"
                                                                        : (con.hotel.rating ==
                                                                                null
                                                                            ? "0.0"
                                                                            : con.hotel.rating +
                                                                                ".0"),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            14))
                                                              ],
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween),
                                                          Row(
                                                            children: [
                                                              InkWell(
                                                                  child: Container(
                                                                      child: Image.asset('assets/images/phone-call (7).png', height: height / 10, width: width / 20, fit: BoxFit.fitHeight),
                                                                      //             margin: EdgeInsets.only(
                                                                      //   bottom: height / 100,
                                                                      // right: width / 100),
                                                                      padding: EdgeInsets.symmetric(horizontal: width / 64, vertical: height / 128),
                                                                      decoration: BoxDecoration(color: Color(0xffF6F6F6), borderRadius: BorderRadius.all(Radius.circular(radius / 160)))),
                                                                  onTap: () async {
                                                                    final p = await launch(
                                                                        "tel://" +
                                                                            con.driver.phone);
                                                                    if (p)
                                                                      print(
                                                                          "Hi");
                                                                  }),
                                                              SizedBox(
                                                                width:
                                                                    width / 10,
                                                              ),
                                                              InkWell(
                                                                  child: Container(
                                                                      child: Image.asset('assets/images/headphone.png', color: Color(0xffbad600), height: height / 10, width: width / 20, fit: BoxFit.fitHeight),
                                                                      //             margin: EdgeInsets.only(
                                                                      //   bottom: height / 100,
                                                                      // right: width / 100),
                                                                      padding: EdgeInsets.symmetric(horizontal: width / 64, vertical: height / 128),
                                                                      decoration: BoxDecoration(color: Color(0xffF6F6F6), borderRadius: BorderRadius.all(Radius.circular(radius / 160)))),
                                                                  onTap: () async {
                                                                    final p =
                                                                        await launch(
                                                                            "tel://18002085234");
                                                                    if (p)
                                                                      print(
                                                                          "Hi");
                                                                  })
                                                            ],
                                                          ),
                                                        ],
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween),
                                                  ))
                                                ],
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start))
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround),
                                    )
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(radius / 100)),
                                // color: Color(0xfff7f7f7),
                                color: Colors.white,
                              )),
                          alignment: Alignment.bottomCenter)
                    ],
                  ));
  }

  @override
  void dispose() {
    hp.rollbackOrientations();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
