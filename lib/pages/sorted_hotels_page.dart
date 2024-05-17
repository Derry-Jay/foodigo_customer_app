import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CuisineBasedHotelsPage extends StatefulWidget {
  final Cuisine cuisine;
  CuisineBasedHotelsPage(this.cuisine);
  @override
  CuisineBasedHotelsPageState createState() => CuisineBasedHotelsPageState();
}

class CuisineBasedHotelsPageState extends StateMVC<CuisineBasedHotelsPage> {
  HotelController con;
  Map<String, dynamic> addressData = new Map<String, dynamic>();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  var imgbase;
  LatLng userloc;
  Duration du = Duration(seconds: 1);
  int page = 1;
  bool isloading = true;
  CuisineBasedHotelsPageState() : super(HotelController()) {
    con = controller;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  void getData() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    print(widget.cuisine.cuisineID);
    setState(() {
      imgbase = sharedPrefs.getString("imgBase");
    });
    if (sharedPrefs.containsKey("defaultAddress")) {
      addressData = json.decode(sharedPrefs.getString("defaultAddress"));
      userloc = LatLng(addressData["latitude"], addressData["longitude"]);
      Map<String, dynamic> body = {
        "cuisine": widget.cuisine.cuisineID.toString(),
        "page": "1",
        "latitude": addressData['latitude'].toString(),
        "longitude": addressData['longitude'].toString()
      };
      await con.waitForCuisineHotels(body);
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: isloading
          ? CircularLoader(
              duration: du,
              heightFactor: 32,
              widthFactor: 16,
              color: Color(0xffa11414),
              loaderType: LoaderType.PouringHourGlass)
          : con.hotels.isEmpty
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Text(
                      hp.loc.unknown,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                )
              : LazyLoadScrollView(
                  scrollDirection: Axis.vertical,
                  onEndOfPage: () async {
                    final sharedPrefs = await SharedPreferences.getInstance();
                    print("object");
                    page++;
                    if (sharedPrefs.containsKey("defaultAddress")) {
                      addressData =
                          json.decode(sharedPrefs.getString("defaultAddress"));
                      Map<String, dynamic> body = {
                        "cuisine": widget.cuisine.cuisineID.toString(),
                        "page": page.toString(),
                        "latitude": addressData['latitude'].toString(),
                        "longitude": addressData['longitude'].toString()
                      };
                      print(body);
                      await con.waitForCuisineHotels(body);
                    }
                  },
                  child: Scrollbar(
                      child: hp.getFilteredHotelsList(
                          con.hotels, dimensions, userloc))),
      appBar: AppBar(
          elevation: 7,
          title: Text(
            widget.cuisine.cuisineName ?? "",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color(0xffFBFBFB),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
    );
  }
}
