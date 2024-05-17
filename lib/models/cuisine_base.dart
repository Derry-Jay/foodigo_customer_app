import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:foodigo_customer_app/models/reply.dart';

class CuisineBase {
  final Reply response;
  final List<Cuisine> cuisines;
  CuisineBase(this.response, this.cuisines);
  factory CuisineBase.fromMap(Map<String, dynamic> json) {
    return CuisineBase(
        Reply.fromMap(json),
        json['data'] == null
            ? <Cuisine>[]
            : List.from(json['data']).map((e) => Cuisine.fromMap(e)).toList());
  }
}
