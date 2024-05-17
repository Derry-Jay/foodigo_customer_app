import 'user.dart';

class Review {
  final int reviewID;
  final String review, rate;
  final User user;
  Review(this.reviewID, this.review, this.rate, this.user);
  factory Review.fromMap(Map<String, dynamic> json) {
    return Review(
        json['id'], json['review'], json['rate'], User.fromJSON(json['user']));
  }
}
