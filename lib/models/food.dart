import 'package:foodigo_customer_app/models/medium.dart';
// import 'package:foodigo_customer_app/models/review.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/restaurant.dart';
import 'coupon.dart';
// import 'category.dart';
// import 'extra.dart';
// import 'extra_group.dart';
// import 'nutrition.dart';

final gc = GlobalConfiguration();

class Food {
  final int foodID, tagID, packageItemsCount, menuID, categoryID;
  final String foodName,
      price,
      discountPrice,
      description,
      ingredients,
      weight,
      imageLink,
      unit,
      s3url;
  final bool
      //featured,
      deliverable;
  final Restaurant hotel;
  final String fromtime, totime, fromtimeone, totimeone, fromtimetwo, totimetwo;
  // final Category category;
  // final List<Extra> extras;
  // final List<ExtraGroup> extraGroups;
  // final List<Review> foodReviews;
  // final List<Nutrition> nutritionContent;
  // final List<Medium> media;
  Food(
      this.foodID,
      this.menuID,
      this.foodName,
      this.price,
      this.discountPrice,
      this.description,
      this.ingredients,
      this.weight,
      this.imageLink,
      this.hotel,
      this.categoryID,
      // this.extras,
      // this.extraGroups,
      // this.foodReviews,
      // this.nutritionContent,
      this.unit,
      this.deliverable,
      //this.featured,
      this.packageItemsCount,
      this.tagID,
      // , this.media
      this.fromtime,
      this.totime,
      this.fromtimeone,
      this.totimeone,
      this.fromtimetwo,
      this.totimetwo,
      this.s3url);
  factory Food.fromMap(Map<String, dynamic> json) {
    return Food(
      json['id'] ?? -1,
      json['menu_id'] ?? -1,
      json['name'] ?? "",
      json['price'] == null ? "" : json['price'].toString(),
      json['discount_price'] == null ? "" : json['discount_price'].toString(),
      json['description'] ?? "",
      json['ingredients'] ?? "",
      json['weight'] == null ? "" : json['weight'].toString(),
      gc.getValue('base_url') +
          (json["upload_image"] ?? "") +
          (json['image'] == null ? "" : json['image']),
      json['restaurant'] == null
          ? Restaurant(
              -1,
              "",
              "",
              "",
              "",
              -1,
              -1,
              "",
              "",
              "",
              "",
              "",
              -1,
              "",
              "",
              -1,
              "",
              LatLng(0.0, 0.0),
              false,
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              Coupon(-1, -1, "", "", "", "", "", "", false, -1, -1),
              <Medium>[],
              "",
              "",
              "",
              false,
              false,
              "")
          : Restaurant.fromMap(json['restaurant']),
      json['category_id'] ?? -1,
      // json['extras'] == null
      //     ? <Extra>[]
      //     : List.from(json['extras']).map((e) => Extra.fromMap(e)).toList(),
      // json['extra_groups'] == null
      //     ? <ExtraGroup>[]
      //     : List.from(json['extra_groups'])
      //         .map((e) => ExtraGroup.fromMap(e))
      //         .toList(),
      // json['food_reviews'] == null
      //     ? <Review>[]
      //     : List.from(json['food_reviews'])
      //         .map((e) => Review.fromMap(e))
      //         .toList(),
      // json['nutrition'] == null
      //     ? <Nutrition>[]
      //     : List.from(json['nutrition'])
      //         .map((e) => Nutrition.fromMap(e))
      //         .toList(),
      json['unit'] ?? "",
      json['deliverable'] ?? false,
      //json['featured'] ?? false,
      json['package_items_count'] == null ? 0 : json['package_items_count'],
      json['tag_id'] ?? -1,
      json['from_time'] == null ? "00:00:00" : json['from_time'],
      json['to_time'] == null ? "00:00:00" : json['to_time'],
      json['from_time_one'] == null ? "00:00:00" : json['from_time_one'],
      json['to_time_one'] == null ? "00:00:00" : json['to_time_one'],
      json['from_time_sec'] == null ? "00:00:00" : json['from_time_sec'],
      json['to_time_sec'] == null ? "00:00:00" : json['to_time_sec'],
      // , json['media'] == null
      //     ? <Medium>[]
      //     : List.from(json['media']).map((e) => Medium.fromMap(e)).toList()
      json['s3url'] ?? "",
    );
  }

  Map<String, dynamic> get json {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['food_id'] = foodID;
    map['food_name'] = foodName;
    map['price'] = price;
    map['discount'] = discountPrice;
    map['image'] = imageLink;
    map['tag_id'] = tagID;
    return map;
  }

  bool isIn(List<Food> foods) {
    bool flag = false;
    if (foods.isEmpty)
      flag = foods.isNotEmpty;
    else if (foods.length == 1) if (foods.first == this)
      flag = true;
    else {
      for (Food food in foods)
        if (food == this) {
          flag = true;
          break;
        } else
          continue;
    }
    return flag;
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Food && this.foodID == other.foodID;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.foodID.hashCode;
}
