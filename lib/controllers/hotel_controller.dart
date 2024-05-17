import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/models/category.dart';
import 'package:foodigo_customer_app/models/coupon.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:foodigo_customer_app/models/custom_field.dart';
import 'package:foodigo_customer_app/models/customer.dart';
import 'package:foodigo_customer_app/models/food.dart';
import 'package:foodigo_customer_app/models/foodigogst.dart';
import 'package:foodigo_customer_app/models/medium.dart';
import 'package:foodigo_customer_app/models/menu.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:foodigo_customer_app/models/ordered_food.dart';
import 'package:foodigo_customer_app/models/razor_pay_customer.dart';
import 'package:foodigo_customer_app/models/razor_pay_order.dart';
import 'package:foodigo_customer_app/models/restaurant.dart';
import 'package:foodigo_customer_app/models/slide.dart';
import 'package:foodigo_customer_app/models/tag.dart';
import 'package:foodigo_customer_app/models/token.dart';
import 'package:foodigo_customer_app/models/user.dart';
import 'package:foodigo_customer_app/repos/rest_repos.dart';
import 'package:foodigo_customer_app/repos/settings_repos.dart';
import 'package:foodigo_customer_app/repos/user_repos.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class HotelController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  Customer user;
  RazorPayOrder rpo;
  Razorpay rp = Razorpay();
  Restaurant hotel;
  RazorPayCustomer customer;
  Order order;
  User driver;
  List<Slide> slides;
  List<Restaurant> hotels = <Restaurant>[];
  List<Category> categories;
  List<Cuisine> cuisines;
  List<Foodigogst> foodigogst = <Foodigogst>[];
  List<Food> foods = <Food>[];
  List<Tag> tags, availableTags = <Tag>[];
  List<OrderedFood> orderedFoods;
  List<Order> deliveredOrders, activeOrders, trashOrders;
  List<Menu> menu = <Menu>[];
  List<LatLng> polylineCoordinates = <LatLng>[];
  List<Coupon> coupons;
  List<Token> tokens;
  LatLng driverLoction;
  int deliveryFee;
  Tag tag;
  double driverLat, driverLong;
  LocationData currentLocation;
  LatLng curLoc;
  PickResult selectedPlace;
  CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(0.0, 0.0), zoom: 17);
  GoogleMapController controller;
  Set<Marker> markers = <Marker>{};
  Set<Polyline> polyLines = <Polyline>{};
  PolylinePoints polylinePoints = PolylinePoints();
  TextEditingController note = new TextEditingController();
  bool isLoading = false;
  Stopwatch st = new Stopwatch();
  final gc = GlobalConfiguration();

  void waitForHotels() async {
    final stream = await getHotels();
    setState(() =>
        hotels = stream == null || stream.isEmpty ? <Restaurant>[] : stream);
  }

  Future<void> waitForHotelData(int hotelID) async {
    final value = await getHotelData(hotelID);
    setState(() => hotel = value == null
        ? Restaurant(
            -1,
            "",
            "",
            "",
            "",
            -1,
            -1,
            "",
            "",
            "",
            "",
            "",
            -1,
            "",
            "",
            -1,
            "",
            LatLng(0.0, 0.0),
            false,
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            Coupon(-1, -1, "", "", "", "", "", "", false, -1, -1),
            <Medium>[],
            "",
            "",
            "",
            false,
            false,
            "")
        : value);
  }

  void waitForSearchedHotels(String pattern) async {
    print(pattern);
  }

  Future<void> waitForCategories() async {
    final stream = await getCategories();
    setState(() => categories = stream == null ? <Category>[] : stream);
  }

  void waitForFoods(Restaurant hotel) async {
    final stream = await getDishes();
    stream.forEach((value) {
      if (value.hotel == hotel && value.menuID != -1 && !value.isIn(foods))
        setState(() => foods.add(value));
    });
  }

  Future<void> waitForFoods1(Restaurant hotel) async {
    final stream = await getDishes1(hotel.restID.toString());
    stream.forEach((value) {
      print(value);
      if (value.hotel == hotel && value.menuID != -1 && !value.isIn(foods))
        setState(() => foods.add(value));
    });
  }

  Future<void> waitForTags() async {
    final stream = await getTags();
    setState(() => tags = stream == null ? <Tag>[] : stream);
    if (foods != null && foods.isNotEmpty && tags != null && tags.isNotEmpty) {
      foods.forEach((food) {
        tags.forEach((tag) {
          if (food.tagID == tag.tagID && !tag.isIn(availableTags))
            setState(() => availableTags.add(tag));
        });
      });
    }
  }

  void waitForTag(Food food) async {
    final value = await getTag(food.tagID);
    setState(() => tag = value == null ? Tag(-1, "") : value);
  }

  Future<void> waitUntilPlaceOrder(Map<String, dynamic> body) async {
    final value = await placeOrder(body);
    if (value.orderID != -1) {
      setState(() => isLoading = false);
      final p = await Navigator.popAndPushNamed(
          stateMVC.context, '/currentOrders',
          arguments: "Home");
      print(p);
    }
  }

  Future<Duration> waitForLocationBasedHotels(Map<String, dynamic> body) async {
    st.start();
    try {
      final stream = await getLocationBasedHotels(body);
      setState(() {
        if ((stream == null || stream.isEmpty) && body['page'] == "1")
          hotels = <Restaurant>[];
        else {
          if (body['page'] == "1")
            hotels = stream;
          else
            hotels.addAll(stream);
        }
      });
      st.stop();
      return st.elapsed;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<Duration> waitForLocationBasedHotelsSearch(
      Map<String, dynamic> body) async {
    st.start();
    try {
      final stream = await getLocationBasedHotelsSearch(body);
      setState(() => hotels = stream == null ? <Restaurant>[] : stream);
      st.stop();
      return st.elapsed;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> waitForCuisines() async {
    final value = await getCuisines();
    setState(() => cuisines = value == null ? <Cuisine>[] : value);
  }

  Future<void> waitForSlides() async {
    final stream = await getHomeSlides();
    setState(() => slides = stream == null ? <Slide>[] : stream);
  }

  void waitForOrders(int userID) async {
    final stream = await getOrders(userID);
    setState(() {
      activeOrders = <Order>[];
      deliveredOrders = <Order>[];
      trashOrders = <Order>[];
      if (stream.isNotEmpty)
        stream.forEach((order) {
          if (!(order.active || order.isIn(deliveredOrders)))
            deliveredOrders.add(order);
          else if (order.active && !order.isIn(activeOrders))
            activeOrders.add(order);
          else
            trashOrders.add(order);
        });
    });
  }

  Future<Duration> waitForCurrentOrders(int userID, page) async {
    st.start();
    try {
      final stream = await getCurrentOrders(userID, page);
      setState(() {
        if ((stream == null || stream.isEmpty) && page == "1")
          activeOrders = <Order>[];
        else {
          if (page == "1")
            activeOrders = stream;
          else
            activeOrders.addAll(stream);
        }
      });
      st.stop();
      return st.elapsed;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> waitForDeliveredOrders(int userID, page) async {
    final stream = await getDeliveredOrders(userID, page);
    setState(() {
      if ((stream == null || stream.isEmpty) && page == "1")
        deliveredOrders = <Order>[];
      else {
        if (page == "1")
          deliveredOrders = stream;
        else
          deliveredOrders.addAll(stream);
      }
    });
  }

  void waitForCancelOrders(userID, orderID) async {
    final value = await getCancelOrders(userID, orderID);
    if (value != null && value.orderID == orderID) {
      final q = await Fluttertoast.showToast(msg: "Order Cancelled");
      final p = await Navigator.popAndPushNamed(
          stateMVC.context, '/currentOrders',
          arguments: "Home");
      if (q) print(p);
    }
  }

  void pauseForFoods(int hotelID) async {
    final stream = await getDishes();
    stream.forEach((value) {
      if (value.hotel.restID == hotelID && !value.isIn(foods))
        setState(() => foods.add(value));
    });
  }

  Future<void> waitForCategorizedHotels(Map<String, dynamic> body) async {
    final stream = await getCategorizedRestaurants(body);
    setState(() {
      if ((stream == null || stream.isEmpty) && body['page'] == "1")
        hotels = <Restaurant>[];
      else {
        if (body['page'] == "1")
          hotels = stream;
        else
          hotels.addAll(stream);
      }
    });
  }

  Future<void> waitForCuisineHotels(Map<String, dynamic> body) async {
    final stream = await getCuisineHotels(body);
    setState(() {
      if ((stream == null || stream.isEmpty) && body['page'] == "1")
        hotels = <Restaurant>[];
      else {
        if (body['page'] == "1")
          hotels = stream;
        else
          hotels.addAll(stream);
      }
    });
  }

  Future<void> waitForOrderedFood(int orderID) async {
    final stream = await getOrderedFoods(orderID);
    setState(() => orderedFoods = stream == null ? <OrderedFood>[] : stream);
  }

  Future<void> waitForDriverDetails(int driverID) async {
    final value = await getDriverDetails(driverID);
    setState(() => driver = value == null || value == User() ? User() : value);
  }

  Future<void> waitForRazorPayOrder(Map<String, dynamic> body) async {
    final value = await uploadOrder(body);
    setState(() => rpo = value == null
        ? RazorPayOrder("", "", 0, 0, 0, "", 0, "", "", 0, 0)
        : value);
  }

  void waitForCustomerData(int customerID) async {
    final value = await getUserData(customerID);
    setState(() => user = value == null
        ? Customer(-1, "", "", "", "", "", <Medium>[], CustomField("", "", ""))
        : value);
  }

  Future<void> waitForMenu() async {
    final stream = await getMenu();
    setState(() => menu = stream == null ? <Menu>[] : stream);
  }

  Future<void> waitForCoupons(String page) async {
    final stream = await getCoupons(page);
    setState(() {
      if ((stream == null || stream.isEmpty) && page == "1")
        coupons = <Coupon>[];
      else {
        if (page == "1")
          coupons = stream;
        else
          coupons.addAll(stream);
      }
    });
  }

  void waitForCouponsbyHotel(hotelID, userID) async {
    final stream = await getCouponsbyHotel(hotelID, userID);
    setState(() => coupons = stream == null ? <Coupon>[] : stream);
  }

  Future<void> waitForFoodigoGST() async {
    final stream = await getgstDeliverycharge();
    setState(() => foodigogst = stream == null ? <Foodigogst>[] : stream);
    print(foodigogst);
    // final value = await getgstDeliverycharge();
    // setState(() => foodigogst = value == null ? Foodigogst(0, 0, 0, 0) : value);
    print(foodigogst[0].deliverychargemin);
  }

  Future<void> getDeliveryFee(kms) {
    var feeperkm = kms * foodigogst[0].rateperkm;
    var delfee = feeperkm + foodigogst[0].deliverychargemin;
    setState(() {
      deliveryFee = delfee;
    });
    return Future.value();
  }

  Future<void> waitForgetdriverLoc(orderID) async {
    final stream = await getDriverLoc(orderID);
    if (stream != null) {
      setState(() {
        driverLat = double.parse(stream['data']['driver_lat']);
        driverLong = double.parse(stream['data']['driver_lang']);
        driverLoction = LatLng(driverLat, driverLong);
      });
    }
  }

  Future<void> waitForSavedCards() async {
    final stream = await getSavedCards();
    setState(() => tokens = stream == null ? <Token>[] : stream);
  }
}
