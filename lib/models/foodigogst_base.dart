import 'package:foodigo_customer_app/models/foodigogst.dart';
import 'package:foodigo_customer_app/models/reply.dart';

// class FodigogstBase {
//   final Reply response;
//   final List<Foodigogst> foodigogst;
//   FodigogstBase(this.response, this.foodigogst);
//   factory FodigogstBase.fromMap(Map<String, dynamic> json) {
//     return FodigogstBase(Reply.fromMap(json),
//         List.from(json['data']).map((e) => Foodigogst.fromMap(e)).toList());
//   }
// }

class FodigogstBase {
  final Reply response;
  final List<Foodigogst> foodigogst;
  FodigogstBase(this.response, this.foodigogst);
  factory FodigogstBase.fromMap(Map<String, dynamic> json) {
    print(json['data'].runtimeType);
    return FodigogstBase(
        Reply.fromMap(json),
        json['data'] != null
            ? List.from(json['data']).map((e) => Foodigogst.fromMap(e)).toList()
            : <Foodigogst>[]);
  }
}
