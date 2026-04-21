import 'package:carparkapp_new/model/car_class.dart';
import 'package:carparkapp_new/model/order_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CarDetailWidget extends StatefulWidget {
  const CarDetailWidget({Key? key}) : super(key: key);

  @override
  State<CarDetailWidget> createState() => _CarDetailState();
}

class _CarDetailState extends State<CarDetailWidget> {
  @override
  void initState() {
    getCar();
    super.initState();
  }

  final _auth = FirebaseAuth.instance;

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

    final allData = querySnapshot.docs
        .map((doc) =>
            ((doc.get('carModel')) + ("-") + (doc.get('plateNo'))) as String)
        .toList();
    setState(() {
      cars = cars + allData;
    });

    print(cars);
  }

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

  OrderClass orderClass = OrderClass();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black, width: 2))),
        isExpanded: false,
        hint: Text("Choose a car"),
        items: cars
            .map((car) => DropdownMenuItem(value: car, child: Text(car)))
            .toList(),
        value: selectedCar == "Choose a car" ? 'Choose a car' : selectedCar,
        onChanged: (car) {
          setState(() {
            selectedCar = car.toString();
            orderClass.carModel = car.toString();
          });
          orderClass.carModel = car.toString();
          print("This is the car saved in orderclass: " +
              orderClass.carModel.toString());
        },
      ),
    );
  }
}
