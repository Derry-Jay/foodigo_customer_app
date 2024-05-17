import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/user_controller.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum addressType { Home, Work, Other }

class UserLocationPage extends StatefulWidget {
  final RouteArgument rar;
  UserLocationPage(this.rar);
  @override
  State<StatefulWidget> createState() => UserLocationPageState();
}

class UserLocationPageState extends StateMVC<UserLocationPage> {
  UserController con;
  LatLng loc;
  LocationData currentLocation;
  Set<Marker> markers = new Set<Marker>();
  List<Marker> myMarkers = <Marker>[];
  TextEditingController tc = new TextEditingController();
  List<Address> addresses;
  addressType at = addressType.Home;
  String d1, d2, pc;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  UserLocationPageState() : super(UserController()) {
    con = controller;
  }
  void getCurrentLocation() async {
    try {
      final location = new Location();
      // final permission = await location.hasPermission();
      // print(permission == PermissionStatus.granted);
      currentLocation = await location.getLocation();
      if (currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0) {
        // mymarker.add(Marker(
        //     markerId: MarkerId('mymarker'),
        //     position:
        //         LatLng(currentLocation.latitude, currentLocation.longitude)));
        print("locationLatitude: ${currentLocation.latitude}");
        print("locationLongitude: ${currentLocation.longitude}");
        final coordinates = new Coordinates(
            currentLocation.latitude, currentLocation.longitude);
        final ads =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        final ad = ads.first;
        setState(() {
          loc = LatLng(currentLocation.latitude, currentLocation.longitude);
          con.initialCameraPosition = CameraPosition(
            bearing: 0,
            target: loc,
            zoom: 17.0,
          );
          pc = ad.postalCode;
          d1 = ad.subLocality == null || ad.subLocality.isEmpty
              ? ad.featureName
              : ad.subLocality;
          d2 = (ad.subAdminArea ?? ad.locality) + " - " + pc;
          tc.text = ad.addressLine;
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

  void _onMapCreated(GoogleMapController controller) {
    con.controller = controller;
  }

  void setRadioValue(addressType type) {
    setState(() => at = type);
  }

  Future<void> handletap(LatLng tappedpoint) async {
    setState(() {
      myMarkers.add(
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
      pc = ad.postalCode;
      d1 = ad.subLocality == null || ad.subLocality.isEmpty
          ? ad.featureName
          : ad.subLocality;
      d2 = (ad.subAdminArea ?? ad.locality) + " - " + pc;
      tc.text = ad.addressLine;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            con.initialCameraPosition == null
                ? CircularLoader(
                    duration: Duration(seconds: 1),
                    heightFactor: height / 32,
                    widthFactor: width / 16,
                    color: Color(0xffa11414),
                    loaderType: LoaderType.PouringHourGlass)
                : GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: Set.from(myMarkers),
                    initialCameraPosition: con.initialCameraPosition,
                    //onTap: handletap,
                    onCameraMove: (camPos) {
                      loc = camPos.target;
                    },
                    onCameraIdle: () async {
                      if (loc != null) {
                        print(loc.latitude);
                        print(loc.longitude);
                        final coordinates =
                            new Coordinates(loc.latitude, loc.longitude);
                        addresses = await Geocoder.local
                            .findAddressesFromCoordinates(coordinates);
                        final address = addresses.first;
                        print("++++++++++++++++++");
                        if (mounted) addresses.forEach(hp.putAddressToString);
                        print("================");
                        setState(() {
                          tc.text = address.addressLine;
                          pc = address.postalCode;
                          d1 = address.subLocality == null ||
                                  address.subLocality.isEmpty
                              ? address.featureName
                              : address.subLocality;
                          d2 = (address.subAdminArea ?? address.locality) +
                              " - " +
                              pc;
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
                                        GestureDetector(
                                            child: Image.asset(
                                                "assets/images/placeholder.png",
                                                fit: BoxFit.fill,
                                                height: height / 32)),
                                        SizedBox(width: width / 50),
                                        d1 == null || d2 == null
                                            ? Text(
                                                hp.loc
                                                    .confirm_your_delivery_address,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12.8,
                                                    color: Colors.black))
                                            : Column(children: [
                                                Expanded(
                                                  child: Text(d1 ?? "",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff181c02),
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
                                                            color: Color(
                                                                0xff200303))))
                                              ])
                                      ],
                                    ))
                                  ])),
                          // Container(
                          //     margin:
                          //         EdgeInsets.symmetric(vertical: height / 80),
                          //     child: InkWell(
                          //         borderRadius:
                          //             BorderRadius.circular(radius * 2),
                          //         child: Column(
                          //           children: [
                          //             Container(
                          //               margin: EdgeInsets.symmetric(
                          //                   vertical: height / 80,
                          //                   horizontal: width / 20),
                          //               child: Row(
                          //                 children: [
                          //                   Icon(Icons.search,
                          //                       color: Colors.black),
                          //                   Container(
                          //                       padding: EdgeInsets.only(
                          //                           left: width / 25),
                          //                       child: Text(
                          //                           "Enter Location Manually",
                          //                           style: TextStyle(
                          //                               color: Colors.black,
                          //                               fontSize: 16,
                          //                               fontWeight:
                          //                                   FontWeight.w500)))
                          //                 ],
                          //               ),
                          //               // color: Colors.lightGreenAccent,
                          //               // height:
                          //             ),
                          //             DottedLine()
                          //           ],
                          //         ),
                          //         onTap: () {
                          //           Navigator.of(context)
                          //               .pushNamed("/searchLocation"
                          //                   // , arguments: RouteArgument(
                          //                   //     id: hotel.restID.toString(),
                          //                   //     heroTag: hotel.restName,
                          //                   //     param: hotel)
                          //                   );
                          //         })),
                          Container(
                              child: TextField(
                                  controller: tc,
                                  style: TextStyle(color: Colors.black)),
                              padding: EdgeInsets.symmetric(
                                  vertical: height / 100,
                                  horizontal: width / 25)),
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
                                Map<String, dynamic> body = widget.rar.param;
                                body['lat'] = loc.latitude.toString();
                                body['lang'] = loc.longitude.toString();
                                body['pincode'] = pc;
                                body['address'] = tc.text;
                                body['description'] =
                                    EnumToString.convertToString(at,
                                        camelCase: true);
                                body['device_token'] =
                                    sharedPrefs.getString("spDeviceToken");
                                // print(body);
                                con.waitUntilRegister(body);
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
                              child: Text(hp.loc.register.toUpperCase(),
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
                    onTap: () {
                      final controller = con.controller;
                      controller.animateCamera(CameraUpdate.newCameraPosition(
                          con.initialCameraPosition));
                    })));
  }
}
