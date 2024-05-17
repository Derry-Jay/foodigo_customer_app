import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';

import 'cuisine_item_widget.dart';

class CuisineGridWidget extends StatelessWidget {
  final List<Cuisine> cuisines;
  final MediaQueryData dimensions;
  final String imgbase;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  CuisineGridWidget(
      {Key key,
      @required this.cuisines,
      @required this.dimensions,
      @required this.imgbase})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // Helper hp = new Helper.of(context);
    return GridView.custom(
        physics: NeverScrollableScrollPhysics(),
        padding:
            EdgeInsets.symmetric(vertical: height / 80, horizontal: width / 32),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: height / 64,
            crossAxisSpacing: width / 40,
            crossAxisCount: height < (2 * width)
                ? (height * 2 / width).ceil()
                : (height * 2 / width).floor(),
            childAspectRatio: width * 1.31072 / height),
        childrenDelegate: SliverChildBuilderDelegate(getCuisineItem,
            childCount: cuisines.length));
  }

  Widget getCuisineItem(BuildContext context, int index) {
    return CuisineItemWidget(
      cuisine: cuisines[index],
      dimensions: dimensions,
      imgbase: imgbase,
    );
  }
}
