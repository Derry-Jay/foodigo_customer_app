import 'package:foodigo_customer_app/models/atm_card.dart';

class Token {
  final String tokenID, entity, method;
  final ATMCard card;
  Token(this.tokenID, this.entity, this.method, this.card);
  factory Token.fromMap(Map<String, dynamic> json) {
    return Token(
        json['id'] ?? "",
        json['entity'] ?? "",
        json['method'] ?? "",
        json['card'] == null
            ? ATMCard(-1, -1, -1, "", "", "", false, false)
            : ATMCard.fromMap(json['card']));
  }
}
