import 'medium.dart';

class Extra {
  final int extraID;
  final String name, price, description;
  final List<Medium> images;
  final bool checked;
  Extra(this.extraID, this.name, this.description, this.price, this.images,
      this.checked);
  factory Extra.fromMap(Map<String, dynamic> json) {
    return Extra(
        json['id'],
        json['name'],
        json['description'],
        json['price'],
        json['media'] == null
            ? <Medium>[]
            : List.from(json['media']).map((e) => Medium.fromMap(e)).toList(),
        false);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = extraID;
    map["name"] = name;
    map["price"] = price;
    map["description"] = description;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other is Extra && other.extraID == this.extraID;
  }

  @override
  int get hashCode => this.extraID.hashCode;
}
