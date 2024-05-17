import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodigo_customer_app/helpers/maps_util.dart';
import 'package:foodigo_customer_app/models/slide.dart';
import 'package:foodigo_customer_app/models/slide_base.dart';
import 'package:geocoder/geocoder.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:scoped_model/scoped_model.dart';
import '../helpers/custom_trace.dart';
import '../models/coupon.dart';
import '../models/setting.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());
ValueNotifier<Address> deliveryAddress = new ValueNotifier(new Address());
Coupon coupon = new Coupon.fromMap({});
final navigatorKey = GlobalKey<NavigatorState>(),
    gc = new GlobalConfiguration();
final client = new Client();
Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

Future<Setting> initSettings() async {
  Setting _setting;
  final url = Uri.parse('${gc.getValue('api_base_url')}settings');
  try {
    final response = await client
        .get(url, headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    if (response.statusCode == 200 &&
        response.headers.containsValue('application/json')) {
      if (json.decode(response.body)['data'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'settings', json.encode(json.decode(response.body)['data']));
        _setting = Setting.fromJSON(json.decode(response.body)['data']);
        if (prefs.containsKey('language')) {
          _setting.mobileLanguage.value = Locale(prefs.get('language'), '');
        }
        _setting.brightness.value = prefs.getBool('isDark') ?? false
            ? Brightness.dark
            : Brightness.light;
        setting.value = _setting;
        setting.notifyListeners();
      }
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url.toString()).toString());
    return Setting.fromJSON({});
  }
  return setting.value;
}

Future<dynamic> setCurrentLocation() async {
  var location = new Location();
  MapsUtil mapsUtil = new MapsUtil();
  final whenDone = new Completer();
  Address _address = new Address();
  location.requestService().then((value) async {
    location.getLocation().then((_locationData) async {
      String _addressName = await mapsUtil.getAddressName(
          new LatLng(_locationData?.latitude, _locationData?.longitude),
          setting.value.googleMapsKey);
      _address = Address.fromMap({
        'address': _addressName,
        'coordinates': {
          'latitude': _locationData?.latitude,
          'longitude': _locationData?.longitude
        }
      });
      await changeCurrentLocation(_address);
      whenDone.complete(_address);
    }).timeout(Duration(seconds: 10), onTimeout: () async {
      await changeCurrentLocation(_address);
      whenDone.complete(_address);
      return null;
    }).catchError((e) {
      whenDone.complete(_address);
    });
  });
  return whenDone.future;
}

Future<Address> changeCurrentLocation(Address _address) async {
  if (!(_address.toMap() == null)) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_address', json.encode(_address.toMap()));
  }
  return _address;
}

Future<Address> getCurrentLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //await prefs.clear();
  if (prefs.containsKey('delivery_address')) {
    deliveryAddress.value =
        Address.fromMap(json.decode(prefs.getString('delivery_address')));
    return deliveryAddress.value;
  } else {
    deliveryAddress.value = Address.fromMap({
      "coordinates": {"latitude": 0.0, "longitude": 0.0}
    });
    return Address.fromMap({
      "coordinates": {"latitude": 0.0, "longitude": 0.0}
    });
  }
}

void setBrightness(Brightness brightness) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (brightness == Brightness.dark) {
    prefs.setBool("isDark", true);
    brightness = Brightness.dark;
  } else {
    prefs.setBool("isDark", false);
    brightness = Brightness.light;
  }
}

Future<void> setDefaultLanguage(String language) async {
  if (language != null) {
    final prefs = await SharedPreferences.getInstance();
    final p = await prefs.setString('language', language);
    if (p) print(setting.value.mobileLanguage.value.languageCode);
  }
}

Future<String> getDefaultLanguage(String defaultLanguage) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('language')) defaultLanguage = prefs.get('language');
  return defaultLanguage;
}

Future<void> saveMessageId(String messageId) async {
  if (messageId != null) {
    final prefs = await SharedPreferences.getInstance();
    final p = await prefs.setString('google.message_id', messageId);
    if (p) print(setting.value.mobileLanguage.value.languageCode);
  }
}

Future<String> getMessageId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.get('google.message_id');
}

Future<List<Slide>> getHomeSlides() async {
  final sharedPrefs = await _sharePrefs;
  Map<String, String> headers = {
    "api": sharedPrefs.getString("apiToken"),
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  final url = Uri.parse(gc.getValue('api_base_url') + "slides");
  try {
    final response = await client.get(url, headers: headers);
    // print(response.body);
    return response.statusCode == 200
        ? SlideBase.fromMap(json.decode(response.body)).slides
        : <Slide>[];
  } catch (e) {
    throw e;
  }
}
