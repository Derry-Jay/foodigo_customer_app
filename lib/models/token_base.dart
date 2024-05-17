import 'token.dart';

class TokenBase {
  final String entity;
  final int count;
  final List<Token> tokens;
  TokenBase(this.entity, this.count, this.tokens);
  factory TokenBase.fromMap(Map<String, dynamic> json) {
    return TokenBase(
        json['entity'],
        json['count'],
        json['items'] == null
            ? <Token>[]
            : List<Map<String, dynamic>>.from(json['items'])
                .map((e) => Token.fromMap(e))
                .toList());
  }
}
