import 'package:foodigo_customer_app/models/reply.dart';

import 'food.dart';

class FoodBase {
  final Reply response;
  final List<Food> foods;
  FoodBase(this.response, this.foods);
  factory FoodBase.fromMap(Map<String, dynamic> json) {
    return FoodBase(
        Reply.fromMap(json),
        json['data'] == null
            ? <Food>[]
            : List.from(json['data']).map((e) => Food.fromMap(e)).toList());
  }
}
