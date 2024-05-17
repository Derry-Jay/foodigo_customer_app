import 'package:foodigo_customer_app/models/restaurant.dart';
import 'package:global_configuration/global_configuration.dart';

final gc = GlobalConfiguration();

class Cuisine {
  final int cuisineID;
  final String cuisineName, description, imageUrl, s3url;
  final List<Restaurant> hotels;
  Cuisine(this.cuisineID, this.cuisineName, this.description, this.hotels,
      this.imageUrl, this.s3url);
  factory Cuisine.fromMap(Map<String, dynamic> json) {
    return Cuisine(
      json['id'] == null ? -1 : json['id'],
      json['name'] ?? "",
      json['description'] ?? "",
      json['restaurants'] == null
          ? <Restaurant>[]
          : List.from(json['restaurants'])
              .map((e) => Restaurant.fromMap(e))
              .toList(),
      gc.getValue('storage_base_url') +
          (json['path'] == null ? "" : json['path'].toString()) +
          "/" +
          (json['file_name'] ?? ""),
      json['s3url'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = cuisineID;
    map['name'] = cuisineName;
    map['description'] = description;
    return map;
  }

  @override
  bool operator ==(dynamic other) =>
      other is Cuisine && other.cuisineID == this.cuisineID;

  @override
  int get hashCode => super.hashCode;
}
