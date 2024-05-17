import 'dart:math';

import 'package:flutter/material.dart';

class LinkItemWidget extends StatelessWidget {
  final String label;
  final MediaQueryData dimensions;
  final VoidCallback onTap;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  LinkItemWidget(
      {Key key,
      @required this.label,
      @required this.onTap,
      @required this.dimensions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
        child: Container(
            child: Row(
              children: [
                Image.asset("assets/images/gear.png"),
                Text(label.padRight((width * 2 / label.length).ceil(), ' '),
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Icon(Icons.arrow_forward_ios, size: 16)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            padding: EdgeInsets.symmetric(
                horizontal: width / 32, vertical: height / 50)),
        onTap: onTap);
  }
}
