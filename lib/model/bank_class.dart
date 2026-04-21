class BankClass {
  String? cardName;
  String? cardNo;
  String? cardholderName;
  String? cvv;
  String? expiryDate;

  BankClass(
      {this.cardName,
      this.cardNo,
      this.cardholderName,
      this.cvv,
      this.expiryDate});

  // receiving data from server
  factory BankClass.fromMap(map) {
    return BankClass(
        cardName: map['cardName'],
        cardNo: map['cardNo'],
        cardholderName: map['cardholderName'],
        cvv: map['cvv'],
        expiryDate: map['expiryDate']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'cardName': cardName,
      'cardNo': cardNo,
      'cardholderName': cardholderName,
      'cvv': cvv,
      'expiryDate': expiryDate,
    };
  }
}
