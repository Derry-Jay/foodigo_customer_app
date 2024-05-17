class Tag {
  final int tagID;
  final String tag;
  Tag(this.tagID, this.tag);
  factory Tag.fromMap(Map<String, dynamic> json) {
    return Tag(json['id'] ?? -1, json['name'] ?? "");
  }
  @override
  bool operator ==(Object other) => other is Tag && other.tagID == tagID;
  bool isIn(List<Tag> tags) {
    bool flag = false;
    for (Tag tag in tags)
      if (this == tag) {
        flag = true;
        break;
      }
    return flag;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.tagID.hashCode;
}
