class OrderClass {
  String? uid;
  String? userUid;
  String? parkingLocation;
  String? parkingBay;
  String? parkingId;
  String? spaceId;
  DateTime? startDate;
  DateTime? endDate;
  String? duration;
  String? carModel;
  double? parkPrice;
  bool? completed = false;

  OrderClass({
    this.uid,
    this.userUid,
    this.parkingLocation,
    this.parkingBay,
    this.parkingId,
    this.spaceId,
    this.startDate,
    this.endDate,
    this.duration,
    this.carModel,
    this.parkPrice,
    this.completed,
  });

  factory OrderClass.fromMap(map) {
    return OrderClass(
        uid: map['uid'],
        userUid: map['userUid'],
        parkingLocation: map['parkingLocation'],
        parkingBay: map['parkingBay'],
        parkingId: map['parkingId'],
        spaceId: map['spaceId'],
        startDate: map['startDate'],
        endDate: map['endDate'],
        duration: map['duration'],
        carModel: map['carModel'],
        parkPrice: map['parkPrice'],
        completed: map['completed']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userUid': userUid,
      'parkingLocation': parkingLocation,
      'parkingBay': parkingBay,
      'parkingId': parkingId,
      'spaceId': spaceId,
      'startDate': startDate,
      'endDate': endDate,
      'duration': duration,
      'carModel': carModel,
      'parkPrice': parkPrice,
      'completed': completed,
    };
  }
}
