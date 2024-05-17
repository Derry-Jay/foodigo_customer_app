class CustomField {
  final String name, view, value;
  CustomField(this.name, this.view, this.value);
  factory CustomField.fromMap(Map<String, dynamic> json) {
    return CustomField(json['name'], json['view'] ?? "", json['value'] ?? "");
  }
}
