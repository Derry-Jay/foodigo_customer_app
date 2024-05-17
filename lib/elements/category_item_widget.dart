import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';
import 'package:foodigo_customer_app/models/category.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CategoryItemWidget extends StatelessWidget {
  final MediaQueryData dimensions;
  final Category category;
  final String imgbase;
  final LatLng userloc;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  CategoryItemWidget(
      {Key key,
      @required this.dimensions,
      @required this.category,
      this.imgbase,
      this.userloc})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Helper hp = new Helper.of(context);
    return InkWell(
        child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                  radius: radius / 28.8230376151711744,
                  backgroundImage: category.s3url == null ||
                          category.s3url.isEmpty ||
                          (imgbase == null && hp.imgBaseUrl == null)
                      ? AssetImage("assets/images/noImage.png")
                      : (NetworkImage(
                          (imgbase ?? hp.imgBaseUrl) + category.s3url))),
              FittedBox(
                child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: height / 125,
                        horizontal:
                            width / (4 * this.category.category.length)),
                    child: Text(this.category.category,
                        // softWrap: false,
                        // maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 12),
                        textAlign: TextAlign.center)),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center),
        onTap: () {
          Navigator.pushNamed(context, '/catHotels', arguments: category);
        });
  }
}
