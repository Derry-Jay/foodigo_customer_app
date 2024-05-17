import '../helpers/custom_trace.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends Model {
  String mainColor,
      mainDarkColor,
      secondColor,
      secondDarkColor,
      accentColor,
      accentDarkColor,
      scaffoldDarkColor,
      scaffoldColor,
      googleMapsKey,
      fcmKey,
      appName = '',
      defaultCurrency,
      distanceUnit,
      appVersion;
  bool payPalEnabled = true,
      stripeEnabled = true,
      enableVersion = true,
      currencyRight = false,
      razorPayEnabled = true;
  double defaultTax;
  int currencyDecimalDigits = 2;
  List<String> homeSections = <String>[];
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  ValueNotifier<Locale> mobileLanguage;
  ValueNotifier<Brightness> brightness = new ValueNotifier(Brightness.light);

  Setting() {
    getLang();
  }

  void getLang() async {
    final prefs = await _sharedPrefs;
    mobileLanguage = new ValueNotifier(new Locale(
        prefs.containsKey('language') ? prefs.getString('language') : 'en',
        ''));
    notifyListeners();
  }

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      appName = jsonMap['app_name'] ?? null;
      mainColor = jsonMap['main_color'] ?? null;
      mainDarkColor = jsonMap['main_dark_color'] ?? '';
      secondColor = jsonMap['second_color'] ?? '';
      secondDarkColor = jsonMap['second_dark_color'] ?? '';
      accentColor = jsonMap['accent_color'] ?? '';
      accentDarkColor = jsonMap['accent_dark_color'] ?? '';
      scaffoldDarkColor = jsonMap['scaffold_dark_color'] ?? '';
      scaffoldColor = jsonMap['scaffold_color'] ?? '';
      googleMapsKey = jsonMap['google_maps_key'] ?? null;
      fcmKey = jsonMap['fcm_key'] ?? null;
      mobileLanguage.value = Locale(jsonMap['mobile_language'] ?? "en", '');
      appVersion = jsonMap['app_version'] ?? '';
      distanceUnit = jsonMap['distance_unit'] ?? 'km';
      enableVersion =
          jsonMap['enable_version'] == null || jsonMap['enable_version'] == '0'
              ? false
              : true;
      defaultTax = double.tryParse(jsonMap['default_tax'] ?? '0') ?? 0.0;
      defaultCurrency = jsonMap['default_currency'] ?? '';
      currencyDecimalDigits =
          int.tryParse(jsonMap['default_currency_decimal_digits'] ?? '2') ?? 2;
      currencyRight =
          jsonMap['currency_right'] == null || jsonMap['currency_right'] == '0'
              ? false
              : true;
      payPalEnabled =
          jsonMap['enable_paypal'] == null || jsonMap['enable_paypal'] == '0'
              ? false
              : true;
      stripeEnabled =
          jsonMap['enable_stripe'] == null || jsonMap['enable_stripe'] == '0'
              ? false
              : true;
      razorPayEnabled = jsonMap['enable_razorpay'] == null ||
              jsonMap['enable_razorpay'] == '0'
          ? false
          : true;
      for (int _i = 1; _i <= 12; _i++) {
        homeSections.add(jsonMap['home_section_' + _i.toString()] != null
            ? jsonMap['home_section_' + _i.toString()]
            : 'empty');
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> get json{
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["app_name"] = appName;
    map["default_tax"] = defaultTax;
    map["default_currency"] = defaultCurrency;
    map["default_currency_decimal_digits"] = currencyDecimalDigits;
    map["currency_right"] = currencyRight;
    map["enable_paypal"] = payPalEnabled;
    map["enable_stripe"] = stripeEnabled;
    map["enable_razorpay"] = razorPayEnabled;
    map["mobile_language"] = mobileLanguage.value.languageCode;
    return map;
  }

  void setLanguage(Locale locale) async {
    final pref = await _sharedPrefs;
    mobileLanguage.value = locale;
    final p = await pref.setString('language', locale.languageCode);
    if (p) notifyListeners();
  }

  void changeDirection() {
    if (mobileLanguage.value == Locale("en"))
      mobileLanguage.value = Locale("fr");
    else if (mobileLanguage.value == Locale("fr"))
      mobileLanguage.value = Locale("ar");
    else
      mobileLanguage.value = Locale("en");
    notifyListeners();
  }
}
