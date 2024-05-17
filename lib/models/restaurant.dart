import 'package:foodigo_customer_app/models/coupon.dart';
import 'package:foodigo_customer_app/models/medium.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final gc = GlobalConfiguration();

class Restaurant {
  final int restID, charge, minOrder, pinCode, p42;
  final String restName,
      phone,
      restDesc,
      imageLink,
      innerimageLink,
      hotelBg,
      foodType,
      gstNo,
      gst,
      fsSaiCode,
      deliveryType,
      baseDeliveryCharge,
      baseDeliveryDistance,
      extraDeliveryCharge,
      extraDeliveryDistance,
      deliveryChargeType,
      category,
      location,
      deliveryTime,
      tax,
      adminCommission,
      rating,
      sthreeurl,
      gstNum;
  final Coupon coupon;
  final LatLng coordinates;
  final bool availableForDelivery, bestSafety, fssai;
  final List<Medium> media;
  Restaurant(
      this.restID,
      this.restName,
      this.restDesc,
      this.imageLink,
      this.innerimageLink,
      this.charge,
      this.minOrder,
      this.category,
      this.foodType,
      this.gst,
      this.gstNo,
      this.location,
      this.pinCode,
      this.rating,
      this.deliveryTime,
      this.p42,
      this.fsSaiCode,
      this.coordinates,
      this.availableForDelivery,
      this.deliveryType,
      this.deliveryChargeType,
      this.baseDeliveryCharge,
      this.baseDeliveryDistance,
      this.extraDeliveryCharge,
      this.extraDeliveryDistance,
      this.tax,
      this.adminCommission,
      this.coupon,
      this.media,
      this.sthreeurl,
      this.phone,
      this.hotelBg,
      this.bestSafety,
      this.fssai,
      this.gstNum);
  factory Restaurant.fromMap(Map<String, dynamic> json) {
    return Restaurant(
      json['id'] ?? -1,
      json['name'] == null ? "" : json['name'],
      json['description'] == null ? "" : json['description'],
      gc.getValue('base_url') +
          (json["upload_image"] ?? "") +
          (json["id"] == null ? "" : json["id"].toString()) +
          "/" +
          (json['image'] == null ? "" : json['image']),
      gc.getValue('base_url') +
          (json["upload_image"] ?? "") +
          (json["id"] == null ? "" : json["id"].toString()) +
          "/" +
          (json['image_inner'] == null ? "" : json['image_inner']),
      json['charge'] == null ? -1 : json['charge'],
      json['min_order_price'] == null ? -1 : json['min_order_price'],
      json['categories'] == null ? "" : json['categories'],
      json['food_type'] == null ? "" : json['food_type'],
      json['gst'] == null ? "" : json['gst'],
      json['gst_number'] == null ? "" : json['gst_number'],
      json['location'] == null ? "" : json['location'],
      json['pincode'] == null ? -1 : json['pincode'],
      json['rating'] == null ? "" : json['rating'].toString(),
      json['approx_delivery_time'] == null ? "" : json['approx_delivery_time'],
      json['approx_price_for_two'] == null ? -1 : json['approx_price_for_two'],
      json['fssai_code'] == null ? "" : json['fssai_code'],
      LatLng(
          json['latitude'] == null
              ? 0.0
              : (json['latitude'] is String
                  ? (double.tryParse(json['latitude']) ?? 0.0)
                  : (json['latitude'] is int
                      ? json['latitude'].toDouble()
                      : json['latitude'])),
          json['longitude'] == null
              ? 0.0
              : (json['longitude'] is String
                  ? (double.tryParse(json['longitude']) ?? 0.0)
                  : (json['longitude'] is int
                      ? json['longitude'].toDouble()
                      : json['longitude']))),
      json['available_for_delivery'] is bool
          ? json['available_for_delivery']
          : (json['available_for_delivery'] == 1),
      json['delivery_type'] == null ? "" : json['delivery_type'],
      json['delivery_charge_type'] == null ? "" : json['delivery_charge_type'],
      json['base_delivery_charge'] == null
          ? ""
          : json['base_delivery_charge'].toString(),
      json['base_delivery_distance'] == null
          ? ""
          : json['base_delivery_distance'].toString(),
      json['extra_delivery_charge'] == null
          ? ""
          : json['extra_delivery_charge'].toString(),
      json['extra_delivery_distance'] == null
          ? ""
          : json['extra_delivery_distance'].toString(),
      json['default_tax'] == null ? "" : json['default_tax'].toString(),
      json['admin_commission'] == null
          ? ""
          : json['admin_commission'].toString(),
      Coupon.fromMap(json),
      json['media'] == null
          ? <Medium>[]
          : List.from(json['media']).map((e) => Medium.fromMap(e)).toList(),
      json['s3url'] == null ? "" : json['s3url'],
      json['mobile'] == null ? "" : json['mobile'],
      json['image_inner'] == null ? "" : json['image_inner'],
      // json['best_safety'] is bool
      //     ? json['best_safety']
      //     : (json['best_safety'] == 1),
      json['fssai'] is bool ? json['fssai'] : (json['fssai'] == 1),
      json['fssai'] is bool ? json['fssai'] : (json['fssai'] == 1),
      json['gst_number'] == null ? "" : json['gst_number'],
    );
  }

  double get deliveryFee =>
      ((double.tryParse(this.baseDeliveryCharge ?? "0.0") ?? 0.0) *
          (double.tryParse(this.baseDeliveryDistance ?? "0.0") ?? 0.0));

  double get totalTax => ((double.tryParse(this.tax ?? "0.0") ?? 0.0) +
      (double.tryParse(this.adminCommission ?? "0.0") ?? 0.0));
  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Restaurant && this.restID == other.restID;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.restID.hashCode;
}
