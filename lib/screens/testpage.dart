import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  late DateTime _minDate, _maxDate;
  void initState() {
    getCar();
    //_minDate = startDate;
    //_maxDate=DateTime(2020,3,25,9,0,0);
    super.initState();
  }

  final _auth = FirebaseAuth.instance;
  late TimeOfDay _startbookingHour = TimeOfDay.now();

  late TimeOfDay _endbookingHour = TimeOfDay.now();

  var nowDate = DateFormat('yyyy').format(DateTime.now());

  late DateTime startDate;
  late DateTime endDate;

  String markerID = 'qnEeTJPDG60QY1PBDZ0Y';

  var _startDate = DateTime.now();
  String formattedDate = "Pick Date";
  var price = 4.0;

  late DateTime startDate_TTD;
  late DateTime endDate_TTD;

  var bookinghour = 0;
  var bookinghour_inMinute = 0.0;
  late double carParkPrice = 0.0;
  var minute_to_hour = 0.0;
  // var display_minute = 0;
  double widgetPositionDefault = -1030;
  double widgetPositionVisible = 0;
  double widgetPositionNotVisible = -1030;
  var cars = [
    "Choose a car",
  ];
  List<String> carDatabase = [];
  var selectedCar = "Choose a car";

  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference carsCollection =
      FirebaseFirestore.instance.collection('users');
  getCar() async {
    QuerySnapshot querySnapshot =
        await carsCollection.doc(user!.uid).collection("cars").get();
    ;

    final allData = querySnapshot.docs
        .map((doc) =>
            ((doc.get('carModel')) + ("-") + (doc.get('plateNo'))) as String)
        .toList();
    cars = cars + allData;
    // print(cars);
    /*StreamBuilder<DocumentSnapshot>(
        stream:
             carsCollection.doc(user!.uid).collection("cars").doc().snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.hasError) {
            return showAlertDialog(context, "Error retrieving cars");
          }
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else {
            showAlertDialog(
                context,
                streamSnapshot.data!['carModel'] +
                    streamSnapshot.data!['plateNo']);
          }
          return Positioned(
            left: 0,
            top: 55,
            child: Text(
              'cars: ' +
                  streamSnapshot.data!['carModel'] +
                  streamSnapshot.data!['plateNo'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          );
        });
  */
  }

/*
  getMarkerData() async {
    return FirebaseFirestore.instance.collection('locations').get().then((value) => {
          if (value.docs.isNotEmpty)
            {
              for (int i = 0; i < value.docs.length; i++)
                {cars(value.docs[i].data(), value.docs[i].id)}
            }
        });
  }*/

  void showWidget() {
    setState(() {
      widgetPositionDefault = widgetPositionVisible;
    });
  }

  void hideWidget() {
    setState(() {
      widgetPositionDefault = widgetPositionNotVisible;
    });
  }

  //var display_time = ":";
  showAlertDialog(BuildContext context, String msg) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
        body: Container(
      color: Colors.blueGrey,
      child: Flexible(
          child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            Positioned(
                top: 380,
                child: ElevatedButton(
                  onPressed: () async {
                    //getCar();

                    if (selectedCar == "Choose a car") {
                      showAlertDialog(context, "You need to select a car");
                    } else {
                      showAlertDialog(context, "You selected " + selectedCar);
                    }
                  },
                  child: Text(
                    "Validate box",
                  ),
                )),
            Positioned(
                top: 100,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 105,
                        width: 300,
                        child: Expanded(
                            child: SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2))),
                            isExpanded: false,
                            hint: Text("Choose a car"),
                            items: cars
                                .map((car) => DropdownMenuItem(
                                    value: car, child: Text(car)))
                                .toList(),
                            value: selectedCar == "Choose a car"
                                ? 'Choose a car'
                                : selectedCar,
                            onChanged: (car) {
                              setState(() {
                                selectedCar = car.toString();
                              });
                            },
                          ),
                        )))))
          ],
        ),
      )),
    ));
  }
}
