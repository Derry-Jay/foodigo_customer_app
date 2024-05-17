class ExtraGroup {
  final int extraGroupID;
  final String extraGroup;
  ExtraGroup(this.extraGroupID, this.extraGroup);
  factory ExtraGroup.fromMap(Map<String, dynamic> json) {
    return ExtraGroup(json['id'], json['name']);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = extraGroupID;
    map["name"] = extraGroup;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other is ExtraGroup && other.extraGroupID == this.extraGroupID;
  }

  @override
  int get hashCode => this.extraGroupID.hashCode;
}
