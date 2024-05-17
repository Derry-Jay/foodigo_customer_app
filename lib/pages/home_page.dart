import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends StateMVC<HomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int page = 1;
  Duration dt = Duration(seconds: 1);
  HotelController con;
  Map<String, dynamic> addressData = new Map<String, dynamic>();
  TextEditingController tc = new TextEditingController();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  String imgBase = "";
  bool lazyLoad = false;
  LatLng userLoc;

  HomePageState() : super(HotelController()) {
    con = controller;
  }
  bool isLoading = true;

  Future<void> getData() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.containsKey("defaultAddress")) {
      addressData = json.decode(sharedPrefs.getString("defaultAddress"));
      setState(() {
        imgBase = sharedPrefs.getString("imgBase");
        userLoc = LatLng(addressData["latitude"], addressData["longitude"]);
      });
      dt = await con.waitForLocationBasedHotels({
        "page": page.toString(),
        "latitude": addressData['latitude'].toString(),
        "longitude": addressData['longitude'].toString()
      });
    }
    await con.waitForSlides();
    await con.waitForCuisines();
    await con.waitForCategories();
    await con.waitForTags();
    if (mounted) {
      hp.lockScreenRotation();
      hp.getConnectStatus();
      setState(() => isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final p = context.dependOnInheritedWidgetOfExactType();
    print(p);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // NativeUpdater.displayUpdateAlert(
    //   context,
    //   forceUpdate: true,
    //   playStoreUrl:
    //       'https://play.google.com/store/apps/details?id=com.foodigo.customer',
    // );
    Future.delayed(Duration.zero, getData);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: LazyLoadScrollView(
          scrollDirection: Axis.vertical,
          onEndOfPage: () async {
            setState(() {
              lazyLoad = true;
            });
            print("object");
            page++;
            print(page);
            final p = await con.waitForLocationBasedHotels({
              "page": page.toString(),
              "latitude": addressData['latitude'].toString(),
              "longitude": addressData['longitude'].toString()
            });
            print(p == dt);
          },
          child: RefreshIndicator(
            onRefresh: getData,
            child: Scrollbar(
              child: SingleChildScrollView(
                  child: Column(
                      children: [
                        con.slides == null
                            ? hp.getCardLoader(size, 5, 1)
                            : hp.getSlides(con.slides),
                        Container(
                          child: Text(
                            hp.loc.food_categories,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                          padding: EdgeInsets.only(
                              top: height / 80, left: width / 25),
                        ),
                        con.categories == null || con.categories.isEmpty
                            ? hp.getCardLoader(size, 8, 1)
                            : hp.getCategoryList(con.categories, dimensions),
                        Container(
                            child: Text(hp.loc.cuisines,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            padding: EdgeInsets.only(
                                left: width / 25, bottom: height / 100)),
                        con.cuisines == null || con.cuisines.isEmpty
                            ? hp.getCardLoader(size, 2, 1)
                            : hp.buildCuisinesList(con.cuisines, dimensions),
                        Visibility(
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: height / 80,
                                    horizontal: width / 25),
                                child: Text(
                                    hp.loc
                                        .restaurants_near_to_your_current_location,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700))),
                            visible:
                                !(con.hotels == null || con.hotels.isEmpty)),
                        con.hotels == null
                            ? CircularLoader(
                                duration: dt,
                                heightFactor: 16,
                                widthFactor: 16,
                                color: Color(0xffa11414),
                                loaderType: LoaderType.PouringHourGlass)
                            : isLoading
                                ? Container()
                                : (con.hotels.isEmpty
                                    ? Container(
                                        child: Center(
                                        child: Text(hp.loc.unknown,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red)),
                                      ))
                                    : hp.getHotelsListUsingLocation(
                                        con.hotels, userLoc, dimensions))
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start),
                  padding: EdgeInsets.zero),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    hp.rollbackOrientations();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
