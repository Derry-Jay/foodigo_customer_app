import 'package:foodigo_customer_app/models/reply.dart';

class OtherData {
  final Reply reply;
  final data;
  OtherData(this.reply, this.data);
  factory OtherData.fromMap(Map<String, dynamic> json) {
    return OtherData(Reply.fromMap(json), json['data']);
  }
}
