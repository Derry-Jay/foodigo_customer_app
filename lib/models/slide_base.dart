import 'package:foodigo_customer_app/models/reply.dart';
import 'package:foodigo_customer_app/models/slide.dart';

class SlideBase {
  final Reply response;
  final List<Slide> slides;
  SlideBase(this.response, this.slides);
  factory SlideBase.fromMap(Map<String, dynamic> json) {
    return SlideBase(
        Reply.fromMap(json),
        json['data'] == null
            ? <Slide>[]
            : List.from(json['data']).map((e) => Slide.fromMap(e)).toList());
  }
}
