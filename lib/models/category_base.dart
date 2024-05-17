import 'package:foodigo_customer_app/models/category.dart';
import 'package:foodigo_customer_app/models/reply.dart';

class CategoryBase {
  final Reply response;
  final List<Category> categories;
  CategoryBase(this.response, this.categories);
  factory CategoryBase.fromMap(Map<String, dynamic> json) {
    return CategoryBase(
        Reply.fromMap(json),
        json['data'] == null
            ? <Category>[]
            : List.from(json['data']).map((e) => Category.fromMap(e)).toList());
  }
}
