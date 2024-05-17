class Reply {
  final bool success;
  final String message;
  Reply(this.message, this.success);
  factory Reply.fromMap(Map<String, dynamic> json) {
    return Reply(json['message'], json['success']);
  }
}
