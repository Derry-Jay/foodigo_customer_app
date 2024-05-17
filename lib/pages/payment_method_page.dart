import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/my_button.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PaymentMethod { PayOnDelivery, OnlinePayment }

class PaymentMethodPage extends StatefulWidget {
  final RouteArgument rar;
  PaymentMethodPage(this.rar);
  @override
  PaymentMethodPageState createState() => PaymentMethodPageState();
}

class PaymentMethodPageState extends StateMVC<PaymentMethodPage> {
  Razorpay rp = new Razorpay();
  HotelController con;
  Map<String, dynamic> cartData = new Map<String, dynamic>(),
      addressData = new Map<String, dynamic>();
  PaymentMethod at = PaymentMethod.PayOnDelivery;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  Helper get hp => Helper.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  bool isLoading = false;
  PaymentMethodPageState() : super(HotelController()) {
    con = controller;
  }
  void setRadioValue(PaymentMethod type) {
    setState(() => at = type);
  }

  void getData() async {
    final sharedPrefs = await _sharedPrefs;
    if (mounted) {
      hp.lockScreenRotation();
      hp.getConnectStatus();
    }
    cartData = json.decode(sharedPrefs.getString("cartData"));
    con.waitForCustomerData(int.tryParse(sharedPrefs.containsKey("spCustomerID")
            ? sharedPrefs.getString("spCustomerID")
            : "-1") ??
        -1);
    addressData = json.decode(sharedPrefs.getString("defaultAddress"));
    con.waitForHotelData(cartData['restaurant_id']);
    rp.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    rp.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    rp.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("____________________");
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    cartData["method"] = "razorpay";
    cartData["tax"] = (widget.rar.tax["tax"]);
    cartData["delivery_fee"] = (widget.rar.tax["deliveryfee"]);
    cartData["coupon_owner"] = (widget.rar.tax["coupon_owner"]);
    cartData["payment"] = response.paymentId;
    cartData["order_amount"] = widget.rar.tax["order_amount"].toString();
    cartData["order_final_amount"] =
        widget.rar.tax["order_final_amount"].toString();
    cartData["total_amount"] =
        (int.tryParse(widget.rar.param["amount"]) / 100).toString();
    cartData["hint"] = (widget.rar.tax["hint"]);
    if (widget.rar.id.isNotEmpty) {
      cartData["coupon_id"] = widget.rar.id;
      cartData["coupon_amount"] = (widget.rar.tax["coupon_amount"]);
    }
    await con.waitUntilPlaceOrder(cartData);
    print("------------------------");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("==================");
    print(cartData);
    print(widget.rar.param);
    print("++++++++++++++++++++");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void proceed() async {
    switch (at) {
      case PaymentMethod.PayOnDelivery:
        setState(setLoading);
        cartData["method"] = "cash";
        cartData["tax"] = (widget.rar.tax["tax"]);
        cartData["delivery_fee"] = (widget.rar.tax["deliveryfee"]);
        cartData["coupon_owner"] = (widget.rar.tax["coupon_owner"]);
        cartData["payment"] = "";
        cartData["total_amount"] =
            (int.tryParse(widget.rar.param["amount"]) / 100).toString();
        cartData["hint"] = (widget.rar.tax["hint"]);
        cartData["order_amount"] = widget.rar.tax["order_amount"].toString();
        cartData["order_final_amount"] =
            widget.rar.tax["order_final_amount"].toString();
        if (widget.rar.id.isNotEmpty) {
          cartData["coupon_id"] = widget.rar.id;
          cartData["coupon_amount"] = (widget.rar.tax["coupon_amount"]);
        }
        await con.waitUntilPlaceOrder(cartData);
        setState(setLoading);
        break;
      case PaymentMethod.OnlinePayment:
        final gc = GlobalConfiguration();
        final sharedPrefs = await _sharedPrefs;
        final rpa =
            gc.getValue<Map<String, dynamic>>('razor_pay_plugin_attributes');
        setState(setLoading);
        await con.waitForRazorPayOrder(widget.rar.param);
        Map<String, dynamic> options = con.rpo.json;
        options['image'] = "assets/images/icon.png";
        options['customer_id'] = sharedPrefs.getString('razorPayID');
        options['prefill'] = con.user.json;
        options['theme'] = rpa['theme'];
        options['external'] = rpa['external'];
        print(options);
        rp.open(options);
        setState(setLoading);
        // print();
        // final str = json.encode({
        //   "razor_pay": widget.rar.param,
        //   "cart": cartData,
        //   "razor_pay_customer": con.user.json
        // });
        // hp.navigateTo('/savedOnlinePaymentMethods',
        //     arguments: RouteArgument(param: CardViewMode.Verify, heroTag: str));
        break;
      default:
        print("Hi");
        break;
    }
  }

  void setLoading() {
    isLoading = !isLoading;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(hp.loc.select_your_preferred_payment_mode,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          // leading: IconButton(
          //     icon: Icon(Icons.arrow_back, color: Colors.black),
          //     onPressed: hp.goBack),
          elevation: 0,
          backgroundColor: Color(0xfffbfbfb)),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: height / 80),
          child: Column(
              children: [
                Container(
                    // width: width / 2,
                    // height: 200
                    child: Row(children: [
                      Column(
                          children: [
                            Icon(Icons.circle,
                                size: 12, color: Color(0xffBAD600)),
                            DottedLine(
                                lineLength: height / 7.2057594037927936,
                                // height: height / 1000,
                                // width: width / 400,
                                direction: Axis.vertical,
                                dashColor: Color(0xffBAD600)),
                            Icon(Icons.trip_origin_outlined,
                                color: Color(0xffBAD600), size: 12)
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center),
                      SizedBox(width: width / 25),
                      IntrinsicWidth(
                        child: Column(
                            children: [
                              Column(children: [
                                Container(
                                  width: width / 2,
                                  child: Text(
                                    con.hotel == null ? "" : con.hotel.restName,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.777216,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                    "ETA: " +
                                        (con.hotel == null
                                            ? "0"
                                            : ((hp.travelTime1(
                                                            con.hotel
                                                                .coordinates,
                                                            LatLng(
                                                                cartData[
                                                                    'customer_lat'],
                                                                cartData[
                                                                    'customer_lang'])) *
                                                        5) /
                                                    3)
                                                .ceil()
                                                .toString()) +
                                        "mins",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.1072,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    con.hotel == null
                                        ? ""
                                        : ("Distance: " +
                                            (con.hotel == null
                                                ? "0"
                                                : hp
                                                    .distanceInKM(
                                                        con.hotel.coordinates,
                                                        LatLng(
                                                            cartData[
                                                                'customer_lat'],
                                                            cartData[
                                                                'customer_lang']))
                                                    .ceil()
                                                    .toString()) +
                                            " Kms"),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.1072,
                                        fontWeight: FontWeight.w500))
                              ], crossAxisAlignment: CrossAxisAlignment.start),
                              Divider(
                                  height: height / 40,
                                  color: Color(0xffE2E0E0),
                                  indent: 0,
                                  endIndent: 0,
                                  thickness: 1),
                              Column(children: [
                                Text(
                                    addressData == null
                                        ? ""
                                        : (addressData['type'] == null
                                            ? ""
                                            : addressData['type']),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.777216,
                                        fontWeight: FontWeight.w600)),
                                Text(
                                  addressData == null
                                      ? ""
                                      : (addressData['area'] == null
                                          ? ""
                                          : addressData['area']),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.1072,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  addressData == null
                                      ? ""
                                      : (addressData['clipped_address'] == null
                                          ? ""
                                          : addressData['clipped_address']),
                                  style: TextStyle(
                                      fontSize: 13.1072,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                )
                              ], crossAxisAlignment: CrossAxisAlignment.start)
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start),
                      )
                    ], mainAxisAlignment: MainAxisAlignment.start),
                    color: Color(0xffF7F7F7),
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 25,
                        vertical: height / 46.11686018427387904)),
                Container(
                    child: Text(hp.loc.payment_mode.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA11414))),
                    margin: EdgeInsets.only(
                        left: width / 50,
                        top: height / 40,
                        bottom: height / 80)),
                for (PaymentMethod i in PaymentMethod.values)
                  GestureDetector(
                      child: Card(
                          margin: EdgeInsets.only(
                              left: width / 100, bottom: height / 80),
                          child: Row(
                            children: [
                              Radio<PaymentMethod>(
                                  activeColor: Colors.black,
                                  value: i,
                                  groupValue: at,
                                  onChanged: setRadioValue),
                              Text(
                                  i == PaymentMethod.PayOnDelivery
                                      ? hp.loc.cash_on_delivery
                                      : hp.loc.razorpayPayment,
                                  // EnumToString.convertToString(i).toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600))
                            ],
                          ),
                          elevation: 3.2),
                      onTap: () {
                        setRadioValue(i);
                      }),
                SizedBox(height: height / 2.5),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween)),
      bottomNavigationBar: Container(
          child: MyButton(
              label: isLoading
                  ? "Processing..."
                  : (at == PaymentMethod.PayOnDelivery
                      ? hp.loc.confirm_payment
                      : hp.loc.clickToPayWithRazorpayMethod),
              dimensions: dimensions,
              labelSize: 14,
              heightFactor: 50,
              widthFactor: 2.5,
              color: isLoading ? 0xff817C7C : 0xffa11414,
              elevation: 5,
              radiusFactor: 0,
              labelWeight: FontWeight.w600,
              onPressed: proceed),
          width: double.infinity),
    );
  }
}
