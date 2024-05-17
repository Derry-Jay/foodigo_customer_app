import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:foodigo_customer_app/models/address.dart';
import 'package:foodigo_customer_app/models/address_base.dart';
import 'package:foodigo_customer_app/models/atm_card.dart';
import 'package:foodigo_customer_app/models/custom_field.dart';
import 'package:foodigo_customer_app/models/customer.dart';
import 'package:foodigo_customer_app/models/medium.dart';
import 'package:foodigo_customer_app/models/misc_data.dart';
import 'package:foodigo_customer_app/models/reply.dart';
import 'package:foodigo_customer_app/models/token.dart';
import 'package:foodigo_customer_app/models/token_base.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../models/user.dart';

Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
ValueNotifier<User> currentUser = new ValueNotifier(User());
final client = new Client(), gc = new GlobalConfiguration();

Future<User> login(User user) async {
  final url = Uri.parse('${gc.getValue('api_base_url')}login');
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.loginMap),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<User> register(User user) async {
  final url = Uri.parse('${gc.getValue('api_base_url')}register');
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.json),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<bool> resetPassword(User user) async {
  final url = Uri.parse('${gc.getValue('api_base_url')}send_reset_link_email');
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.json),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  final prefs = await _sharePrefs;
  final p = await prefs.remove('current_user');
  if (p) currentUser.value = new User();
}

void setCurrentUser(jsonString) async {
  try {
    if (json.decode(jsonString)['data'] != null) {
      final prefs = await _sharePrefs;
      await prefs.setString(
          'current_user', json.encode(json.decode(jsonString)['data']));
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: jsonString).toString());
    throw new Exception(e);
  }
}

Future<List<Token>> getSavedCards() async {
  final prefs = await _sharePrefs;
  final str = prefs.containsKey('razorPayID')
      ? prefs.getString('razorPayID')
      : "cust_FJ57PBzFr0bp2A";
  try {
    final url = Uri.tryParse(
        gc.getValue('razor_pay_url') + "customers/" + str + "/tokens");
    final response = await client.get(url, headers: {
      HttpHeaders.authorizationHeader: "Basic " +
          base64Encode(utf8.encode(gc.getValue('razor_pay_key') +
              ":" +
              gc.getValue('razor_pay_secret')))
    });
    return response.statusCode == 200
        ? TokenBase.fromMap(json.decode(response.body)).tokens
        : <Token>[];
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: e.toString()).toString());
    throw new Exception(e);
  }
}

Future<Token> addCreditCard(Map<String, dynamic> body) async {
  final prefs = await _sharePrefs;
  final str = prefs.containsKey('razorPayID')
      ? prefs.getString('razorPayID')
      : "cust_FJ57PBzFr0bp2A";
  final url = Uri.tryParse(
      gc.getValue('razor_pay_url') + "customers/" + str + "/tokens");
  final httpClient = new HttpClient();
  final request = await httpClient.postUrl(url);
  final reqStr = json.encode(body);
  request.headers.set(
      HttpHeaders.authorizationHeader,
      "Basic " +
          base64Encode(utf8.encode(gc.getValue('razor_pay_key') +
              ":" +
              gc.getValue('razor_pay_secret'))));
  request.headers.set('content-type', 'application/json');
  request.headers.contentType =
      new ContentType("application", "json", charset: "utf-8");
  request.write(reqStr);
  try {
    final response = await request.close();
    final reply = await response.transform(utf8.decoder).join();
    print(reply);
    return response.statusCode == 200
        ? Token.fromMap(json.decode(reply))
        : Token("", "", "", ATMCard(-1, -1, -1, "", "", "", false, false));
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<bool> deleteCard(String tokenID) async {
  final sharedPrefs = await _sharePrefs;
  final str = sharedPrefs.containsKey('razorPayID')
      ? sharedPrefs.getString('razorPayID')
      : "cust_FJ57PBzFr0bp2A";
  try {
    final url = Uri.tryParse(gc.getValue('razor_pay_url') +
        "customers/" +
        str +
        "/tokens/" +
        tokenID);
    final response = await client.delete(url, headers: {
      HttpHeaders.authorizationHeader: "Basic " +
          base64Encode(utf8.encode(gc.getValue('razor_pay_key') +
              ":" +
              gc.getValue('razor_pay_secret')))
    });
    return response.statusCode == 200 &&
        json.decode(response.body)['deleted'] as bool;
  } catch (e) {
    print(e);
    throw e;
  }
}

Future<User> getCurrentUser() async {
  final prefs = await _sharePrefs;
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value = User.fromJSON(json.decode(prefs.get('current_user')));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<User> updateProfile(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(gc.getValue('api_base_url') +
      "users/" +
      sharedPrefs.getString("spCustomerID"));
  try {
    final response = await client.post(url, body: body1, headers: headers);
    return response.statusCode == 200
        ? User.fromJSON(json.decode(response.body)['data'])
        : User();
  } catch (e) {
    throw e;
  }
}

Future<User> update(User user) async {
  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final url = Uri.parse(
      '${gc.getValue('api_base_url')}users/${currentUser.value.id}?$_apiToken');
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.json),
  );
  setCurrentUser(response.body);
  currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  return currentUser.value;
}

Future<List<WhereAbouts>> getAddresses() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "Api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue('api_base_url') +
      "delivery_addresses/" +
      (sharedPrefs.containsKey("spCustomerID")
          ? sharedPrefs.getString("spCustomerID")
          : "481"));
  try {
    final response = await client.get(url, headers: headers);
    return response.statusCode == 200
        ? AddressBase.fromMap(json.decode(response.body)).addresses
        : <WhereAbouts>[];
  } catch (e) {
    throw e;
  }
}

Future<OtherData> sendOTP(User user) async {
  final url = Uri.parse(gc.getValue("api_base_url") + "getmobile");
  try {
    final response = await client.post(url,
        body: user.signInMap,
        headers: {HttpHeaders.authorizationHeader: currentUser.value.apiToken});
    return response.statusCode == 200
        ? OtherData.fromMap(json.decode(response.body))
        : OtherData(Reply(response.body, false), "");
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url.toString()));
    throw e;
  }
}

Future<Customer> getUserData(int customerID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url =
      Uri.parse(gc.getValue('api_base_url') + "users/" + customerID.toString());
  try {
    final response = await client.post(url, headers: headers);
    return response.statusCode == 200
        ? Customer.fromMap(json.decode(response.body)['data'])
        : Customer(-1, "", "", "", "", "", <Medium>[], CustomField("", "", ""));
  } catch (e) {
    throw e;
  }
}

Future<WhereAbouts> addAddress(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  print(sharedPrefs.containsKey("spCustomerID"));
  final url = Uri.parse('${gc.getValue('api_base_url')}resadd/' +
      sharedPrefs.getString("spCustomerID"));
  try {
    final response = await client.post(url, body: body1, headers: headers);
    print(response.body);
    return response.statusCode == 200
        ? WhereAbouts.fromMap(json.decode(response.body)['data'])
        : WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url.toString()));
    return WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false);
  }
}

Future<WhereAbouts> updateAddress(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final body1 = jsonEncode(body);
  final url = Uri.parse(
      '${gc.getValue('api_base_url')}delivery_addresses_update/' +
          body['id'].toString());
  try {
    final response = await client.post(url, body: body1, headers: headers);
    return response.statusCode == 200
        ? WhereAbouts.fromMap(json.decode(response.body)['data'])
        : WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false);
  } catch (e) {
    print(e);
    print(CustomTrace(StackTrace.current, message: url.toString()));
    return WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false);
  }
}

Future<WhereAbouts> removeDeliveryAddress(int addressID) async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(
      '${gc.getValue('api_base_url')}delivery_addresses_delete/' +
          addressID.toString());
  try {
    final response = await client.get(url, headers: headers);
    return response.statusCode == 200
        ? WhereAbouts.fromMap(json.decode(response.body)['data'])
        : WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url.toString()));
    return WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false);
  }
}

Future<OtherData> verifyOTP(Map<String, dynamic> body) async {
  final url = Uri.tryParse(gc.getValue('api_base_url') + "getotp");
  try {
    final response = await client.post(url, body: body);
    print("OTP");
    print(response.body);
    return response.statusCode == 200
        ? OtherData.fromMap(json.decode(response.body))
        : OtherData(Reply("", false), "");
  } catch (e) {
    throw e;
  }
}

Future<String> imgBase() async {
  final url = Uri.tryParse(gc.getValue('api_base_url') + "sthree");
  try {
    final response = await client.get(url);
    print(response.body);
    var result = json.decode(response.body);
    if (result['success']) {
      print(result['data']['url']);
    }
    return result['data']['url'].toString();
  } catch (e) {
    throw e;
  }
}

Future<User> registerUser(Map<String, dynamic> body) async {
  final url = Uri.tryParse(gc.getValue('api_base_url') + "getdriverdetails");
  try {
    final response = await client.post(url, body: body);
    print(response.body);
    return response.statusCode == 200
        ? User.fromJSON(json.decode(response.body)['data'])
        : User();
  } catch (e) {
    throw e;
  }
}
