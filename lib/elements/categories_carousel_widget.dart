import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'circular_loader.dart';
import '../elements/category_item_widget.dart';
import '../models/category.dart';

class CategoriesCarouselWidget extends StatelessWidget {
  final List<Category> categories;
  final MediaQueryData dimensions;
  final String imgbase;
  final LatLng userloc;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  CategoriesCarouselWidget(
      {Key key, this.categories, this.dimensions, this.imgbase, this.userloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.categories.isEmpty
        ? CircularLoader(
            duration: Duration(seconds: 5),
            widthFactor: 20,
            heightFactor: 20,
            color: Color(0xffa11414),
            loaderType: LoaderType.PouringHourGlass)
        : Container(
            height: height / 6.4,
            child: ListView.builder(
                itemCount: this.categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new CategoryItemWidget(
                      dimensions: dimensions,
                      imgbase: imgbase,
                      userloc: userloc,
                      category: this.categories[index]);
                },
                padding: EdgeInsets.symmetric(
                    vertical: height / 100, horizontal: width / 40)));
  }
}
