import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/category.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryBasedHotelsPage extends StatefulWidget {
  final Category cat;
  CategoryBasedHotelsPage(this.cat);
  @override
  CategoryBasedHotelsPageState createState() => CategoryBasedHotelsPageState();
}

class CategoryBasedHotelsPageState extends StateMVC<CategoryBasedHotelsPage> {
  HotelController con;
  int page = 1;
  Map<String, dynamic> addressData = new Map<String, dynamic>();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get height => dimensions.size.height;
  double get width => dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  var imgbase;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  LatLng userloc;
  bool isloading = true;
  CategoryBasedHotelsPageState() : super(HotelController()) {
    con = controller;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Future.delayed(Duration.zero, getData);
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    setState(() {
      imgbase = sharedPrefs.getString("imgBase");
    });
    hp.getConnectStatus();
    if (sharedPrefs.containsKey("defaultAddress")) {
      addressData = json.decode(sharedPrefs.getString("defaultAddress"));
      userloc = LatLng(addressData["latitude"], addressData["longitude"]);
      Map<String, dynamic> body = {
        "categories": widget.cat.categoryID.toString(),
        "page": '1',
        "latitude": addressData['latitude'].toString(),
        "longitude": addressData['longitude'].toString()
      };
      await con.waitForCategorizedHotels(body);
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: isloading
            ? CircularLoader(
                color: Color(0xffa11414),
                heightFactor: 16,
                widthFactor: 16,
                loaderType: LoaderType.PouringHourGlass)
            : con.hotels.isEmpty
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Text(
                        "No Data Found",
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
                        addressData = json
                            .decode(sharedPrefs.getString("defaultAddress"));
                        Map<String, dynamic> body = {
                          "categories": widget.cat.categoryID.toString(),
                          "page": page.toString(),
                          "latitude": addressData['latitude'].toString(),
                          "longitude": addressData['longitude'].toString()
                        };
                        await con.waitForCategorizedHotels(body);
                      }
                    },
                    child: Scrollbar(
                        child: hp.getFilteredHotelsList(
                            con.hotels, dimensions, userloc))),
        appBar: AppBar(
            title: Text(widget.cat.category,
                style: TextStyle(color: Colors.black)),
            backgroundColor: Color(0xffFBFBFB),
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                }),
            elevation: 0));
  }
}
