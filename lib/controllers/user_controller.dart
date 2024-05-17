import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/elements/address_list_widget.dart';
import 'package:foodigo_customer_app/elements/saved_cards_list_widget.dart';
import 'package:foodigo_customer_app/generated/l10n.dart';
import 'package:foodigo_customer_app/models/address.dart';
import 'package:foodigo_customer_app/models/custom_field.dart';
import 'package:foodigo_customer_app/models/customer.dart';
import 'package:foodigo_customer_app/models/medium.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:foodigo_customer_app/models/razor_pay_order.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:foodigo_customer_app/models/token.dart';
import 'package:foodigo_customer_app/pages/saved_online_payment_methods_page.dart';
import 'package:foodigo_customer_app/repos/rest_repos.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helper.dart';
import '../models/user.dart';
import '../repos/user_repos.dart' as repository;

class UserController extends ControllerMVC {
  Order order;
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  bool isLoading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Stopwatch st = new Stopwatch();
  RazorPayOrder rpOrder;
  OverlayEntry loader;
  CameraPosition initialCameraPosition;
  WhereAbouts address;
  GoogleMapController controller;
  Customer customer;
  List<WhereAbouts> addresses;
  List<Token> tokens;
  Helper hp;

  UserController() {
    this.loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.loader = Helper.overlayLoader();
    print(states);
    print("eeeeeeeeeeeeee");
    print(state);
    print("ffffffffffffff");
    print(stateMVC);
    print("cccccccccccccc");
    print(scaffoldKey.currentContext);
    print("dddddddddddddd");
    print(loginFormKey.currentContext);
// this.hp = Helper.of(this.scaffoldKey.currentContext);
  }

  void logout() async {
    final sharedPrefs = await _sharedPrefs;
    final hp = Helper.of(stateMVC.context);
    bool p = false;
    sharedPrefs.getKeys().forEach((element) async => p = true &&
        (element == "spDeviceToken" ? p : await sharedPrefs.remove(element)));
    final q = await Fluttertoast.showToast(
        msg: p ? hp.loc.log_out + hp.loc.yes : hp.loc.unknown);
    if (p && q) {
      repository.currentUser.value.apiToken = null;
      hp.navigateWithoutGoBack('/login');
    } else
      print("Hi");
  }

  Future getimgbase() async {
    final sharedPrefs = await _sharedPrefs;
    var imgbase = sharedPrefs.getString("imgBase");
    return imgbase;
  }

  void waitUntilAddressAdd(Map<String, dynamic> body) async {
    final loc = S.of(stateMVC.context);
    final value = await repository.addAddress(body);
    setState(() => address = value == null
        ? WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false)
        : value);
    final p = await Fluttertoast.showToast(
        msg: address.addressID == -1
            ? loc.not_a_valid_address
            : loc.new_address_added_successfully);
    if (p) Navigator.pop(stateMVC.context);
  }

  void waitForCustomerDetails(int customerID) async {
    final value = await repository.getUserData(customerID);
    setState(() => customer = value == null
        ? Customer(-1, "", "", "", "", "", <Medium>[], CustomField("", "", ""))
        : value);
  }

  Future<Duration> waitForDeliveryAddresses() async {
    st.start();
    try {
      final value = await repository.getAddresses();
      setState(() => addresses = value == null ? <WhereAbouts>[] : value);
      st.stop();
      return st.elapsed;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void waitUntilProfileUpdate(Map<String, dynamic> body) async {
    final value = await repository.updateProfile(body);
    if (value != null && value != User()) {
      final p = await Navigator.pushNamed(stateMVC.context, '/pages',
          arguments: RouteArgument(heroTag: "2"));
      print(p);
    } else
      print("failure");
  }

  void waitUntilUpdateAddress(
      Map<String, dynamic> body, BuildContext context) async {
    final value = await repository.updateAddress(body);
    setState(() => address = value == null
        ? WhereAbouts(-1, "", "", LatLng(0.0, 0.0), false)
        : value);
    if (address.addressID != -1) {
      final p =
          await Fluttertoast.showToast(msg: "Addresses Added Successfully");
      if (p) Navigator.pop(context);
    } else {
      final p = await Fluttertoast.showToast(msg: "Problem Updating Address");
      if (p) print("Hi");
    }
  }

  void waitUntilDeleteAddress(
      int addressID, AddressPageListWidgetState widgetState) async {
    final hp = Helper.of(widgetState.context);
    final value = await repository.removeDeliveryAddress(addressID);
    final p = await Fluttertoast.showToast(
        msg: value.addressID == -1
            ? "Error deleting address"
            : hp.loc.delivery_address_removed_successfully);
    if (p) {
      widgetState.didUpdateWidget(widgetState.widget);
      hp.goBack();
    }
  }

  void getOTP() async {
    final value = await repository.sendOTP(user);
    if (value.reply.success) {
      final p = await Navigator.pushNamed(state.context, '/verifyOTP',
          arguments: RouteArgument(heroTag: user.phone, param: value.data));
      print(p);
    } else {
      final q = await Fluttertoast.showToast(msg: value.reply.message);
      if (q) print("Bye");
    }
  }

  void checkOTP(Map<String, dynamic> body) async {
    final sharedPrefs = await _sharedPrefs;
    final value = await repository.verifyOTP(body);
    print(value.data);
    if (value.data != " OTP Verification Failure") {
      print("value.data");
      final imgBase = await repository.imgBase();
      if (value.reply.success) setState(() => user = User.fromJSON(value.data));
      if (user.isRegistered) {
        final r = await sharedPrefs.setString("imgBase", imgBase);
        final p = await sharedPrefs.setString("spCustomerID", user.id);
        final q = await sharedPrefs.setString("apiToken", user.apiToken);
        if (p && q && r) {
          final s = await Navigator.of(stateMVC.context)
              .pushNamedAndRemoveUntil(
                  '/pages', (Route<dynamic> route) => false,
                  arguments: RouteArgument(id: user.id, heroTag: "0"));
          print(s);
        }
      } else {
        final s = await sharedPrefs.setString("imgBase", imgBase);
        final p = await Navigator.pushNamed(stateMVC.context, '/register',
            arguments: RouteArgument(heroTag: user.phone));
        if (s) print(p);
      }
    } else if (value.data == " OTP Verification Failure" &&
        await Fluttertoast.showToast(msg: "Wrong OTP")) {
      print("Bye");
    }
  }

  void resendOTP() async {
    final value = await repository.sendOTP(user);
    if (value.reply.success) setState(() => user.otp = value.data.toString());
  }

  void waitUntilRegister(Map<String, dynamic> body) async {
    final sharedPrefs = await _sharedPrefs;
    try {
      final value = await repository.registerUser(body);
      if (value.isCompleteProfile) {
        final p = await sharedPrefs.setString("spCustomerID", value.id);
        final q = await sharedPrefs.setString("apiToken", value.apiToken);
        final r = await waitUntilRazorPayCustomerAdd(value.map);
        if (p && q && r) {
          final s = await Navigator.of(stateMVC.context)
              .pushNamedAndRemoveUntil(
                  '/pages', (Route<dynamic> route) => false,
                  arguments: RouteArgument(id: value.id, heroTag: "0"));
          print(s);
        }
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<Duration> waitForSavedCards(
      SavedOnlinePaymentMethodsPageState payState) async {
    st.start();
    final stream = await repository.getSavedCards();
    payState.setState(() => tokens = stream == null ? <Token>[] : stream);
    st.stop();
    return st.elapsed;
  }

  Future<void> waitUntilPlaceOrder(Map<String, dynamic> body) async {
    final sx = Helper.of(stateMVC.context);
    order = await placeOrder(body);
    if (order.orderID != -1) {
      final p = await Navigator.popAndPushNamed(
          stateMVC.context, '/currentOrders',
          arguments: "Home");
      final q = await Fluttertoast.showToast(
          msg: sx.loc.your_order_has_been_successfully_submitted,
          gravity: ToastGravity.BOTTOM);
      if (q) print(p);
    } else {
      final r = await Fluttertoast.showToast(msg: "Error Placing Order");
      if (r) print('Error');
    }
  }

  void waitUntilAddCard(Map<String, dynamic> body) async {
    final loc = S.of(stateMVC.context);
    final value = await repository.addCreditCard(body);
    final p = await Fluttertoast.showToast(
        msg: value.tokenID.isNotEmpty
            ? loc.payment_card_updated_successfully
            : loc.your_credit_card_not_valid);
    if (p) Navigator.pop(stateMVC.context);
  }

  Future<bool> waitUntilRazorPayCustomerAdd(Map<String, dynamic> body) async {
    final prefs = await _sharedPrefs;
    try {
      final value = await addRazorPayCustomer(body);
      if (value.customerID.isNotEmpty) {
        final p = await prefs.setString('razorPayID', value.customerID);
        final q = await Fluttertoast.showToast(
            msg: p
                ? "Razor Pay Customer Registered Successfully"
                : "Error Registering to Razorpay");
        return (p && q);
      } else {
        final r =
            await Fluttertoast.showToast(msg: "Error Registering to Razorpay");
        return !r;
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> waitUntilRazorPayOrderAdd(Map<String, dynamic> body) async {
    rpOrder = await uploadOrder(body);
    final p = await Fluttertoast.showToast(
        msg: rpOrder.orderID.isNotEmpty
            ? "Razor Pay Order Registered Successfully"
            : "Error Registering Order to Razorpay");
    if (p) print(rpOrder.entity);
  }

  void waitUntilUploadOrder(
      Map<String, dynamic> body, Map<String, dynamic> cardData) async {
    try {
      final prefs = await _sharedPrefs;
      final rpcID = prefs.getString('razorPayID');
      print(cardData['cvv']);
      print(cardData['cno']);
      print(body);
      final data = {
        "amount": body['razor_pay']['amount'],
        "currency": body['razor_pay']['currency'],
        "email": body['razor_pay_customer']['email'],
        "contact": body['razor_pay_customer']['contact'],
        "customer_id": rpcID,
        "save": "0",
        "method": "card",
        "card[number]": cardData['cno'],
        "card[cvv]": cardData['cvv'],
        "card[name]": body['razor_pay_customer']['name']
      };
      print(data);
      final cartData = body['cart'];
      cartData["method"] = "razorpay";
      await waitUntilRazorPayOrderAdd(body['razor_pay']);
      cartData["order"] = rpOrder.orderID;
      print(cartData);
      await waitUntilPlaceOrder(cartData);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void waitUntilCardDelete(String tokenID,
      SavedOnlinePaymentOptionsListWidgetState widgetState) async {
    final flag = await repository.deleteCard(tokenID);
    if (flag) widgetState.didUpdateWidget(widgetState.widget);
  }
}
