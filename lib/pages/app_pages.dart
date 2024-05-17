import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/address_popup_widget.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:foodigo_customer_app/pages/SearchHotelPage.dart';
import 'package:foodigo_customer_app/pages/profile_page.dart';
// import 'package:native_updater/native_updater.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:new_version/new_version.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'help_page.dart';
import 'home_page.dart';
// import 'offers_page.dart';

class AppPages extends StatefulWidget {
  final RouteArgument rar;
  AppPages(this.rar);
  @override
  State<StatefulWidget> createState() => AppPagesState();
}

class AppPagesState extends StateMVC<AppPages> {
  DateTime currentBackPressTime;
  HotelController con;
  Widget page;
  int index, count = 0;
  Cart cart;
  bool flag;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  String d1, d2;
  Map<String, dynamic> addressData;
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get pixelRatio => dimensions.devicePixelRatio;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  AppPagesState() : super(HotelController()) {
    con = controller;
  }

  void selectTab(int a) {
    setState(() {
      index = a;
      switch (a) {
        case 1:
          page = SearchHotelPage();
          break;
        case 2:
          page = HelpPage();
          break;
        case 3:
          page = ProfilePage();
          break;
        // case 4:
        //   page = OffersPage();
        //   break;
        case 0:
        default:
          page = HomePage();
          break;
      }
    });
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    con.waitForOrders(sharedPrefs.containsKey("spCustomerID")
        ? (int.tryParse(sharedPrefs.getString("spCustomerID") ?? "-1") ?? -1)
        : -1);
    con.waitForCuisines();
    hp.lockScreenRotation();
    flag = sharedPrefs.containsKey("defaultAddress");
    addressData = flag
        ? json.decode(sharedPrefs.getString("defaultAddress"))
        : new Map<String, dynamic>();
    if (addressData.isNotEmpty) {
      d1 = addressData["area"];
      d2 = addressData["clipped_address"];
    } else
      Future.delayed(Duration.zero, popUpAddressWidget);
    cart = sharedPrefs.containsKey("cartData")
        ? Cart.fromMap(json.decode(sharedPrefs.getString("cartData")))
        : Cart();
    count = cart.itemCount ?? 0;
  }

  void setPage() {
    index = int.tryParse(widget.rar.heroTag ?? "0") ?? 0;
    selectTab(index);
  }

  void checkVersion() async {
    final newVersion = NewVersion(androidId: "com.foodigo.customer");
    final status = await newVersion.getVersionStatus();
    print("Version status");
    print(status.appStoreLink);
    if (mounted) newVersion.showAlertIfNecessary(context: context);
  }

  FutureOr<Null> popUpAddressWidget() {
    return showModalBottomSheet(
        enableDrag: false,
        builder: hp.showAddressPopup,
        context: context,
        isDismissible: false);
  }

  void assignState() {
    checkVersion();
    setPage();
    getData();
  }

  Future<bool> onWillPop() async {
    if (index != 0) {
      selectTab(0);
      return Future.value(false);
    } else {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        final p = await Fluttertoast.showToast(msg: hp.loc.tapAgainToLeave);
        return Future.value(!p);
      } else {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      }
    }
  }

  FutureOr onGoBack(dynamic value) async {
    final sharedPrefs = await _sharedPrefs;
    setState(() {
      cart = sharedPrefs.containsKey("cartData")
          ? Cart.fromMap(json.decode(sharedPrefs.getString("cartData")))
          : Cart();
      count = cart.itemCount ?? 0;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, assignState);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
                leading: null,
                title: InkWell(
                    child: d1 == null || d2 == null
                        ? Row(
                            children: [
                              //Image.asset("assets/images/placeholder.png"),
                              new SvgPicture.asset(
                                  'assets/images/location-svg.svg'),
                              Text(hp.loc.your_address,
                                  style: TextStyle(
                                      color: Color(0xff110202),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.8))
                            ],
                          )
                        : Column(children: [
                            Row(
                                children: [
                                  // Image.asset("assets/images/placeholder.png"),
                                  new SvgPicture.asset(
                                      'assets/images/location-svg.svg'),
                                  SizedBox(width: width / 50),
                                  Expanded(
                                      child: Text(d1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.black)))
                                ],
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween),
                            Text(d2,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.black))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                    onTap: () {
                      showModalBottomSheet(
                          enableDrag: false,
                          isDismissible: false,
                          builder: (context) => AddressPopupWidget(),
                          context: context);
                    }),
                backgroundColor: Color(0xffFBFBFB),
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: InkWell(
                        child: Badge(
                            child: new SvgPicture.asset(
                              'assets/images/cart-svg.svg',
                            ),
                            // Image.asset("assets/images/cart.png",
                            //     height: height / 4, width: width / 6.4),
                            badgeContent: Text(count.toString(),
                                style: TextStyle(color: Colors.white)),
                            badgeColor: Color(0xffBAD600),
                            position:
                                BadgePosition.topStart(start: 12, top: 8)),
                        onTap: () {
                          hp.navigateTo('/cart',
                              arguments: RouteArgument(param: cart.json),
                              onGoBack: onGoBack);
                        }),
                  ),
                ]),
            body: page == null ? HomePage() : page,
            bottomNavigationBar: BottomNavigationBar(
                unselectedItemColor: Color(0xff929292),
                selectedItemColor: Color(0xffa11414),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Color(0xffF1F1F1),
                unselectedLabelStyle: TextStyle(
                    color: Color(0xff929292),
                    fontWeight: FontWeight.w500,
                    fontSize: 10),
                selectedLabelStyle: TextStyle(
                    color: Color(0xffa11414),
                    fontWeight: FontWeight.w500,
                    fontSize: 10),
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: hp.loc.home,
                      backgroundColor: Color(0xffF1F1F1)),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: hp.loc.search,
                      backgroundColor: Color(0xffF1F1F1)),
                  // BottomNavigationBarItem(
                  //     icon: Icon(Icons.local_offer),
                  //     label: "OFFERS",
                  //     backgroundColor: Color(0xffF1F1F1)),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.av_timer),
                      label: hp.loc.recent_orders,
                      backgroundColor: Color(0xffF1F1F1)),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: hp.loc.profile,
                      backgroundColor: Color(0xffF1F1F1))
                ],
                currentIndex: index,
                onTap: selectTab)),
        onWillPop: onWillPop);
  }

  @override
  void dispose() {
    super.dispose();
    hp.rollbackOrientations();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print(AppLifecycleState.values);
    // print(state);
    // print(con.activeOrders.isEmpty && state == AppLifecycleState.paused);
    // (con.activeOrders == null || con.activeOrders.isEmpty) &&
    //         state == AppLifecycleState.inactive
    //     ? Future.delayed(Duration.zero, popUpAddressWidget)
    //     : print(state);
  }
}
