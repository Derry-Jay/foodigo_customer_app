import 'package:foodigo_customer_app/models/custom_field.dart';

import 'medium.dart';

class Customer {
  final int customerID;
  final String customerName, customerEmail, apiToken, deviceToken, phone;
  final CustomField bio;
  final List<Medium> images;
  Customer(this.customerID, this.customerName, this.customerEmail, this.phone,
      this.deviceToken, this.apiToken, this.images, this.bio);
  Map<String, dynamic> get json {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['name'] = customerName;
    map['contact'] = phone;
    map['email'] = customerEmail;
    return map;
  }

  factory Customer.fromMap(Map<String, dynamic> json) {
    return Customer(
        json['id'],
        json['name'],
        json['email'],
        json['mobileno'] ?? (json['alternative_mobileno'] ?? ""),
        json['device_token'],
        json['api_token'],
        json['media'] == null
            ? <Medium>[]
            : List<Map<String, dynamic>>.from(json['media'])
                .map((e) => Medium.fromMap(e))
                .toList(),
        CustomField.fromMap(json['custom_fields']['bio']));
  }
}
