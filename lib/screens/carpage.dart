// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:carparkapp_new/main.dart';
import 'package:carparkapp_new/model/bank_class.dart';
import 'package:carparkapp_new/model/car_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoPage extends StatefulWidget {
  const CarInfoPage({Key? key}) : super(key: key);
  @override
  State<CarInfoPage> createState() => _CarInfoPageState();
}

class _CarInfoPageState extends State<CarInfoPage> {
  String? errorMessage;

  // our form key
  final _formKeyBP = GlobalKey<FormState>();
  // editing Controller
  final carNoFieldController = new TextEditingController();
  final carModelFieldController = new TextEditingController();
  bool disabledFieldValue = false;
  bool electricFieldValue = false;

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    final carNoField = TextFormField(
        inputFormatters: [LengthLimitingTextInputFormatter(8)],
        autofocus: false,
        controller: carNoFieldController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{4,}$');
          if (value!.isEmpty) {
            return ("Car number plate cannot be empy");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter valid number plate(4 Character)");
          }
          return null;
        },
        onSaved: (value) {
          carNoFieldController.text = value!;
        },
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 3.0),
            borderRadius: BorderRadius.circular(15.0),
          ),
          prefixIcon: Icon(Icons.account_circle, color: Colors.white),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: const TextStyle(color: Colors.white60),
          hintText: "Car Number plate",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    final carModelField = TextFormField(
        inputFormatters: [LengthLimitingTextInputFormatter(15)],
        autofocus: false,
        controller: carModelFieldController,
        keyboardType: TextInputType.number,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Car model cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter valid car model");
          }
          return null;
        },
        onSaved: (value) {
          carNoFieldController.text = value!;
        },
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 3.0),
            borderRadius: BorderRadius.circular(15.0),
          ),
          prefixIcon:
              const Icon(Icons.credit_card_outlined, color: Colors.white),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: const TextStyle(color: Colors.white),
          hintText: "car model",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    final disableCheckBox = Checkbox(
      value: disabledFieldValue,
      onChanged: (bool? value) {
        setState(() {
          disabledFieldValue = value!;
        });
      },
    );

    final electricCheckBox = Checkbox(
      value: electricFieldValue,
      onChanged: (bool? value) {
        setState(() {
          electricFieldValue = value!;
        });
      },
    );

    final submitButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      color: const Color(0xFF17262A),
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            submit();
          },
          child: const Text(
            "Submit",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 24, 36, 44),
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.airport_shuttle_rounded),
            Text("Car Details"),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 24, 36, 44),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('cars')
                    .orderBy('carModel', descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong', textScaleFactor: 1);
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading", textScaleFactor: 1);
                  }
                  if (snapshot.data!.size == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height - 320,
                              child: Text(
                                "No cars saved",
                                style: TextStyle(fontSize: 25),
                              )),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                primary: Colors.blueGrey,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 120, vertical: 25)),
                            child: Text("Add car"),
                            onPressed: () async {
                              Future<void> showInfoDialog(
                                  BuildContext context) async {
                                return await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Add Car Details",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 25),
                                        ),
                                        content: Center(
                                          child: SingleChildScrollView(
                                            child: Container(
                                              //color: const Color.fromARGB(255, 255, 150, 3),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Form(
                                                  key: _formKeyBP,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      new Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            width: 0.0,
                                                          ),
                                                          new Flexible(
                                                            child: Text(
                                                                'Car number plate',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start),
                                                          ),
                                                          SizedBox(
                                                              //width: 180.0,
                                                              ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      carNoField,
                                                      SizedBox(height: 15),
                                                      new Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            width: 0.0,
                                                          ),
                                                          new Flexible(
                                                            child: Text(
                                                              'Car Model',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              //width: 220.0,
                                                              ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 15),
                                                      carModelField,
                                                      SizedBox(height: 25),
                                                      SizedBox(height: 45),
                                                      submitButton
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              }

                              await showInfoDialog(context);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  final data = snapshot.requireData;

                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 230,
                        child: Stack(
                          children: [
                            ListView.builder(
                                itemCount: data.size,
                                itemBuilder: (context, index) {
                                  String carModel =
                                      data.docs[index]['carModel'];
                                  String plateNo = data.docs[index]['plateNo'];

                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            height: 55,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                90,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color: Colors.indigoAccent,
                                            ),
                                            //color: Colors.blueGrey,
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ListTile(
                                                onTap: () async {
                                                  /*  print("Id car park" +
                                                      data.docs[index]['carModel']);*/
                                                },
                                                //tileColor: Colors.green,
                                                selectedTileColor: Colors.black,
                                                title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(3),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Stack(
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Positioned(
                                                                        top: 1,
                                                                        child:
                                                                            Text(
                                                                          ' ${carModel}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                                          //textScaleFactor: 0.2,
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        bottom:
                                                                            0,
                                                                        child:
                                                                            Text(
                                                                          ' ${" - " + plateNo}',
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ]),
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //floating button
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Expanded(
                                            child:
                                                FloatingActionButton.extended(
                                                    heroTag: plateNo,
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    label: Icon(
                                                        Icons.cancel_rounded),
                                                    onPressed: () async {
                                                      showConfirmation(
                                                        BuildContext context,
                                                      ) {
                                                        // set up the button
                                                        Widget okButton =
                                                            TextButton(
                                                          child: Text("Yes"),
                                                          onPressed: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .runTransaction(
                                                                    (Transaction
                                                                        myTransaction) async {
                                                              await myTransaction
                                                                  .delete(snapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .reference);
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        );

                                                        Widget cancelButton =
                                                            TextButton(
                                                          child: Text("No"),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        );
                                                        // set up the AlertDialog
                                                        AlertDialog alert =
                                                            AlertDialog(
                                                          title: Text(
                                                              "Delete record"),
                                                          content: Text(
                                                              "Do you wish to delete the car record?"),
                                                          actions: [
                                                            okButton,
                                                            cancelButton
                                                          ],
                                                        );

                                                        // show the dialog
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return alert;
                                                          },
                                                        );
                                                      }

                                                      await showConfirmation(
                                                          context);
                                                    }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            primary: Colors.blueGrey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 20)),
                        child: Text("Add car"),
                        onPressed: () async {
                          Future<void> showInfoDialog(
                              BuildContext context) async {
                            return await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Add Car Details",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 25),
                                    ),
                                    content: Center(
                                      child: SingleChildScrollView(
                                        child: Container(
                                          //color: const Color.fromARGB(255, 255, 150, 3),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Form(
                                              key: _formKeyBP,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  new Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 0.0,
                                                      ),
                                                      new Flexible(
                                                        child: Text(
                                                            'Car number plate',
                                                            textAlign: TextAlign
                                                                .start),
                                                      ),
                                                      SizedBox(
                                                          //width: 180.0,
                                                          ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  carNoField,
                                                  SizedBox(height: 15),
                                                  new Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 0.0,
                                                      ),
                                                      new Flexible(
                                                        child: Text(
                                                          'Car Model',
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          //width: 220.0,
                                                          ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),
                                                  carModelField,
                                                  SizedBox(height: 25),
                                                  SizedBox(height: 45),
                                                  submitButton
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          }

                          await showInfoDialog(context);
                        },
                      ),
                    ],
                  );
                }),
          ],
        ),
      ]),
    );
  }

  showAlertDialog(BuildContext context, String msg, void function) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        function;
      },
    );

    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete record"),
      content: Text(msg),
      actions: [okButton, cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void submit() async {
    if (_formKeyBP.currentState!.validate()) {
      postDetailsToFirestore();
    } else {
      Fluttertoast.showToast(msg: 'There was an error with the details');
    }
    Navigator.pop(context);
  }

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    CarClass carClass = CarClass();

    // writing all the values

    carClass.plateNo = carNoFieldController.text;
    carClass.carModel = carModelFieldController.text;
    carClass.isDisabled = disabledFieldValue;
    carClass.isElectric = electricFieldValue;

    await firebaseFirestore
        .collection("users")
        .doc(user!.uid)
        .collection("cars")
        .doc()
        .set(carClass.toMap());
    Fluttertoast.showToast(msg: "Car Details saved :) ");
  }
}
