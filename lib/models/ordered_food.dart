class OrderedFood {
  String food, price;
  int foodID, quantity;
  Map<String, dynamic> get json {
    var map = new Map<String, dynamic>();
    map["food_id"] = foodID;
    map["name"] = food;
    map["price"] = price;
    map["quantity"] = quantity;
    return map;
  }

  OrderedFood();
  OrderedFood.fromMap(Map<String, dynamic> json) {
    try {
      foodID = json["food_id"];
      food = json["name"];
      price = json["price"].toString();
      quantity = json["quantity"];
    } catch (e) {
      foodID = -1;
      food = "";
      price = "";
      print(e);
    }
  }
}
