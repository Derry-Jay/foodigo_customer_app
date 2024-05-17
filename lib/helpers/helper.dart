import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/active_order_item_widget.dart';
import 'package:foodigo_customer_app/elements/address_item_widget.dart';
import 'package:foodigo_customer_app/elements/address_popup_widget.dart';
import 'package:foodigo_customer_app/elements/banner_item.dart';
import 'package:foodigo_customer_app/elements/categories_carousel_widget.dart';
import 'package:foodigo_customer_app/elements/coupon_item_widget.dart';
import 'package:foodigo_customer_app/elements/cuisine_item_widget.dart';
import 'package:foodigo_customer_app/elements/cuisines_grid_widget.dart';
import 'package:foodigo_customer_app/elements/custom_dialog_box_widget.dart';
import 'package:foodigo_customer_app/elements/custom_tab_and_list.dart';
import 'package:foodigo_customer_app/elements/delivered_order_item_widget.dart';
import 'package:foodigo_customer_app/elements/filter_builder_widget.dart';
import 'package:foodigo_customer_app/elements/food_item_widget.dart';
import 'package:foodigo_customer_app/elements/hotel_item_widget.dart';
import 'package:foodigo_customer_app/models/address.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/models/category.dart';
import 'package:foodigo_customer_app/models/coupon.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:foodigo_customer_app/models/food.dart';
import 'package:foodigo_customer_app/models/menu.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:foodigo_customer_app/models/ordered_food.dart';
import 'package:foodigo_customer_app/models/restaurant.dart';
import 'package:foodigo_customer_app/models/slide.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/parser.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../elements/circular_loader.dart';
import '../repos/settings_repos.dart';
import 'app_config.dart' as config;
import 'custom_trace.dart';

typedef OnItemSearch<T> = List<T> Function(List<T> list, String text);
typedef ValidateSelectedItem<T> = bool Function(List<T> list, T item);

enum CardViewMode { Verify, Delete }

class Helper {
  BuildContext context;
  DateTime currentBackPressTime;
  String imgBaseUrl;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  S get loc => S.of(context);
  ThemeData get theme => Theme.of(context);
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get pixelRatio => dimensions.devicePixelRatio;
  double get textScaleFactor => dimensions.textScaleFactor;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  Helper.of(BuildContext context) {
    this.context = context;
    getImageBase();
  }

  // for mapping data retrieved form json array
  static getData(Map<String, dynamic> data) {
    return data['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data'] as int) ?? 0;
  }

  static double getDoubleData(Map<String, dynamic> data) {
    return (data['data'] as double) ?? 0;
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data'] as bool) ?? false;
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  static Future<Marker> getMarker(Map<String, dynamic> res) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/img/marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(res['id']),
        icon: BitmapDescriptor.fromBytes(markerIcon),
//        onTap: () {
//          //print(res.name);
//        },
        anchor: Offset(0.5, 0.5),
        infoWindow: InfoWindow(
            title: res['name'],
            snippet: getDistance(
                res['distance'].toDouble(), setting.value.distanceUnit),
            onTap: () {
              print(CustomTrace(StackTrace.current, message: 'Info Window'));
            }),
        position: LatLng(
            double.parse(res['latitude']), double.parse(res['longitude'])));

    return marker;
  }

  static Future<Marker> getMyPositionMarker(
      double latitude, double longitude) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/my_marker.png', 120);
    final Marker marker = Marker(
        markerId: MarkerId(Random().nextInt(100).toString()),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        anchor: Offset(0.5, 0.5),
        position: LatLng(latitude, longitude));

    return marker;
  }

  static List<Icon> getStarsList(double rate, {double size = 18}) {
    var list = <Icon>[];
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(Icon(Icons.star_half, size: size, color: Color(0xFFFFB24D)));
    }
    list.addAll(
        List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
      return Icon(Icons.star_border, size: size, color: Color(0xFFFFB24D));
    }));
    return list;
  }

  static Widget getPrice(double myPrice, BuildContext context,
      {TextStyle style, String zeroPlaceholder = '-'}) {
    if (style != null) {
      style = style.merge(TextStyle(fontSize: style.fontSize + 2));
    }
    try {
      if (myPrice == 0) {
        return Text(zeroPlaceholder,
            style: style ?? Theme.of(context).textTheme.subtitle1);
      }
      return RichText(
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        text: setting.value?.currencyRight != null &&
                setting.value?.currencyRight == false
            ? TextSpan(
                text: setting.value?.defaultCurrency,
                style: style == null
                    ? Theme.of(context).textTheme.subtitle1.merge(
                          TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .fontSize -
                                  6),
                        )
                    : style.merge(TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: style.fontSize - 6)),
                children: <TextSpan>[
                  TextSpan(
                      text: myPrice.toStringAsFixed(
                              setting.value?.currencyDecimalDigits) ??
                          '',
                      style: style ?? Theme.of(context).textTheme.subtitle1),
                ],
              )
            : TextSpan(
                text: myPrice.toStringAsFixed(
                        setting.value?.currencyDecimalDigits) ??
                    '',
                style: style ?? Theme.of(context).textTheme.subtitle1,
                children: <TextSpan>[
                  TextSpan(
                    text: setting.value?.defaultCurrency,
                    style: style == null
                        ? Theme.of(context).textTheme.subtitle1.merge(
                              TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .fontSize -
                                      6),
                            )
                        : style.merge(TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: style.fontSize - 6)),
                  ),
                ],
              ),
      );
    } catch (e) {
      return Text('');
    }
  }

  static double getTotalOrderPrice(List<OrderedFood> foodOrder) {
    double total = 0.0;
    if (foodOrder != null && foodOrder.isNotEmpty)
      for (OrderedFood i in foodOrder)
        total += (double.tryParse(i.price ?? "0.0") ?? 0.0) * i.quantity;
    print("================");
    print(total);
    print(total);
    print("------------");
    return total;
  }

  Future<List<String>> getLocalStorageKeys() async {
    final sharedPrefs = await _sharedPrefs;
    return sharedPrefs.getKeys().toList();
  }

  Widget getAddressesList(List<WhereAbouts> addresses) {
    return addresses == null
        ? Image.asset("assets/images/loading_trend.gif")
        : ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (context, index) =>
                AddressItemWidget(address: addresses[index]),
            physics: AlwaysScrollableScrollPhysics());
  }

  void rollbackOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void lockScreenRotation() {
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.landscapeRight,
      // DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);
  }

  static String getDistance(double distance, String unit) {
    String _unit = setting.value.distanceUnit;
    if (_unit == 'km') {
      distance *= 1.60934;
    }
    return distance != null ? distance.toStringAsFixed(2) + " " + unit : "";
  }

  static bool parseBool(String source) {
    return source != null && source != "" && source.toLowerCase() == "true";
  }

  Future<DateTime> getDatePicker(TextEditingController tc) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: DateTime(today.year, today.month),
        lastDate: DateTime(today.year + 100, today.month));
    tc.text = putDateToString(picked);
    return picked;
  }

  static String skipHtml(String htmlString) {
    try {
      var document = parse(htmlString);
      String parsedString = parse(document.body.text).documentElement.text;
      return parsedString;
    } catch (e) {
      return '';
    }
  }

  static Html applyHtml(context, String html, {TextStyle style}) {
    return Html(
      data: html ?? '',
      style: {
        "*": Style(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          color: Theme.of(context).hintColor,
          fontSize: FontSize(16.0),
          display: Display.INLINE_BLOCK,
          width: config.App(context).appWidth(100),
        ),
        "h4,h5,h6": Style(
          fontSize: FontSize(18.0),
        ),
        "h1,h2,h3": Style(
          fontSize: FontSize.xLarge,
        ),
        "br": Style(
          height: 0,
        ),
        "p": Style(
          fontSize: FontSize(16.0),
        )
      },
    );
  }

  static OverlayEntry overlayLoader() {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      final theme = Theme.of(context);
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: theme.primaryColor.withOpacity(0.85),
          child: CircularLoader(
              duration: Duration(seconds: 5),
              heightFactor: 16,
              widthFactor: 16,
              color: Color(0xffA11414),
              loaderType: LoaderType.PouringHourGlass),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader?.remove();
      } catch (e) {}
    });
  }

  static String limitString(String text,
      {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) +
        (text.length > limit ? hiddenText : '');
  }

  String getCreditCardNumber(String number) {
    String result = '';
    if (number != null && number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static Uri getUri(String path) {
    String _path = Uri.parse(GlobalConfiguration().getValue('base_url')).path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
    Uri uri = Uri(
        scheme: Uri.parse(GlobalConfiguration().getValue('base_url')).scheme,
        host: Uri.parse(GlobalConfiguration().getValue('base_url')).host,
        port: Uri.parse(GlobalConfiguration().getValue('base_url')).port,
        path: _path + path);
    return uri;
  }

  Color getColorFromHex(String hex) {
    if (hex.contains('#')) {
      return Color(int.parse(hex.replaceAll("#", "0xFF")));
    } else {
      return Color(int.parse("0xFF" + hex));
    }
  }

  static BoxFit getBoxFit(String boxFit) {
    switch (boxFit) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'none':
        return BoxFit.none;
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  void getImageBase() async {
    final sharedPrefs = await _sharedPrefs;
    this.imgBaseUrl = sharedPrefs.containsKey("imgBase")
        ? sharedPrefs.getString("imgBase")
        : "";
  }

  static AlignmentDirectional getAlignmentDirectional(
      String alignmentDirectional) {
    switch (alignmentDirectional) {
      case 'top_start':
        return AlignmentDirectional.topStart;
      case 'top_center':
        return AlignmentDirectional.topCenter;
      case 'top_end':
        return AlignmentDirectional.topEnd;
      case 'center_start':
        return AlignmentDirectional.centerStart;
      case 'center':
        return AlignmentDirectional.topCenter;
      case 'center_end':
        return AlignmentDirectional.centerEnd;
      case 'bottom_start':
        return AlignmentDirectional.bottomStart;
      case 'bottom_center':
        return AlignmentDirectional.bottomCenter;
      case 'bottom_end':
        return AlignmentDirectional.bottomEnd;
      default:
        return AlignmentDirectional.bottomEnd;
    }
  }

  static timecheck(String time, LatLng userloc, LatLng resloc) {
    List<String> resTime = time.trim().split(":");
    final _distanceInMeters1 = Geolocator.distanceBetween(
        userloc.latitude, userloc.longitude, resloc.latitude, resloc.longitude);
    final meters = _distanceInMeters1;
    final timeslot = meters / 600;
    final sec = int.tryParse(resTime.last) ?? 0;
    final data = (int.tryParse(resTime.first) ?? 0) + (timeslot / 60).round();
    int locTime = int.tryParse(resTime.first) ?? 0;
    int hr = int.tryParse(resTime.first) ?? 0;
    int min = int.tryParse(resTime[1]) ?? 0;
    print(sec);
    print(resTime);
    print(timeslot);
    print((timeslot / 60).round());
    print(meters);
    print(locTime);
    print(data);
    if ((timeslot / 60).round() > 0)
      hr = (int.tryParse(resTime.first) ?? 0) + (timeslot / 60).round();
    else
      min = (int.tryParse(resTime[1]) ?? 0) + (timeslot).round();
    final hour = hr == 0 ? "" : hr.toString() + " hr";
    final mins = min == 0 ? "" : min.toString() + " mins";
    final timeOfDriver = hour.toString() + " " + mins.toString();
    return timeOfDriver;
  }

  String putDateToString(DateTime dt) =>
      dt == null ? "" : dt.month.toString() + "/" + dt.year.toString();

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      final p = await Fluttertoast.showToast(
          msg: loc == null ? "Tap Again to Exit" : loc.tapAgainToLeave);
      return Future.value(!p);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  String trans(String text) {
    switch (text) {
      case "App\\Notifications\\StatusChangedOrder":
        return loc.order_status_changed;
      case "App\\Notifications\\NewOrder":
        return loc.new_order_from_client;
      case "km":
        return loc.km;
      case "mi":
        return loc.mi;
      default:
        return "";
    }
  }

  Map<String, double> locationToMap(LatLng a) {
    Map<String, double> map = {
      "longitude": a.longitude,
      "latitude": a.latitude
    };
    return map;
  }

  double haversineDistance(LatLng a, LatLng b) {
    double dLat = ((b.latitude - a.latitude).abs() * 11) / 630;
    double dLong = ((b.longitude - a.longitude).abs() * 11) / 630;
    final v1 = 1 + cos(dLat);
    final v2 = 2 *
        cos((a.latitude * 11) / 630) *
        cos((b.latitude * 11) / 630) *
        cos(dLong);
    return (12.742 * asin(sqrt(((v1 - v2).abs()) / 2)));
  }

  double distanceInKM(LatLng a, LatLng b) {
    final _distanceInMeters = Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
    return _distanceInMeters / 1000;
  }

  double travelTime1(LatLng a, LatLng b) {
    var _distanceInMeters1 = Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
    var meters = _distanceInMeters1;
    var time = meters / 600;
    return time;
  }

  double travelTime2(LatLng a, LatLng b, LatLng c, LatLng d) {
    var _distanceInMeters1 = Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
    var _distanceInMeters2 = Geolocator.distanceBetween(
        c.latitude, c.longitude, d.latitude, d.longitude);
    var meters = _distanceInMeters1 + _distanceInMeters2;
    var time = meters / 600;
    return time;
  }

  void goBack({dynamic result}) {
    result == null ? Navigator.pop(context) : Navigator.pop(context, result);
  }

  Widget getCategoryList(
          List<Category> categories, MediaQueryData dimensions) =>
      categories == null
          ? CircularLoader(
              duration: Duration(seconds: 5),
              heightFactor: 16,
              widthFactor: 16,
              color: Color(0xffa11414),
              loaderType: LoaderType.PouringHourGlass)
          : CategoriesCarouselWidget(
              categories: categories,
              dimensions: dimensions,
              imgbase: imgBaseUrl);

  GridView getCuisinesList(List<Cuisine> cuisines, MediaQueryData dimensions) {
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
          childAspectRatio:
              dimensions.size.height / (1.25 * dimensions.size.width)),
    );
  }

  CarouselSlider getSlides(List<Slide> slides) => CarouselSlider.builder(
      itemCount: slides.length,
      itemBuilder: (context, int i, int j) {
        return BannerItemWidget(
          slide: slides[i],
          dimensions: MediaQuery.of(context),
          imgBase: imgBaseUrl,
        );
      },
      options: CarouselOptions(autoPlay: true, viewportFraction: 1.0));

  Widget getHotelsList(List<Restaurant> hotels, MediaQueryData dimensions) {
    return Expanded(
      child: ListView.builder(
          padding: EdgeInsets.all(5),
          itemCount: hotels == null ? 0 : hotels.length,
          itemBuilder: (context, index) {
            return HotelItemWidget(
              hotel: hotels[index],
              dimensions: dimensions,
            );
          }),
    );
  }

  Widget buildCuisinesList(List<Cuisine> cuisines, MediaQueryData dimensions) {
    return CuisineGridWidget(
        cuisines: cuisines, dimensions: dimensions, imgbase: imgBaseUrl);
  }

  Widget getHotelsListUsingLocation(
      List<Restaurant> hotels, LatLng userloc, MediaQueryData dimensions) {
    return hotels.length == 0
        ? Container(
            child: Center(
                child: Text(loc.unknown,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red))))
        : Container(
            child: ListView.builder(
                itemCount: hotels == null ? 0 : hotels.length,
                itemBuilder: (context, index) {
                  // if (lazyload && index == hotels.length - 1) {
                  //   return Center(child: CircularLoadingWidget());
                  // } else {
                  return HotelItemWidget(
                    hotel: hotels[index],
                    dimensions: dimensions,
                    imgbase: imgBaseUrl,
                    userloc: userloc,
                  );
                  // }
                },
                physics: NeverScrollableScrollPhysics()),
            height: (dimensions.size.height * hotels.length) / 5,
          );
  }

  TimeOfDay getTime(String s) {
    if (s == null || s.isEmpty || ":".allMatches(s).length != 2)
      return TimeOfDay(hour: 0, minute: 0);
    else {
      final a = s.trim().split(":");
      return TimeOfDay(
          hour: (int.tryParse(a.first) ?? 0),
          minute: (int.tryParse(a[1]) ?? 0));
    }
  }

  Widget getFilterWidget(List<List> lists, Size size,
      {@required ValidateSelectedItem validateSelectedItem,
      @required OnItemSearch onItemSearch}) {
    return FilterBuilder(
        lists: lists,
        size: size,
        validateSelectedItem: validateSelectedItem,
        onItemSearch: onItemSearch);
  }

  Widget getSearchedHotelsList(
      List<Restaurant> hotels,
      MediaQueryData dimensions,
      List<Cuisine> cuisines,
      List<Category> categories) {
    return hotels == null
        ? CircularLoader(
            duration: Duration(seconds: 5),
            heightFactor: 16,
            widthFactor: 16,
            color: Color(0xffa11414),
            loaderType: LoaderType.PouringHourGlass)
        : (hotels.isEmpty
            ? Column(children: [
                Container(
                    child: Text(loc.food_categories,
                        style:
                            TextStyle(color: Color(0xff181c02), fontSize: 14)),
                    padding: EdgeInsets.only(left: dimensions.size.width / 25)),
                getCategoryList(categories, dimensions),
                Container(
                    child: Text("RESTAURANTS ON OFFER",
                        style:
                            TextStyle(color: Color(0xff181c02), fontSize: 14)),
                    padding: EdgeInsets.only(left: dimensions.size.width / 25)),
              ], crossAxisAlignment: CrossAxisAlignment.start)
            : Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.all(5),
                    itemCount: hotels == null ? 0 : hotels.length,
                    itemBuilder: (context, index) {
                      Restaurant hotel = hotels[index];
                      return HotelItemWidget(
                        hotel: hotel,
                        dimensions: dimensions,
                      );
                    })));
  }

  Widget getFilteredHotelsList(
      List<Restaurant> hotels, MediaQueryData dimensions, LatLng userloc) {
    return ListView.builder(
        // padding: EdgeInsets.all(5),
        itemCount: hotels == null ? 0 : hotels.length,
        itemBuilder: (context, index) {
          Restaurant hotel = hotels[index];
          // if (index == hotels.length - 1) {
          //   return Center(child: CircularLoadingWidget());
          // } else {
          return HotelItemWidget(
            hotel: hotel,
            dimensions: dimensions,
            imgbase: imgBaseUrl,
            userloc: userloc,
          );
          // }
        });
  }

  Widget errorBuilder(BuildContext context, Object object, StackTrace trace) {
    final size = MediaQuery.of(context).size;
    return Image.asset("assets/images/loading.gif",
        matchTextDirection: true,
        height: size.height / 12.8,
        width: size.width / 6.4,
        fit: BoxFit.fill);
  }

  Widget getPageLoader(Size size) {
    return Image.asset("assets/images/loading_trend.gif",
        width: size.width, fit: BoxFit.fill, height: size.height);
  }

  Widget getPageLoader1(Size size) {
    return Image.asset("assets/images/loader1.gif",
        width: size.width, fit: BoxFit.fill, height: size.height);
  }

  bool hasOnlyZeroes(List<num> list) {
    if (list == null)
      return true;
    else if (list.isEmpty)
      return true;
    else {
      bool val = true;
      for (num i in list) {
        if (i != 0) {
          val = false;
          break;
        } else
          continue;
      }
      return val;
    }
  }

  num getSumOfNumList(List<num> list) {
    if (list == null || list.isEmpty)
      return num.tryParse("0");
    else {
      num s = 0;
      for (num i in list) s += i;
      return s;
    }
  }

  num getLargestNumber(List<num> list) {
    if (list.isEmpty)
      return -1;
    else if (list.length == 1)
      return list.first;
    else {
      num val = list.first;
      for (num i in list) if (i > val) val = i;
      return val;
    }
  }

  Widget getPlaceHolder(BuildContext context, String url) {
    final size = MediaQuery.of(context).size;
    return Image.asset("assets/images/loading.gif",
        height: size.height / 12.8, width: size.width / 6.4, fit: BoxFit.fill);
  }

  Widget getPlaceHolderNoImage(BuildContext context, String url) {
    final size = MediaQuery.of(context).size;
    return Image.asset("assets/images/noImage.png",
        height: size.height / 12.8, width: size.width / 6.4, fit: BoxFit.fill);
  }

  Widget getErrorWidgetNoImage(
      BuildContext context, String url, dynamic error) {
    final size = MediaQuery.of(context).size;
    return Image.asset("assets/images/noImage.png",
        height: size.height / 12.8, width: size.width / 6.4, fit: BoxFit.fill);
  }

  Widget getErrorWidget(BuildContext context, String url, dynamic error) {
    final size = MediaQuery.of(context).size;
    return Image.asset("assets/images/noImage.png",
        height: size.height / 12.8, width: size.width / 6.4, fit: BoxFit.fill);
  }

  Future<void> showDialogBox(String action, List<String> options,
      List<VoidCallback> actions, Size size) async {
    if (options.length == actions.length) {
      final p = await showDialog<String>(
        context: context,
        builder: (context) => CustomDialogBoxWidget(
          child: new AlertDialog(
            contentPadding: EdgeInsets.symmetric(
                horizontal: size.width / 25, vertical: size.height / 100),
            content: new Text("Are You sure to " + action + "?",
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Color(0xff200303))),
            actions: <Widget>[
              for (String i in options)
                new TextButton(
                    child: Text(
                      i,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xffa11414)),
                    ),
                    onPressed: actions[options.indexOf(i)])
            ],
          ),
        ),
      );
      print(p);
    }
  }

  List<String> getFirstAndLastName(String name) {
    List<String> ls = [];
    if (name != null && name != "") {
      ls.add(name.trim().split(' ')[0]);
      ls.add(name.trim().split(' ')[name.trim().split(' ').length - 1]);
    }
    return ls;
  }

  void navigateTo(String route,
      {dynamic arguments, FutureOr<dynamic> Function(dynamic) onGoBack}) {
    Navigator.pushNamed(context, route, arguments: arguments)
        .then(onGoBack ?? doNothing);
  }

  bool compareDates(DateTime a, DateTime b) {
    return !(a == null || b == null) &&
        a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute &&
        a.second == b.second &&
        a.millisecond == b.millisecond &&
        a.microsecond == b.microsecond;
  }

  Widget getActiveOrdersList(List<Order> orders, Size size) {
    return orders == null
        ? CircularLoader(
            duration: Duration(seconds: 5),
            heightFactor: 16,
            widthFactor: 16,
            color: Color(0xffa11414),
            loaderType: LoaderType.PouringHourGlass)
        : (orders.isEmpty
            ? Center(
                child: Text(loc.youDontHaveAnyOrder,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
            // Image.asset("assets/images/loading_trend.gif",
            //     fit: BoxFit.fill, height: size.height, width: size.width)
            : ListView.builder(
                itemBuilder: (context, int index) {
                  // if (index == orders.length - 1) {
                  //   return Center(child: CircularLoadingWidget());
                  // } else {
                  return ActiveOrderItemWidget(order: orders[index]);
                  // }
                },
                // ActiveOrderItemWidget(order: orders[index]),
                itemCount: orders.length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics()));
  }

  Widget getCardLoader(Size size, num heightDivisor, num widthDivisor) {
    return Image.asset('assets/images/loading_card.gif',
        width: size.width / widthDivisor,
        fit: BoxFit.fill,
        height: size.height / heightDivisor);
  }

  Widget getDeliveredOrdersList(List<Order> orders, Size size) {
    return orders == null
        ? getPageLoader1(size)
        : (orders.isEmpty
            ? Center(
                child: Text(loc.youDontHaveAnyOrder,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  // if (index == orders.length - 1) {
                  //   return Center(child: CircularLoadingWidget());
                  // } else {
                  return DeliveredOrderItemWidget(order: orders[index]);
                  // }
                }));
  }

  Widget getHelpPageOrdersList(List<Order> orders, Size size) {
    return orders == null
        ? getPageLoader(size)
        : (orders.isEmpty
            ? Center(
                child: Container(
                    child: Column(children: [
                      Text(loc.youDontHaveAnyOrder,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(
                        loc.forMoreDetailsPleaseChatWithOurManagers + "@",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "+0125879463",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffA11414)),
                      ),
                      OutlinedButton(
                          onPressed: () {},
                          child: Text("CALL NOW",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffA11414))),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    side:
                                        BorderSide(
                                            color: Color(0xffA11414),
                                            width: 10),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)))),
                            // minimumSize: MaterialStateProperty.all(radius),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                    ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                    padding: EdgeInsets.symmetric(
                        vertical: size.height / 2.5,
                        horizontal: size.width / 16)),
              )
            : ListView.builder(
                itemBuilder: (context, int index) =>
                    ActiveOrderItemWidget(order: orders[index]),
                itemCount: orders.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics()));
  }

  Map<String, dynamic> razorpayMap(PaymentSuccessResponse response) {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['order_id'] = response.orderId;
    map['payment_id'] = response.paymentId;
    map['signature'] = response.signature;
    return map;
  }

  Widget getOrderedFoodList(List<OrderedFood> foods, Size size) {
    return foods.isEmpty
        ? getCardLoader(size, 5, 1)
        : Container(
            child: ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, int index) => Container(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Text(
                        foods[index].food +
                            " x " +
                            foods[index].quantity.toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                  Text(
                      "₹ " +
                          ((double.tryParse(foods[index].price ?? "0.0") ??
                                      0.0) *
                                  foods[index].quantity)
                              .toString(),
                      style: TextStyle(color: Colors.black))
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                // padding: EdgeInsets.symmetric(vertical: size.height / 160)
              ),
              // physics: NeverScrollableScrollPhysics()
            ),
            // height: (foods.length * size.height) / 15
            height: MediaQuery.of(context).size.height / 3.5,
          );
  }

  Widget getCouponsList(List<Coupon> coupons, route, Cart cart) {
    return coupons == null
        ? getPageLoader(size)
        : coupons.isEmpty
            ? Center(
                child: Text("No Coupons Found",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
            : ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  // if (index == coupons.length - 1) {
                  //   return Center(child: CircularLoadingWidget());
                  // } else {
                  return CouponItemWidget(
                      coupon: coupons[index], route: route, cart: cart);
                  // }
                },
                itemCount: coupons.length);
  }

  Widget getHotelMenu(List<Food> foods, List<Menu> menu, List<int> items,
      List<double> prices, MediaQueryData dimensions, HotelController con) {
    return foods == null ||
            foods.isEmpty ||
            menu == null ||
            menu.isEmpty ||
            items.isEmpty ||
            prices.isEmpty
        ? getCardLoader(dimensions.size, 2.097152, 1)
        : Expanded(
            child: MyScrollableListTabView(dimensions: dimensions, tabs: [
            for (Menu i in menu)
              MyScrollableListTab(
                  tab: MyListTab(label: i.menu),
                  body: getFoodList(
                      foods
                          .where((element) => element.menuID == i.menuID)
                          .toList(),
                      dimensions.size,
                      con)),
          ]));
  }

  Widget getFoodList(List<Food> foods, Size size, HotelController con) {
    return foods == null
        ? getCardLoader(size, 5, 1)
        : ListView.builder(
            itemBuilder: (context, int index) => FoodItemWidget(
                  food: foods[index],
                  index: con.foods.indexOf(foods[index]),
                  imgbase: imgBaseUrl,
                ),
            itemCount: foods.length,
            shrinkWrap: true,
            // padding: EdgeInsets.only(bottom: 20.0),
            physics: NeverScrollableScrollPhysics());
  }

  double getCouponDiscount(Cart cart, Coupon coupon) {
    return coupon == null
        ? 0.0
        : (coupon.type == "percent"
            ? (cart.itemTotal *
                (double.tryParse(coupon.discount ?? "0.0") ?? 0.0) /
                100)
            : (double.tryParse(coupon.discount ?? "0.0") ?? 0.0));
  }

  double getTax(orderamount) {
    return (5 * orderamount) / 100;
  }

  String validatePhoneNumber(String phone) {
    return (phone != null && phone.length == 10 && int.tryParse(phone) != null
        ? null
        : loc.not_a_valid_phone);
  }

  double h2d(LatLng a, LatLng b) {
    double distanceInMeters = Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
    return distanceInMeters / 1000000;
  }

  String validatePassword(String password) {
    RegExp re = new RegExp(
        r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$");
    return password.isNotEmpty &&
            password.length >= 6 &&
            password.length <= 12 &&
            re.hasMatch(password)
        ? null
        : "Please Enter a Valid Password like(Foodigo@123)";
  }

  String validateEmail(String email) {
    RegExp re = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return re.hasMatch(email) && re.allMatches(email).length == 1
        ? null
        : loc.not_a_valid_email;
  }

  String validateName(String value) =>
      value.isEmpty ? loc.not_a_valid_full_name : null;

  void getConnectStatus() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // I am connected to a mobile network.
      final str = await showAlert();
      print(str);
    } else
      print(connectivityResult);
  }

  Widget showAddressPopup(BuildContext context) {
    return AddressPopupWidget();
  }

  Future<String> showAlert() async {
    return showDialog<String>(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(
          'Network Status',
          style: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        content: new Text(
          loc.verify_your_internet_connection,
          style: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: <Widget>[
          new TextButton(
            onPressed: () {
              goBack();
              getConnectStatus();
            },
            child: new Text('Ok'),
          ),
        ],
      ),
    );
  }

  bool predicate(Route<dynamic> route) {
    print(route);
    return false;
  }

  void putAddressToString(Address element) {
    print("---------------");
    print("Full Address : " +
        (element.addressLine == null ? "" : element.addressLine));
    print("Feature Name : " +
        (element.featureName == null ? "" : element.featureName));
    print("Country Name : " +
        (element.countryName == null ? "" : element.countryName));
    print(
        "Admin Area : " + (element.adminArea == null ? "" : element.adminArea));
    print("Sub Admin Area : " +
        (element.subAdminArea == null ? "" : element.subAdminArea));
    print("Locality : " + (element.locality == null ? "" : element.locality));
    print("Sub Locality : " +
        (element.subLocality == null ? "" : element.subLocality));
    print(
        "Zip Code : " + (element.postalCode == null ? "" : element.postalCode));
    print("_______________");
  }

  String putDateTimeToString(DateTime element) {
    String sep = "/";
    if (element != null) {
      int ds = (element.millisecond * 1000) + element.microsecond;
      String str = (element.year == null ? "" : element.year.toString());
      str += (sep +
          (element.month == null ? "" : element.month.toString()) +
          sep +
          (element.day == null ? "" : element.day.toString()) +
          "|" +
          (element.hour == null ? "" : element.hour.toString()) +
          ":" +
          (element.minute == null ? "" : element.minute.toString()) +
          ":" +
          (element.second == null ? "" : element.second.toString()) +
          "." +
          ds.toString());
      return str;
    } else {
      print("Year : ");
      print("Month : ");
      // print("Country Name : ");
      // print(
      //     "Admin Area : ");
      // print("Sub Admin Area : ");
      // print("Locality : ");
      return "";
    }
  }

  FutureOr<dynamic> doNothing(dynamic value) {
    print(value);
  }

  void navigateWithoutGoBack(String route, {dynamic arguments}) {
    Navigator.pushNamedAndRemoveUntil(context, route, predicate,
            arguments: arguments)
        .then(doNothing);
  }

  void popAndPush(String route, {dynamic result, dynamic arguments}) {
    Navigator.pushReplacementNamed(context, route,
            result: result, arguments: arguments)
        .then(doNothing);
  }
}
