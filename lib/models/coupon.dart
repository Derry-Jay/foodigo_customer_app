class Coupon {
  final int couponID, hotelID, admin, amountExpect;
  final bool enabled;
  final String discount, fpc, vpc, code, type, expiryDate;
  Coupon(
    this.couponID,
    this.hotelID,
    this.code,
    this.type,
    this.discount,
    this.fpc,
    this.vpc,
    this.expiryDate,
    this.enabled,
    this.admin,
    this.amountExpect,
  );
  Map<String, dynamic> get json {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['coupon_id'] = couponID;
    map['code'] = code;
    map['discount_type'] = type;
    map['discount'] = discount;
    map['enabled'] = enabled;
    map['restaurant_id'] = hotelID;
    map['expiry_date'] = expiryDate;
    map['admin'] = admin;
    map['discount_expected'] = amountExpect;
    return map;
  }

  factory Coupon.fromMap(Map<String, dynamic> json) {
    return Coupon(
      json['id'] ?? json['coupon_id'],
      -1, //int.parse(json['restaurant_id']),
      json['code'] == null
          ? (json['coupon_code'] == null ? "" : json['coupon_code'])
          : json['code'],
      json['discount_type'] ?? "",
      json['discount'] == null
          ? json['coupon_discount'].toString()
          : json['discount'].toString(),
      json['foodigo_percentage'].toString(),
      json['vendor_percentage'].toString(),
      json['expires_at'] ?? json['coupon_expiry_date'],
      json['enabled'],
      json['admin'],
      json['discount_expected'],
    );
  }
}
