class UserClass {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  String? phoneNumber;
  double? money = 0.0;
  String? token;

  UserClass(
      {this.uid,
      this.email,
      this.firstName,
      this.secondName,
      this.phoneNumber,
      this.money,
      this.token});

  // receiving data from server
  factory UserClass.fromMap(map) {
    return UserClass(
        uid: map['uid'],
        email: map['email'],
        firstName: map['firstName'],
        secondName: map['secondName'],
        phoneNumber: map['phoneNumber'],
        money: map['money'],
        token: map['token']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'phoneNumber': phoneNumber,
      'money': money,
      'token': token,
    };
  }
}
