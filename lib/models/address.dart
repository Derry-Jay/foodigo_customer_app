import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WhereAbouts extends Address {
  final int addressID;
  final String fullAddress, title;
  final LatLng location;
  final bool isDefault;
  WhereAbouts(this.addressID, this.title, this.fullAddress, this.location,
      this.isDefault);

  Map<String, dynamic> get json {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['id'] = addressID;
    map['description'] = title;
    map['address'] = fullAddress ?? addressLine;
    map['latitude'] = location.latitude ?? coordinates.latitude;
    map['longitude'] = location.longitude ?? coordinates.longitude;
    map['is_default'] = isDefault;
    map['pinCode'] = postalCode;
    map['countryCode'] = countryCode;
    map['country'] = countryName;
    return map;
  }

  factory WhereAbouts.fromMap(Map<String, dynamic> json) {
    return WhereAbouts(
        json['id'],
        json['description'],
        json['address'],
        LatLng(
            json['latitude'] == null
                ? 0.0
                : (json['latitude'] is double
                    ? json['latitude']
                    : (json['latitude'] is int
                        ? json['latitude'].toDouble()
                        : (double.tryParse(json['latitude'] ?? "0.0") ?? 0.0))),
            json['longitude'] == null
                ? 0.0
                : (json['longitude'] is double
                    ? json['longitude']
                    : (json['longitude'] is int
                        ? json['longitude'].toDouble()
                        : (double.tryParse(json['longitude'] ?? "0.0") ??
                            0.0)))),
        json['is_default'] ?? false);
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is WhereAbouts && this.addressID == other.addressID;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.addressID.hashCode;
}
