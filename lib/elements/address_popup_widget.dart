import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_button.dart';

class AddressPopupWidget extends StatefulWidget {
  @override
  AddressPopupWidgetState createState() => AddressPopupWidgetState();
}

class AddressPopupWidgetState extends StateMVC<AddressPopupWidget> {
  UserController con;
  String d1, d2, al;
  LocationData currentLocation;
  Map<String, dynamic> addressData;
  List<bool> selected;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  AddressPopupWidgetState() : super(UserController()) {
    con = controller;
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    print(sharedPrefs.getString("spCustomerID"));
    addressData = sharedPrefs.containsKey("defaultAddress")
        ? json.decode(sharedPrefs.getString("defaultAddress"))
        : Map<String, dynamic>();
    con.waitForDeliveryAddresses();
    if (addressData.isNotEmpty) {
      d1 = addressData["area"];
      d2 = addressData["clipped_address"];
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (selected == null && con.addresses != null)
      selected = List.filled(con.addresses.length, false, growable: true);
    return WillPopScope(
      onWillPop: hp.onWillPop,
      child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(radius / 100)),
                      color: Color(0xffFCEAEA)),
                  height: height / 16,
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 25, vertical: height / 100),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            new SvgPicture.asset(
                                'assets/images/location-svg.svg'),
                            // Image.asset("assets/images/placeholder.png",
                            //     fit: BoxFit.fill, height: height / 32),
                            SizedBox(width: width / 50),
                            d1 == null || d2 == null
                                ? Text(hp.loc.your_address,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.8,
                                        color: Colors.black))
                                : Column(children: [
                                    Expanded(
                                      child: Text(d1,
                                          style: TextStyle(
                                              color: Color(0xff181c02),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Expanded(
                                        child: Text(d2,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff200303))))
                                  ])
                          ],
                        )),
                        // GestureDetector(
                        //     child: Image.asset("assets/images/map_button.png"),
                        //     onTap: getCurrentLocation)
                        MyButton(
                            label: hp.loc.add_delivery_address.toUpperCase(),
                            dimensions: dimensions,
                            labelSize: 11.52921504606846976,
                            heightFactor: 100,
                            widthFactor: 40,
                            elevation: 5,
                            labelWeight: FontWeight.w700,
                            radiusFactor: 160,
                            onPressed: () {
                              hp.navigateTo('/addLocation', onGoBack: onGoBack);
                            })
                      ])),
              // Container(
              //     margin: EdgeInsets.symmetric(vertical: height / 80),
              //     child: InkWell(
              //         borderRadius: BorderRadius.circular(radius * 2),
              //         child: Column(
              //           children: [
              //             Container(
              //               margin: EdgeInsets.symmetric(
              //                   vertical: height / 80, horizontal: width / 20),
              //               child: Row(
              //                 children: [
              //                   Icon(Icons.search, color: Colors.black),
              //                   Container(
              //                       padding: EdgeInsets.only(left: width / 25),
              //                       child: Text("Enter Location Manually",
              //                           style: TextStyle(
              //                               color: Colors.black,
              //                               fontSize: 16,
              //                               fontWeight: FontWeight.w500)))
              //                 ],
              //               ),
              //               // color: Colors.lightGreenAccent,
              //               // height:
              //             ),
              //             DottedLine()
              //           ],
              //         ),
              //         onTap: () {
              //           Navigator.of(context).pushNamed("/searchLocation"
              //               // , arguments: RouteArgument(
              //               //     id: hotel.restID.toString(),
              //               //     heroTag: hotel.restName,
              //               //     param: hotel)
              //               );
              //         })),
              Expanded(
                  child: con.addresses == null
                      ? Image.asset("assets/images/loading_card.gif",
                          fit: BoxFit.fill)
                      : ListView.builder(
                          itemBuilder: (context, int index) => GestureDetector(
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / 10,
                                      vertical: height / 200),
                                  color: selected[index]
                                      ? Color(0xffbad600)
                                      : Color(0xffE2E0E0),
                                  child: Column(
                                      children: [
                                        Text(
                                            con.addresses[index].title ??
                                                "No Title Available",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff110202),
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(height: size.height / 128),
                                        Text(
                                            con.addresses[index].fullAddress ??
                                                "No Address Available",
                                            style: TextStyle(
                                                color: Color(0xff110202),
                                                fontWeight: FontWeight.w400)),
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly),
                                  margin: EdgeInsets.symmetric(
                                      vertical: height / 64)),
                              onTap: () async {
                                final address =
                                    con.addresses[selected.indexOf(true)];
                                final coordinates = new Coordinates(
                                    address.location.latitude,
                                    address.location.longitude);
                                final addList = await Geocoder.local
                                    .findAddressesFromCoordinates(coordinates);
                                final add = addList.first;
                                al = add.addressLine;
                                setState(() {
                                  if (selected.indexOf(true) == -1)
                                    selected[index] = true;
                                  else {
                                    selected[selected.indexOf(true)] = false;
                                    selected[index] = true;
                                  }
                                  d1 = add.subLocality == null ||
                                          add.subLocality.isEmpty
                                      ? add.featureName
                                      : add.subLocality;
                                  d2 = (add.subAdminArea ?? add.locality) +
                                      " - " +
                                      add.postalCode;
                                });
                              }),
                          itemCount: con.addresses.length,
                        )),
              TextButton(
                  onPressed: selected == null
                      ? null
                      : (selected.indexOf(true) == -1 &&
                              d1 == null &&
                              d2 == null
                          ? null
                          : () async {
                              final sharedPrefs = await _sharedPrefs;
                              final address =
                                  con.addresses[selected.indexOf(true)];
                              final lat = currentLocation == null
                                  ? (address == null
                                      ? 0.0
                                      : (address.location == null
                                          ? 0.0
                                          : address.location.latitude))
                                  : currentLocation.latitude;
                              final long = currentLocation == null
                                  ? (address == null
                                      ? 0.0
                                      : (address.location == null
                                          ? 0.0
                                          : address.location.longitude))
                                  : currentLocation.longitude;
                              final p = await sharedPrefs.setString(
                                  "defaultAddress",
                                  json.encode({
                                    "addressID": address.addressID,
                                    "type": address.title,
                                    "area": d1,
                                    "clipped_address": d2,
                                    "latitude": lat,
                                    "longitude": long,
                                    "address": al
                                  }));
                              if (p)
                                hp.navigateWithoutGoBack('/pages',
                                    arguments: RouteArgument(
                                        id: sharedPrefs
                                            .getString("spCustomerID"),
                                        heroTag: "0"));
                            }),
                  child: Text("USE THIS LOCATION",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          horizontal: size.width / 20,
                          vertical: size.height / 100)),
                      foregroundColor: MaterialStateProperty.all(
                          selected == null
                              ? Color(0xff676666)
                              : (selected.indexOf(true) == -1 &&
                                      d1 == null &&
                                      d2 == null
                                  ? Color(0xff676666)
                                  : Color(0xffFFFFFF))),
                      backgroundColor: MaterialStateProperty.all(
                          selected == null
                              ? Color(0xffE2E0E0)
                              : (selected.indexOf(true) == -1 &&
                                      d1 == null &&
                                      d2 == null
                                  ? Color(0xffE2E0E0)
                                  : Color(0xffA11414)))))
            ],
          ),
          decoration: BoxDecoration(
              // color: Color(0xff9ccaac),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(radius / 100)))),
    );
  }

  void getCurrentLocation() async {
    try {
      final sharedPrefs = await _sharedPrefs;
      final location = new Location();
      // final permission = await location.hasPermission();
      // print(permission == PermissionStatus.granted);
      currentLocation = await location.getLocation();
      if (currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0) {
        print("locationLatitude: ${currentLocation.latitude}");
        print("locationLongitude: ${currentLocation.longitude}");
        final coordinates = new Coordinates(
            currentLocation.latitude, currentLocation.longitude);
        final ads =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        final address = ads.first;
        // setState(() {
        d1 = address.subLocality == null || address.subLocality.isEmpty
            ? address.featureName
            : address.subLocality;
        d2 = (address.subAdminArea ?? address.locality) +
            " - " +
            address.postalCode;
        // });
        final p = await sharedPrefs.setString(
            "defaultAddress",
            json.encode({
              // "addressID": address.addressID,
              // "type": address.,
              "area": d1,
              "clipped_address": d2,
              "latitude": address.coordinates.latitude,
              "longitude": address.coordinates.longitude,
              "address": address.addressLine
            }));
        if (p)
          Navigator.pushNamedAndRemoveUntil(
              context, '/pages', (Route<dynamic> route) => false,
              arguments: RouteArgument(
                  id: sharedPrefs.getString("spCustomerID"), heroTag: "0"));
      } else
        setState(() => con.initialCameraPosition =
            CameraPosition(target: LatLng(13.0827, 80.2707), zoom: 17));
    } catch (e) {
      print(e);
      // currentLocation = null;
      // setState(() => con.initialCameraPosition =
      //     CameraPosition(target: LatLng(13.0827, 80.2707), zoom: 17));
      throw e;
    }
  }

  FutureOr onGoBack(dynamic value) async {
    setState(() {
      con.waitForDeliveryAddresses();
      selected.add(false);
    });
  }
}
