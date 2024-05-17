import 'package:foodigo_customer_app/models/reply.dart';
import 'package:foodigo_customer_app/models/restaurant.dart';

class RestaurantBase {
  final Reply response;
  final List<Restaurant> restaurants;
  RestaurantBase(this.response, this.restaurants);
  factory RestaurantBase.fromMap(Map<String, dynamic> json) {
    print(json['data'].runtimeType);
    return RestaurantBase(
        Reply.fromMap(json),
        json['data'] != null
            ? List.from(json['data']).map((e) => Restaurant.fromMap(e)).toList()
            : <Restaurant>[]);
  }
}
