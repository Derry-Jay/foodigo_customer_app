class RazorPayCustomer {
  final String customerID, customerName, customerEmail, customerPhone;
  final int createdAt;
  RazorPayCustomer(this.customerID, this.customerName, this.customerEmail,
      this.customerPhone, this.createdAt);
  factory RazorPayCustomer.fromMap(Map<String, dynamic> json) {
    return RazorPayCustomer(json['id'], json['name'], json['email'],
        json['contact'], json['created_at']);
  }
}
