import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/categories_carousel_widget.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/elements/cuisine_item_widget.dart';
import 'package:foodigo_customer_app/elements/cuisines_grid_widget.dart';
import 'package:foodigo_customer_app/elements/hotel_item_widget.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/category.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:foodigo_customer_app/models/restaurant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHotelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchHotelPageState();
}

class SearchHotelPageState extends StateMVC<SearchHotelPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  HotelController con;
  int page = 1;
  Duration du = Duration(seconds: 1);
  Map<String, dynamic> addressData = new Map<String, dynamic>();
  TextEditingController tc = new TextEditingController();
  Helper get hp => Helper.of(context);
  S get loc => S.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  TextEditingController searchKey = new TextEditingController();
  var imgBase;
  LatLng userLoc;
  SearchHotelPageState() : super(HotelController()) {
    con = controller;
  }
  bool isLoading = true;
  List<Restaurant> searchList = <Restaurant>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  void hotelSearch(String value) {
    setState(() {
      searchList = con.hotels
          .where((searchList) =>
              searchList.restName.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: getData,
          child: SingleChildScrollView(
              child: Column(
                  children: [
                    TextFormField(
                        onChanged: hotelSearch,
                        controller: searchKey,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: loc.search_for_restaurants_or_foods,
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: IconButton(
                              onPressed: () async {
                                final p = await Navigator.pushNamed(
                                    context, '/hotels');
                                print(p);
                              },
                              icon: Icon(
                                Icons.search,
                                color: Color(0xffBAD600),
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  searchKey.clear();
                                  searchList = con.hotels;
                                });
                              },
                              icon: Icon(
                                Icons.cancel,
                                color: Color(0xffBAD600),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(radius / 100),
                            ))),
                    SizedBox(
                      height: 15.0,
                    ),
                    // Container(
                    //   child: Text(
                    //     "TOP CATEGORIES",
                    //     style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w700),
                    //   ),
                    //   padding:
                    //       EdgeInsets.only(top: height / 80, left: width / 25),
                    // ),
                    // con.categories == null || con.categories.isEmpty
                    //     ? hp.getCardLoader(size, 8, 1)
                    //     : getCategoryList(con.categories),
                    Visibility(
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: height / 80, horizontal: width / 25),
                            child: Text(
                                loc.restaurants_near_to_your_current_location,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700))),
                        visible: !(con.hotels == null || con.hotels.isEmpty)),
                    con.hotels == null
                        ? CircularLoader(
                            duration: du,
                            heightFactor: 16,
                            widthFactor: 16,
                            loaderType: LoaderType.PouringHourGlass,
                            color: Color(0xffa11414))
                        : isLoading
                            ? hp.getCardLoader(size, 2, 1)
                            : (con.hotels.isEmpty
                                ? Container(
                                    width: width,
                                    height: height / 1.5,
                                    child: Center(
                                      child: Text(loc.unknown,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red)),
                                    ))
                                : getHotelsList(searchList, userLoc))
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start),
              padding: EdgeInsets.zero),
        ));
  }

  @override
  void dispose() {
    hp.rollbackOrientations();
    super.dispose();
  }

  Widget getCategoryList(List<Category> categories) {
    return categories == null
        ? CircularLoader(
            duration: du,
            color: Color(0xffA11414),
            heightFactor: 16,
            widthFactor: 16,
            loaderType: LoaderType.PouringHourGlass)
        : CategoriesCarouselWidget(
            categories: categories,
            dimensions: dimensions,
            imgbase: imgBase,
          );
  }

  GridView getCuisinesList(List<Cuisine> cuisines) {
    return GridView.builder(
      // scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, int index) =>
          CuisineItemWidget(cuisine: cuisines[index], dimensions: dimensions),
      itemCount: cuisines.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 0,
          mainAxisSpacing: 16,
          crossAxisCount: 4,
          childAspectRatio: height / (1.25 * width)),
    );
  }

  Widget getHotelsList(List<Restaurant> hotels, LatLng userLoc) {
    return hotels.length == 0
        ? Container(
            child: Center(
                child: Text(hp.loc.unknown,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red))))
        : Container(
            child: ListView.builder(
                itemCount: hotels == null ? 0 : hotels.length,
                itemBuilder: (context, index) {
                  // if (index == hotels.length - 1) {
                  //   return Center(child: CircularLoadingWidget());
                  // } else {
                  return HotelItemWidget(
                    hotel: hotels[index],
                    dimensions: dimensions,
                    imgbase: imgBase,
                    userloc: userLoc,
                  );
                  // }
                },
                physics: NeverScrollableScrollPhysics()),
            height: (height * hotels.length) / 5,
          );
  }

  Widget buildCuisinesList(List<Cuisine> cuisines) {
    return CuisineGridWidget(
      cuisines: cuisines,
      dimensions: dimensions,
      imgbase: imgBase,
    );
  }

  Future<void> getData() async {
    hp.lockScreenRotation();
    hp.getConnectStatus();
    final sharedPrefs = await SharedPreferences.getInstance();
    addressData = json.decode(sharedPrefs.getString("defaultAddress"));
    setState(() {
      imgBase = sharedPrefs.getString("imgBase");
      userLoc = LatLng(addressData["latitude"], addressData["longitude"]);
    });
    // await con.waitForCuisines();
    // await con.waitForCategories();
    // await con.waitForTags();
    // if (sharedPrefs.containsKey("defaultAddress")) {
    // addressData = json.decode(sharedPrefs.getString("defaultAddress"));
    du = await con.waitForLocationBasedHotelsSearch({
      "latitude": addressData['latitude'].toString(),
      "longitude": addressData['longitude'].toString()
    });
    print(con.hotels);
    setState(() {
      isLoading = false;
      searchList = con.hotels;
    });
    // }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
