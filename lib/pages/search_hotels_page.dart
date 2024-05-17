import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHotelsPage extends StatefulWidget {
  final RouteArgument rar;
  SearchHotelsPage(this.rar);
  State<StatefulWidget> createState() => SearchHotelsPageState();
}

class SearchHotelsPageState extends StateMVC<SearchHotelsPage> {
  HotelController con;
  List<List> lists = <List>[];
  List<Cuisine> selectedCuisineList = <Cuisine>[];
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  TextEditingController tc = new TextEditingController();
  SearchHotelsPageState() : super(HotelController()) {
    con = controller;
  }

  void getData() async {
    final prefs = await _sharedPrefs;
    // print();
    hp.getConnectStatus();
    if (!prefs.containsKey('razorPayID'))
      // await con.waitUntilRazorPayCustomerAdd({
      //   "name": "User3",
      //   "email": "user3@example.com",
      //   "contact": "7530148952"
      // });
      await con.waitForCategories();
    await con.waitForCuisines();
    print("Done");
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            child: TextField(
                cursorColor: Colors.black,
                controller: tc,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.arrow_back_ios, color: Colors.black),
                    filled: true,
                    fillColor: Colors.black12,
                    suffixIcon: InkWell(
                        child: Container(
                          color: Color(0xffbad600),
                          child: Image.asset("assets/images/controls.png"),
                          height: height / 12.5,
                        ),
                        onTap: () {
                          showBarModalBottomSheet(
                              barrierColor: Colors.transparent,
                              expand: true,
                              context: context,
                              backgroundColor: Color(0xffa11414),
                              builder: (context) =>
                                  hp.getFilterWidget(lists, size, onItemSearch:
                                      (List<dynamic> list, String text) {
                                    return [];
                                  }, validateSelectedItem:
                                      (List<dynamic> list, item) {
                                    return list.contains(item);
                                  }));
                        }),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(radius / 100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(radius / 100),
                    )),
                onChanged: con.waitForSearchedHotels),
            padding: EdgeInsets.all(radius / 80),
          ),
          hp.getSearchedHotelsList(
              con.hotels, dimensions, con.cuisines, con.categories)
        ],
      ),
    );
  }
}
