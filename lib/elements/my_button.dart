import 'dart:math';

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final MediaQueryData dimensions;
  final String label;
  final FontWeight labelWeight;
  final double labelSize, widthFactor, heightFactor, elevation, radiusFactor;
  final VoidCallback onPressed;
  final int color;
  MyButton(
      {key,
      @required this.label,
      @required this.dimensions,
      @required this.labelSize,
      @required this.heightFactor,
      @required this.widthFactor,
      @required this.elevation,
      @required this.labelWeight,
      @required this.radiusFactor,
      @required this.onPressed,
      this.color: 0xffA11414})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = dimensions.size;
    // TODO: implement build
    return FittedBox(
      child: TextButton(
          child: Text(
            label,
            style: TextStyle(
                fontSize: labelSize,
                fontWeight: labelWeight,
                color: Colors.white),
          ),
          onPressed: onPressed,
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Color(color)),
              tapTargetSize: MaterialTapTargetSize.padded,
              elevation: MaterialStateProperty.all(elevation),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  side: BorderSide(color: Color(color), width: 10),
                  borderRadius: BorderRadius.all(
                      radiusFactor == null || radiusFactor == 0
                          ? Radius.zero
                          : Radius.circular(
                              sqrt(pow(size.height, 2) + pow(size.width, 2)) /
                                  radiusFactor)))),
              padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                  horizontal: size.width / widthFactor,
                  vertical: size.height / heightFactor)),
              foregroundColor: MaterialStateProperty.all(Color(0xffFFFFFF)),
              backgroundColor: MaterialStateProperty.all(Color(color)))),
    );
  }
}
