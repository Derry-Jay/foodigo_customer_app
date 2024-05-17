import 'package:foodigo_customer_app/models/menu.dart';
import 'package:foodigo_customer_app/models/reply.dart';

class MenuBase {
  final Reply response;
  final List<Menu> menu;
  MenuBase(this.response, this.menu);
  factory MenuBase.fromMap(Map<String, dynamic> json) {
    return MenuBase(Reply.fromMap(json),
        List.from(json['data']).map((e) => Menu.fromMap(e)).toList());
  }
}
