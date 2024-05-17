import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:foodigo_customer_app/models/category.dart';
import 'package:foodigo_customer_app/models/category_base.dart';
import 'package:foodigo_customer_app/models/coupon.dart';
import 'package:foodigo_customer_app/models/coupon_base.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:foodigo_customer_app/models/cuisine_base.dart';
import 'package:foodigo_customer_app/models/food.dart';
import 'package:foodigo_customer_app/models/food_base.dart';
import 'package:foodigo_customer_app/models/foodigogst.dart';
import 'package:foodigo_customer_app/models/foodigogst_base.dart';
import 'package:foodigo_customer_app/models/medium.dart';
import 'package:foodigo_customer_app/models/menu.dart';
import 'package:foodigo_customer_app/models/menu_base.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:foodigo_customer_app/models/order_base.dart';
import 'package:foodigo_customer_app/models/ordered_food.dart';
import 'package:foodigo_customer_app/models/ordered_food_base.dart';
import 'package:foodigo_customer_app/models/razor_pay_customer.dart';
import 'package:foodigo_customer_app/models/razor_pay_order.dart';
import 'package:foodigo_customer_app/models/restaurant.dart';
import 'package:foodigo_customer_app/models/restaurants_base.dart';
import 'package:foodigo_customer_app/models/tag.dart';
import 'package:foodigo_customer_app/models/tag_base.dart';
import 'package:foodigo_customer_app/models/user.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

final client = new Client(), gc = new GlobalConfiguration();

Future<List<Restaurant>> getHotels() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "restaurants");
  try {
    final response = await client.get(url, headers: headers);
    return response.statusCode == 200
        ? RestaurantBase.fromMap(json.decode(response.body)).restaurants
        : <Restaurant>[];
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<Restaurant> getHotelData(int hotelID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(
      gc.getValue("api_base_url") + "restaurants/" + hotelID.toString());
  try {
    final response = await client.get(url, headers: headers);
    print("Hotel Data");
    print(response.body);
    return response.statusCode == 200
        ? Restaurant.fromMap(json.decode(response.body)['data'])
        : Restaurant(
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
            "");
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<List<Cuisine>> getCuisines() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "cuisines");
  try {
    final response = await client.get(url, headers: headers);
    // print("response.body");
    // print(response.body);
    return response.statusCode == 200
        ? CuisineBase.fromMap(json.decode(response.body)).cuisines
        : <Cuisine>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Food>> getDishes() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "foods");
  try {
    final response = await client.get(url, headers: headers);
    print(json.decode(response.body));
    return response.statusCode == 200
        ? FoodBase.fromMap(json.decode(response.body)).foods
        : <Food>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Food>> getDishes1(String id) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "foodsrestaurent/" + id);
  try {
    final response = await client.get(url, headers: headers);
    print("Restaurant ID: $id");
    print(response.body);
    return response.statusCode == 200
        ? FoodBase.fromMap(json.decode(response.body)).foods
        : <Food>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Category>> getCategories() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "categories");
  try {
    final response = await client.get(url, headers: headers);
    // print(response.body);
    return response.statusCode == 200
        ? CategoryBase.fromMap(json.decode(response.body)).categories
        : <Category>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Tag>> getTags() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue("api_base_url") + "tags");
  try {
    final response = await client.get(url, headers: headers);
    return response.statusCode == 200
        ? TagBase.fromMap(json.decode(response.body)).tags
        : <Tag>[];
  } catch (e) {
    throw e;
  }
}

Future<Tag> getTag(int tagID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url =
      Uri.parse(gc.getValue("api_base_url") + "tags/" + tagID.toString());
  try {
    final response = await client.get(url, headers: headers);
    return response.statusCode == 200
        ? Tag.fromMap(json.decode(response.body))
        : Tag(-1, "");
  } catch (e) {
    throw e;
  }
}

Future<Order> placeOrder(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  final url = Uri.parse(gc.getValue("api_base_url") + "orders/store");
  final client = new HttpClient();
  final request = await client.postUrl(url);
  final reqStr = json.encode(body);
  print(reqStr);
  request.headers
      .set("Authorization", "Bearer " + sharedPrefs.getString("apiToken"));
  request.headers.set('content-type', 'application/json');
  request.headers.contentType =
      new ContentType("application", "json", charset: "utf-8");
  request.write(reqStr);
  try {
    final response = await request.close();
    print(response.statusCode);
    if (response.statusCode == 200) {
      final reply = await response.transform(utf8.decoder).join();
      final p = await sharedPrefs.remove("cartData");
      final q = await sharedPrefs.remove("itemCount");
      final r = await sharedPrefs.remove("itemPrice");
      final s = await sharedPrefs.remove("spHotelID");
      final t = await sharedPrefs.remove("coupon");
      final u = await sharedPrefs.remove("items");
      if (p && q && r && s && t && u) {
        print(json.decode(reply));
        return Order.fromMap(json.decode(reply)['data']);
      } else
        return Order(-1, 0, "", "", false, "", -1, -1, -1, LatLng(0.0, 0.0),
            LatLng(0.0, 0.0), LatLng(0.0, 0.0), "", 0, "", "", "", "");
    } else
      return Order(-1, 0, "", "", false, "", -1, -1, -1, LatLng(0.0, 0.0),
          LatLng(0.0, 0.0), LatLng(0.0, 0.0), "", 0, "", "", "", "");
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<List<Restaurant>> getLocationBasedHotels(
    Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "reslocation");
  print(gc.getValue('api_base_url') + "reslocation");
  print(body1);
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print("response.body");
    print(response.statusCode);
    print(response.body);
    return response.statusCode == 200
        ? RestaurantBase.fromMap(json.decode(response.body)).restaurants
        : <Restaurant>[];
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<List<Restaurant>> getLocationBasedHotelsSearch(
    Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "research");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print("response.body");
    print(response.body);
    return response.statusCode == 200
        ? RestaurantBase.fromMap(json.decode(response.body)).restaurants
        : <Restaurant>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Order>> getOrders(int userID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(
      gc.getValue('api_base_url') + "showcustomerorders/" + userID.toString());
  try {
    final response = await client.get(url, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? OrderBase.fromMap(json.decode(response.body)).orders
        : <Order>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Order>> getCurrentOrders(int userID, page) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode({"id": userID.toString(), "page": page});
  final url = Uri.parse(gc.getValue('api_base_url') + "showcurrentorders");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    //print(response.body);
    return response.statusCode == 200
        ? OrderBase.fromMap(json.decode(response.body)).orders
        : <Order>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Order>> getDeliveredOrders(int userID, page) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode({
    "id": userID.toString(),
    "page": page,
    "api_token": sharedPrefs.getString("apiToken")
  });
  final url = Uri.parse(gc.getValue('api_base_url') + "showhistoryorders");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? OrderBase.fromMap(json.decode(response.body)).orders
        : <Order>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Order>> getDeliveredOrdersapitoken(int userID, page) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(
      gc.getValue('api_base_url') + "showhistoryorders/" + userID.toString());
  try {
    final response = await client.get(
      url,
      headers: headers,
    );
    print(response.body);
    return response.statusCode == 200
        ? OrderBase.fromMap(json.decode(response.body)).orders
        : <Order>[];
  } catch (e) {
    throw e;
  }
}

Future<Order> getCancelOrders(userID, orderID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  final body1 = jsonEncode(
      {"user_id": userID.toString(), "order_id": orderID.toString()});
  final url = Uri.parse(gc.getValue('api_base_url') + "cancel");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    return response.statusCode == 200
        ? Order.fromMap(json.decode(response.body)['data'])
        : <Order>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Restaurant>> getCategorizedRestaurants(
    Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.tryParse(gc.getValue('api_base_url') + "rescategories");
  final address = json.decode(sharedPrefs.getString("defaultAddress"));
  try {
    print(address);
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? RestaurantBase.fromMap(json.decode(response.body)).restaurants
        : <Restaurant>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Restaurant>> getCuisineHotels(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') + "rescuisine");
  final address = json.decode(sharedPrefs.getString("defaultAddress"));
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(address);
    print(response.body);
    return response.statusCode == 200
        ? RestaurantBase.fromMap(json.decode(response.body)).restaurants
        : <Restaurant>[];
  } catch (e) {
    throw e;
  }
}

Future<List<OrderedFood>> getOrderedFoods(int orderID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(
      gc.getValue('api_base_url') + "foodorders/" + orderID.toString());
  try {
    final response = await client.get(url, headers: headers);
    //print(response.body);
    return response.statusCode == 200
        ? (OrderedFoodBase.fromMap(json.decode(response.body)).response.success
            ? OrderedFoodBase.fromMap(json.decode(response.body)).foods
            : <OrderedFood>[])
        : <OrderedFood>[];
  } catch (e) {
    throw e;
  }
}

Future<User> getDriverDetails(int driverID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url =
      Uri.parse(gc.getValue('api_base_url') + "users/" + driverID.toString());
  try {
    final response = await client.post(url, headers: headers);
    return response.statusCode == 200
        ? User.fromJSON(json.decode(response.body)['data'])
        : User();
  } catch (e) {
    throw e;
  }
}

Future<RazorPayOrder> uploadOrder(Map<String, dynamic> body) async {
  final url = Uri.tryParse(gc.getValue('razor_pay_url') + "orders");
  try {
    final response = await client.post(url, body: body, headers: {
      HttpHeaders.authorizationHeader: 'Basic ' +
          base64Encode(utf8.encode(gc.getValue('razor_pay_key') +
              ":" +
              gc.getValue('razor_pay_secret')))
    });
    print(response.body);
    return response.statusCode == 200
        ? RazorPayOrder.fromMap(json.decode(response.body))
        : RazorPayOrder("", "", 0, 0, 0, "", 0, "", "", 0, 0);
  } catch (e) {
    throw e;
  }
}

Future<RazorPayCustomer> addRazorPayCustomer(Map<String, dynamic> body) async {
  final headers = {
    HttpHeaders.acceptCharsetHeader: "utf-8",
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Basic " +
        base64Encode(utf8.encode(gc.getValue('razor_pay_key') +
            ":" +
            gc.getValue('razor_pay_secret')))
  };
  try {
    final reqJson = json.encode(body);
    final url = Uri.tryParse(gc.getValue('razor_pay_url') + "customers");
    final response = await client.post(url, body: reqJson, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? RazorPayCustomer.fromMap(json.decode(response.body))
        : RazorPayCustomer("", "", "", "", -1);
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<List<Menu>> getMenu() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.tryParse(gc.getValue('api_base_url') + "menus");
  try {
    final response = await client.get(url, headers: headers);
    print(response.body);
    return response.statusCode == 200 &&
            MenuBase.fromMap(json.decode(response.body)).response.success
        ? MenuBase.fromMap(json.decode(response.body)).menu
        : <Menu>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Coupon>> getCoupons(page) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  final body1 = jsonEncode({"page": page.toString()});
  final url = Uri.tryParse(gc.getValue('api_base_url') + "coupons");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print("Offers");
    print(response.body);
    return response.statusCode == 200
        ? CouponBase.fromMap(json.decode(response.body)).coupons
        : <Coupon>[];
  } catch (e) {
    throw e;
  }
}

// Future<List<Coupon>> getCouponsbyHotel(hotelID) async {
//   final url = Uri.tryParse(
//       gc.getValue('api_base_url') + "couponrestaurent/" + hotelID.toString());
//   try {
//     final response = await client.post(url);
//     print(response.body);
//     return response.statusCode == 200
//         ? CouponBase.fromMap(json.decode(response.body)).coupons
//         : <Coupon>[];
//   } catch (e) {
//     throw e;
//   }
// }

Future<List<Coupon>> getCouponsbyHotel(hotelID, userID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode({"restaurant_id": hotelID, "user_id": userID});
  final url = Uri.tryParse(gc.getValue('api_base_url') + "customercoupon");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    // print(response.body);
    return response.statusCode == 200
        ? CouponBase.fromMap(json.decode(response.body)).coupons
        : <Coupon>[];
  } catch (e) {
    throw e;
  }
}

Future<List<Foodigogst>> getgstDeliverycharge() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.tryParse(gc.getValue('api_base_url') + "getfoodigogst");
  try {
    final response = await client.post(url, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? FodigogstBase.fromMap(json.decode(response.body)).foodigogst
        : <Foodigogst>[];
  } catch (e) {
    throw e;
  }
}

Future getDriverLoc(orderID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode({"order_id": orderID.toString()});
  final url = Uri.tryParse(gc.getValue('api_base_url') + "driver/dynamicloc");
  try {
    final response = await client.post(url, body: body1, headers: headers);
    // print(response.body);
    return response.statusCode == 200 ? json.decode(response.body) : null;
  } catch (e) {
    throw e;
  }
}
