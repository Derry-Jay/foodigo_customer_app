import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/restaurant.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelItemWidget extends StatelessWidget {
  final Restaurant hotel;
  final String imgbase;
  final LatLng userloc;
  final MediaQueryData dimensions;
  Size get size => dimensions.size;
  double get width => size.width;
  double get height => size.height;
  double get pixelRatio => dimensions.devicePixelRatio;
  double get textScaleFactor => dimensions.textScaleFactor;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  HotelItemWidget(
      {Key key,
      @required this.hotel,
      @required this.dimensions,
      this.imgbase,
      this.userloc})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(builder: (context, constraints) {
      // print(hotel.coupon.code.isNotEmpty && hotel.coupon.couponID > 0);
      // print(hotel.coupon.code);
      // print(constraints.biggest.width);
      return Opacity(
        opacity: hotel.availableForDelivery ? 1 : 0.3,
        child: Card(
            margin: EdgeInsets.symmetric(
                horizontal: width / 25, vertical: height / 64),
            color: Color(0xffFBFBFB),
            // color: Color(0xffBAD600),
            elevation: 0,
            child: InkWell(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: height / 6.5536,
                      width: width / 3.6028797018963968,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(radius / 160)),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: hotel.sthreeurl == null ||
                                    hotel.sthreeurl.isEmpty ||
                                    imgbase == null
                                // !(hotel.imageLink.endsWith(".jpg") ||
                                //     hotel.imageLink.endsWith(".jpeg") ||
                                //     hotel.imageLink.endsWith(".png"))
                                ? AssetImage("assets/images/noImage.png")
                                : NetworkImageWithRetry(
                                    imgbase + hotel.sthreeurl)),
                        // boxShadow: [
                        //   BoxShadow(
                        //       color: Theme.of(context)
                        //           .focusColor
                        //           .withOpacity(0.2),
                        //       offset: Offset(0, 2),
                        //       blurRadius: 7.0)
                        // ]
                      )),
                  // ClipRRect(
                  //     child: CachedNetworkImage(
                  //         fit: BoxFit.fill,
                  //         height: height / 6.5536,
                  //         width: width / 3.6028797018963968,
                  //         imageUrl: hotel.imageLink,
                  //         placeholder: hp.getPlaceHolder,
                  //         errorWidget: hp.getErrorWidget),
                  //     borderRadius: BorderRadius.horizontal(
                  //         left: Radius.circular(radius / 160))),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(radius / 160))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            width: width / 3,
                                            child: Text(
                                              hotel.restName,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: height / 160)),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            hotel.fssai
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.pink[900],
                                                        borderRadius: BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10))),
                                                    child: Text(
                                                        "Prime Safety"
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    padding:
                                                        const EdgeInsets.all(3))
                                                : Container(),
                                            Container(
                                              height: height / 40,
                                              width: width / 10,
                                              color: Colors.transparent,
                                            ),
                                            // SizedBox(
                                            //   height: 3.0,
                                            // ),
                                            // hotel.fssai
                                            //     ? Image.asset(
                                            //         "assets/images/fssai.png",
                                            //         fit: BoxFit.fill,
                                            //         height: height / 40,
                                            //         width: width / 10)
                                            //     : Container(),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                        child: Text(
                                            hotel.restDesc == ""
                                                ? "Description Unavailable"
                                                : hotel.restDesc,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10)),
                                        padding: EdgeInsets.only(
                                            bottom: height / 100)),
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Text(
                                              hotel.location == ""
                                                  ? "Location Unavailable"
                                                  : hotel.location,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10)),
                                          VerticalDivider(
                                            thickness: 1,
                                            color: Colors.black,
                                            indent: 0,
                                            endIndent: 0,
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Text(
                                                  Helper.timecheck(
                                                          hotel.deliveryTime,
                                                          userloc,
                                                          hotel.coordinates)
                                                      .toString(),
                                                  // Helper.timeDiff(
                                                  //     hotel.deliveryTime),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600)))
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: height / 128,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                              children: [
                                                Image.asset(
                                                    "assets/images/star.png",
                                                    fit: BoxFit.fill,
                                                    height: height / 80,
                                                    width: width / 40),
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        left: width / 100),
                                                    // height: height / 4,
                                                    // decoration: BoxDecoration(
                                                    //     color: Color(0x996dbbe8),
                                                    //     borderRadius: BorderRadius.vertical(
                                                    //         bottom:
                                                    //         Radius.circular(size / 50))),
                                                    // color: Colors.pink[900],
                                                    child: Text(
                                                        hotel.rating == ""
                                                            ? "0.0"
                                                            : hotel.rating +
                                                                ".0",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                            fontSize: 12)))
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly),
                                          padding: EdgeInsets.symmetric(
                                              vertical: height / 400,
                                              horizontal: width / 100),
                                          decoration: BoxDecoration(
                                              color: hotel.availableForDelivery
                                                  ? Colors.pink[900]
                                                  : Colors.grey,
                                              border: Border.all(
                                                color:
                                                    hotel.availableForDelivery
                                                        ? Colors.pink[900]
                                                        : Colors.grey,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      radius / 160))),
                                        ),
                                        Container(
                                            child: Text(
                                                "Approx cost for two ₹" +
                                                    (hotel.p42 == -1
                                                        ? ""
                                                        : hotel.p42.toString()),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xff1D1707),
                                                    fontSize: 10)),
                                            padding: EdgeInsets.only(
                                              right: width / 50,
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.only(
                                    left: width /
                                        (hotel.coupon.code.isNotEmpty
                                            ? (2 *
                                                pixelRatio *
                                                hotel.coupon.code.length)
                                            : 20))),
                            Visibility(
                                child: SizedBox(height: height / 32),
                                visible: !(hotel.coupon.code.isNotEmpty &&
                                    hotel.coupon.couponID > 0)),
                            Visibility(
                                child: Container(
                                    width: constraints.maxWidth,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight:
                                                Radius.circular(radius / 160)),
                                        color: Color(0xffFCEAEA)),
                                    margin: EdgeInsets.only(top: height / 125),
                                    padding: EdgeInsets.only(
                                        left: width /
                                            (1.8014398509481984 *
                                                pixelRatio *
                                                (hotel.coupon.code.isEmpty
                                                    ? 10
                                                    : hotel
                                                        .coupon.code.length)),
                                        // right: (width * 1.40737488355328) /
                                        //     (pixelRatio *
                                        //         hotel.coupon.code.length),
                                        top: height / 160,
                                        bottom: height / 160),
                                    child: Text(
                                        "Use " +
                                            (hotel.coupon.code.isEmpty
                                                ? ""
                                                : hotel.coupon.code
                                                    .toUpperCase()) +
                                            " for flat " +
                                            hotel.coupon.discount +
                                            " " +
                                            hotel.coupon.type +
                                            " Discount",
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: hotel.coupon.code.isEmpty
                                                ? 10.99511627776
                                                : (hotel.coupon.code.length > 10
                                                    ? 10
                                                    : (hotel.coupon.code.length <=
                                                                10 &&
                                                            hotel.coupon.code.length > 5
                                                        ? 10.48576
                                                        : 10.73741824))))),
                                visible: hotel.coupon.code.isNotEmpty && hotel.coupon.couponID > 0)
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly))
                ],
              ),
              onTap: () async {
                if (hotel.availableForDelivery) {
                  final p = await Navigator.of(context).pushNamed(
                      "/hotelDetails",
                      arguments: RouteArgument(
                          id: hotel.restID.toString(),
                          heroTag: hotel.restName,
                          param: hotel));
                }
                // print(imgbase + hotel.sthreeurl);
              },
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(radius / 160)))),
      );
    });
  }
}
