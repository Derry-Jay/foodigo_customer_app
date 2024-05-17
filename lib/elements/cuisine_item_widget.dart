import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image/network.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';

class CuisineItemWidget extends StatelessWidget {
  final Cuisine cuisine;
  final MediaQueryData dimensions;
  final String imgbase;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  CuisineItemWidget(
      {Key key,
      @required this.cuisine,
      @required this.dimensions,
      this.imgbase})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final hp = Helper.of(context);
    return InkWell(
      onTap: () async {
        final p = await Navigator.of(context)
            .pushNamed('/cuisineHotels', arguments: cuisine);
        print(p);
        // print(imgbase + cuisine.s3url);
      },
      child: Column(children: [
        Container(
            height: height / 8.796093022208,
            width: width / 4,
            decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: cuisine.s3url == null ||
                          cuisine.s3url == "" ||
                          imgbase == null
                      // !(cuisine.imageUrl.endsWith(".jpg") ||
                      //     cuisine.imageUrl.endsWith(".jpeg") ||
                      //     cuisine.imageUrl.endsWith(".png"))
                      ? AssetImage("assets/images/noImage.png")
                      : NetworkImageWithRetry(imgbase + cuisine.s3url),
                ),
                borderRadius: BorderRadius.all(Radius.circular(radius / 160)))),
        // ClipRRect(
        //     child: CachedNetworkImage(
        //         width: width / 4,
        //         height: height / 8.796093022208,
        //         fit: BoxFit.fill,
        //         imageUrl: cuisine.imageUrl,
        //         placeholder: hp.getPlaceHolder,
        //         errorWidget: hp.getErrorWidget),
        //     borderRadius: BorderRadius.all(Radius.circular(radius / 128))),
        FittedBox(
            child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: width / 20),
                child: Text(cuisine.cuisineName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.52921504606846976)),
                margin: EdgeInsets.only(top: 2.5, bottom: 0))),
      ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
    );
  }
}
