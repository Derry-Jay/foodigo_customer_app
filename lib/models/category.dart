import 'medium.dart';

class Category {
  final int categoryID;
  final String category, description, s3url;
  final List<Medium> images;
  Category(this.categoryID, this.category, this.description, this.s3url,
      this.images);
  factory Category.fromMap(Map<String, dynamic> json) {
    return Category(
        json['id'] ?? -1,
        json['name'] ?? "",
        json['description'] ?? "",
        json['s3url'] ?? "",
        json['media'] == null
            ? <Medium>[]
            : List.from(json['media']).map((e) => Medium.fromMap(e)).toList());
  }
}
