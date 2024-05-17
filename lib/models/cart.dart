import 'package:foodigo_customer_app/models/ordered_food.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cart {
  int hotelID, customerID, addressID, statusID;
  List<OrderedFood> foods;
  LatLng customerLocation;
  String tax, deliveryFee;
  int get itemCount => foods == null ? 0 : foods.length;
  int get cartCount {
    int c = 0;
    if (foods == null || foods.isEmpty)
      return 0;
    else {
      for (OrderedFood i in this.foods) c += i.quantity;
      return c;
    }
  }

  double get itemTotal {
    double p = 0.0;
    if (foods != null && foods.isNotEmpty)
      for (OrderedFood i in this.foods)
        p += (i.quantity.toDouble() *
            (double.tryParse(i.price ?? "0.0") ?? 0.0));

    return p;
  }

  double get gst {
    double p = 0.0;
    if (foods != null && foods.isNotEmpty)
      for (OrderedFood i in this.foods)
        p += (i.quantity.toDouble() *
            (double.tryParse(i.price ?? "0.0") ?? 0.0));
    return (5 * p) / 100;
  }

  double get cartValue {
    double p = itemTotal;
    p += ((double.tryParse(this.deliveryFee ?? "0.0") ?? 0.0) + gst);
    return p;
  }

  double get cartValuewithoutGST {
    double p = itemTotal;
    p += ((double.tryParse(this.deliveryFee ?? "0.0") ?? 0.0));
    return p;
  }

  List<Map<String, dynamic>> get foodsMapList {
    var mapList = <Map<String, dynamic>>[];
    if (this.foods != null) if (this.foods.isNotEmpty)
      for (OrderedFood i in this.foods) mapList.add(i.json);
    return mapList;
  }

  Map<String, dynamic> get json {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["user_id"] = customerID ?? -1;
    map["restaurant_id"] = hotelID ?? -1;
    map["delivery_address_id"] = addressID ?? -1;
    map["order_status_id"] = statusID ?? -1;
    map["tax"] = tax ?? "";
    map["delivery_fee"] = deliveryFee ?? "";
    map["customer_lat"] =
        customerLocation == null ? 0.0 : (customerLocation.latitude ?? 0.0);
    map["customer_lang"] =
        customerLocation == null ? 0.0 : (customerLocation.longitude ?? 0.0);
    map["foods"] = foodsMapList;
    return map;
  }

  Cart();
  Cart.fromMap(Map<String, dynamic> json) {
    try {
      hotelID = json['restaurant_id'];
      customerID = json['user_id'];
      addressID = json['delivery_address_id'];
      statusID = json['order_status_id'];
      tax = json['tax'];
      deliveryFee = json['delivery_fee'];
      customerLocation =
          LatLng(json['customer_lat'] ?? 0.0, json['customer_lang'] ?? 0.0);
      foods = json['foods'] == null
          ? <OrderedFood>[]
          : List.from(json['foods'])
              .map((e) => OrderedFood.fromMap(e))
              .toList(growable: true);
    } catch (e) {
      hotelID = -1;
      customerID = -1;
      addressID = -1;
      statusID = -1;
      tax = "";
      deliveryFee = "";
      customerLocation = LatLng(0.0, 0.0);
      foods = <OrderedFood>[];
      print(e);
    }
  }

  void incrementProductCount(int index) {
    this.foods[index].quantity += 1;
  }

  void decrementProductCount(int index, List<int> indices) {
    if (this.foods[index].quantity == 1) {
      final p = indices.remove(index);
      final q = this.foods.remove(this.foods[index]);
      if (p && q) print(indices);
    } else
      this.foods[index].quantity -= 1;
  }

  double getFoodPrice(int index) {
    final food = this.foods[index];
    return (food.quantity.toDouble() *
        (double.tryParse(food.price ?? "0.0") ?? 0.0));
  }
}
