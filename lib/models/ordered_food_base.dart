import 'package:foodigo_customer_app/models/ordered_food.dart';
import 'package:foodigo_customer_app/models/reply.dart';

class OrderedFoodBase {
  final Reply response;
  final List<OrderedFood> foods;
  OrderedFoodBase(this.response, this.foods);
  factory OrderedFoodBase.fromMap(Map<String, dynamic> json) {
    return OrderedFoodBase(
        Reply.fromMap(json),
        json['data'] == null
            ? <OrderedFood>[]
            : List.from(json['data'])
                .map((e) => OrderedFood.fromMap(e))
                .toList());
  }
}
