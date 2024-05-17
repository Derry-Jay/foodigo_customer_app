import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/models/slide.dart';

import '../helpers/helper.dart';

class BannerItemWidget extends StatelessWidget {
  final Slide slide;
  final String imgBase;
  final MediaQueryData dimensions;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  BannerItemWidget(
      {Key key,
      @required this.slide,
      @required this.dimensions,
      @required this.imgBase})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        print(imgBase + slide.s3url);
      },
      child: Container(
        alignment: Helper.getAlignmentDirectional(slide.textPosition),
        // width: dimensions.size.width,
        height: height / 20,
        decoration: BoxDecoration(
            color: Colors.black12,
            image: DecorationImage(
                fit: Helper.getBoxFit('fill'),
                image: slide.s3url == null || slide.s3url.isEmpty
                    ? AssetImage("assets/images/loading.gif")
                    : (imgBase == null
                        ? AssetImage("assets/images/noImage.png")
                        : NetworkImage(imgBase +
                            slide.s3url)) //NetworkImage(slide.media.first.url)
                )),
        margin: EdgeInsets.only(bottom: dimensions.size.height / 50),
        //margin: EdgeInsets.symmetric(vertical: dimensions.size.height / 50),
        // child: Text(slide.text,
        //     style: TextStyle(
        //         color: hp.getColorFromHex(slide.textColor), fontSize: 20))
      ),
    );
  }
}
