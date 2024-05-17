class Foodigogst {
  final int foodgst, servicegst, deliverychargemin, rateperkm;
  //final String menu;
  Foodigogst(
      this.foodgst, this.servicegst, this.deliverychargemin, this.rateperkm);
  factory Foodigogst.fromMap(Map<String, dynamic> json) {
    return Foodigogst(json['food_gst'], json['service_gst'],
        json['delivery_charge_min'], json['rate_per_km']);
  }
}
