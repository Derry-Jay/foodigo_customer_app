import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/address.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum addressType { Home, Work, Other }

class AddressEditPage extends StatefulWidget {
  final WhereAbouts address;
  AddressEditPage(this.address);
  @override
  AddressEditPageState createState() => AddressEditPageState();
}

class AddressEditPageState extends StateMVC<AddressEditPage> {
  UserController con;
  LatLng loc;
  TextEditingController tc = new TextEditingController();
  List<Address> addresses;
  addressType at;
  String d1, d2;
  List<Marker> mymarker = [];
  var currentLocation;
  LatLng curLoc;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  AddressEditPageState() : super(UserController()) {
    con = controller;
  }

  void getData() async {
    at = addressType.values.firstWhere((element) =>
        element.toString().toLowerCase() ==
        ("addressType." + widget.address.title).toLowerCase());
    con.initialCameraPosition =
        CameraPosition(target: widget.address.location, zoom: 17.0);
    // mymarker.add(Marker(
    //     markerId: MarkerId('mymarker'),
    //     position: LatLng(widget.address.location.latitude,
    //         widget.address.location.longitude)));
    tc.text = widget.address.fullAddress ?? widget.address.addressLine;
    final point = new Coordinates(
        widget.address.location.latitude, widget.address.location.longitude);
    final addresses = await Geocoder.local.findAddressesFromCoordinates(point);
    final address = addresses.first;
    setState(() {
      d1 = address.subLocality == null || address.subLocality.isEmpty
          ? address.featureName
          : address.subLocality;
      d2 = (address.subAdminArea ?? address.locality) +
          " - " +
          address.postalCode;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    con.controller = controller;
  }

  void setRadioValue(addressType type) {
    setState(() => at = type);
  }

  Future<void> handletap(LatLng tappedpoint) async {
    setState(() {
      mymarker = [];
      mymarker.add(
        Marker(
          markerId: MarkerId(tappedpoint.toString()),
          position: tappedpoint,
        ),
      );
    });
    final coordinates =
        new Coordinates(tappedpoint.latitude, tappedpoint.longitude);
    final ads = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final ad = ads.first;
    setState(() {
      loc = LatLng(tappedpoint.latitude, tappedpoint.longitude);
      // con.initialCameraPosition = CameraPosition(
      //   bearing: 10,
      //   target: loc,
      //   zoom: 17.0,
      // );
      //pc = ad.postalCode;
      d1 = ad.subLocality == null || ad.subLocality.isEmpty
          ? ad.featureName
          : ad.subLocality;
      d2 = (ad.subAdminArea ?? ad.locality) + " - " + ad.postalCode;
      tc.text = ad.addressLine;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            con.initialCameraPosition == null
                ? hp.getPageLoader(size)
                : GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: Set.from(mymarker),
                    initialCameraPosition: con.initialCameraPosition,
                    // onTap: handletap,
                    onCameraMove: (camPos) {
                      loc = camPos.target;
                    },
                    onCameraIdle: () async {
                      if (loc != null &&
                          loc.latitude != 0.0 &&
                          loc.longitude != 0.0) {
                        final coordinates =
                            new Coordinates(loc.latitude, loc.longitude);
                        addresses = await Geocoder.local
                            .findAddressesFromCoordinates(coordinates);
                        final address = addresses.first;
                        print("++++++++++++++++++");
                        addresses.forEach(hp.putAddressToString);
                        print("================");
                        setState(() {
                          tc.text = address.addressLine;
                          d1 = address.subLocality == null ||
                                  address.subLocality.isEmpty
                              ? address.featureName
                              : address.subLocality;
                          d2 = (address.subAdminArea ?? address.locality) +
                              " - " +
                              address.postalCode;
                        });
                      } else
                        print("Bye");
                    }),
            Align(
                alignment: AlignmentDirectional.center,
                child: Image.asset("assets/images/map_marker.png")),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                      padding: EdgeInsets.only(top: height / 10),
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(radius / 100)),
                                  color: Color(0xffFCEAEA)),
                              height: height / 16,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width / 25,
                                  vertical: height / 200),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                            "assets/images/placeholder.png",
                                            fit: BoxFit.fill,
                                            height: height / 32),
                                        SizedBox(width: width / 50),
                                        Column(children: [
                                          Expanded(
                                            child: Text(d1 ?? "",
                                                style: TextStyle(
                                                    color: Color(0xff181c02),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                          Expanded(
                                              child: Text(d2 ?? "",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          Color(0xff200303))))
                                        ])
                                      ],
                                    ))
                                  ])),
                          Container(
                              child: TextField(
                                  controller: tc,
                                  style: TextStyle(color: Colors.black)),
                              padding: EdgeInsets.all(radius / 50)),
                          Row(
                            children: [
                              for (dynamic i in addressType.values)
                                Row(
                                  children: [
                                    Radio<addressType>(
                                        activeColor: Color(0xffA11414),
                                        value: i,
                                        groupValue: at,
                                        onChanged: setRadioValue),
                                    Text(
                                      EnumToString.convertToString(i),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                )
                            ],
                          ),
                          TextButton(
                              onPressed: () async {
                                final sharedPrefs =
                                    await SharedPreferences.getInstance();
                                Map<String, dynamic> body = {
                                  "id": widget.address.addressID.toString(),
                                  "is_default": true.toString(),
                                  "user_id":
                                      sharedPrefs.getString("spCustomerID"),
                                  "description":
                                      EnumToString.convertToString(at),
                                  "address": tc.text == null || tc.text == ""
                                      ? (widget.address.fullAddress == null
                                          ? (widget.address.addressLine == null
                                              ? ""
                                              : widget.address.addressLine)
                                          : widget.address.fullAddress)
                                      : tc.text,
                                  "latitude": loc == null
                                      ? widget.address.location.latitude
                                          .toString()
                                      : loc.latitude.toString(),
                                  "longitude": loc == null
                                      ? widget.address.location.longitude
                                          .toString()
                                      : loc.longitude.toString()
                                };
                                con.waitUntilUpdateAddress(body, context);
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: width / 8,
                                          vertical: height / 100)),
                                  foregroundColor: MaterialStateProperty.all(
                                      Color(0xffFFFFFF)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xffA11414))),
                              child: Text(
                                  (hp.loc.edit + hp.loc.address).toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)))
                        ],
                      ))
                ])
          ],
        ),
        floatingActionButton: con.initialCameraPosition == null
            ? Container(
                height: 0,
                width: 0,
              )
            : Padding(
                padding: EdgeInsets.only(bottom: height / 3.2),
                child: InkWell(
                    child: Image.asset("assets/images/map_button.png"),
                    onTap: getCurrentLocation
                    // onTap: () {
                    //   final controller = con.controller;
                    //   controller.animateCamera(CameraUpdate.newCameraPosition(
                    //     con.initialCameraPosition,
                    //   ));
                    // }
                    ),
              ));
  }

  void getCurrentLocation() async {
    try {
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
        setState(() {
          final controller = con.controller;
          curLoc = LatLng(currentLocation.latitude, currentLocation.longitude);
          con.initialCameraPosition = CameraPosition(
            bearing: 0,
            target: curLoc,
            zoom: 17.0,
          );
          controller.animateCamera(CameraUpdate.newCameraPosition(
            con.initialCameraPosition,
          ));
          tc.text = ads.first.addressLine;
        });
      } else
        setState(() => con.initialCameraPosition =
            CameraPosition(target: LatLng(13.0827, 80.2707), zoom: 17));
    } catch (e) {
      print(e);
      currentLocation = null;
      setState(() => con.initialCameraPosition =
          CameraPosition(target: LatLng(13.0827, 80.2707), zoom: 17));
      throw e;
    }
  }
}
