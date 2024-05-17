class Medium {
  final int mediumID;
  final String name, url, icon, size, thumb;
  Medium(this.mediumID, this.name, this.url, this.icon, this.thumb, this.size);
  factory Medium.fromMap(Map<String, dynamic> json) {
    return Medium(
        json['id'],
        json['name'] == null ? "" : json['name'],
        json['url'] == null ? "" : json['url'],
        json['thumb'] == null ? "" : json['thumb'],
        json['icon'] == null ? "" : json['icon'],
        json['formated_size'] == null ? "" : json['formated_size']);
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = mediumID;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;
    return map;
  }
}
