import 'package:foodigo_customer_app/models/reply.dart';
import 'package:foodigo_customer_app/models/tag.dart';

class TagBase {
  final Reply response;
  final List<Tag> tags;
  TagBase(this.response, this.tags);
  factory TagBase.fromMap(Map<String, dynamic> json) {
    return TagBase(
        Reply.fromMap(json),
        json['data'] == null
            ? <Tag>[]
            : List.from(json['data']).map((e) => Tag.fromMap(e)).toList());
  }
}
