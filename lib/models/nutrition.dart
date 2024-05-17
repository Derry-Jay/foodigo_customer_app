class Nutrition {
  final int nutritionID;
  final String nutrition, quantity;
  Nutrition(this.nutritionID, this.nutrition, this.quantity);
  factory Nutrition.fromMap(Map<String, dynamic> json) {
    return Nutrition(json['id'], json['name'], json['quantity']);
  }
}
