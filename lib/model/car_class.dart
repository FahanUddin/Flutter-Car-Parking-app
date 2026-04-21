class CarClass {
  String? plateNo;
  String? carModel;
  bool? isDisabled;
  bool? isElectric;

  CarClass({this.plateNo, this.carModel, this.isDisabled, this.isElectric});

  // receiving data from server
  factory CarClass.fromMap(map) {
    return CarClass(
        plateNo: map['plateNo'],
        carModel: map['carModel'],
        isDisabled: map['isDisabled'],
        isElectric: map['isElectric']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'plateNo': plateNo,
      'carModel': carModel,
      'isDisabled': isDisabled,
      'isElectric': isElectric,
    };
  }
}
