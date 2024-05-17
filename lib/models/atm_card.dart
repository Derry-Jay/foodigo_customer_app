class ATMCard {
  final int last4, expMt, expYr;
  final String nameOnCard, network, issuer;
  final bool isI18N, emi;
  ATMCard(this.last4, this.expMt, this.expYr, this.nameOnCard, this.network,
      this.issuer, this.isI18N, this.emi);
  factory ATMCard.fromMap(Map<String, dynamic> json) {
    return ATMCard(
        json['last4'] is String
            ? (int.tryParse(json['last4']) ?? -9999)
            : json['last4'],
        json['expiry_month'],
        json['expiry_year'],
        json['name'],
        json['network'],
        json['issuer'],
        json['international'],
        json['emi']);
  }
}
