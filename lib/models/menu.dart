class Menu {
  final int menuID;
  final String menu;
  Menu(this.menuID, this.menu);
  factory Menu.fromMap(Map<String, dynamic> json) {
    return Menu(json['id'], json['name']);
  }
}
