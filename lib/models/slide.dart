import 'package:foodigo_customer_app/models/medium.dart';

class Slide {
  final int sliderID, slidePosition;
  final String text,
      button,
      textPosition,
      textColor,
      buttonColor,
      bgColor,
      indicatorColor,
      imageFit,
      s3url;
  final List<Medium> media;
  Slide(
      this.sliderID,
      this.slidePosition,
      this.text,
      this.button,
      this.textPosition,
      this.textColor,
      this.buttonColor,
      this.bgColor,
      this.indicatorColor,
      this.imageFit,
      this.media,
      this.s3url);
  factory Slide.fromMap(Map<String, dynamic> json) {
    return Slide(
      json['id'],
      json['order'],
      json['text'],
      json['button'],
      json['text_position'],
      json['text_color'],
      json['button_color'],
      json['background_color'],
      json['indicator_color'],
      json['image_fit'],
      json['media'] == null
          ? <Medium>[]
          : List.from(json['media']).map((e) => Medium.fromMap(e)).toList(),
      json['s3url'],
    );
  }
}
