import 'package:foodigo_customer_app/models/address.dart';
import 'package:foodigo_customer_app/models/reply.dart';

class AddressBase {
  final Reply response;
  final List<WhereAbouts> addresses;
  AddressBase(this.response, this.addresses);
  factory AddressBase.fromMap(Map<String, dynamic> json) {
    return AddressBase(Reply.fromMap(json),
        List.from(json['data']).map((e) => WhereAbouts.fromMap(e)).toList());
  }
}
