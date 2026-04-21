// ignore_for_file: prefer_const_constructors, unnecessary_new
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:carparkapp_new/main.dart';
import 'package:carparkapp_new/model/bank_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class BankInfoPage extends StatefulWidget {
  const BankInfoPage({Key? key}) : super(key: key);
  @override
  State<BankInfoPage> createState() => _BankInfoPageState();
}

class _BankInfoPageState extends State<BankInfoPage> {
  String? errorMessage;

  // our form key
  final _formKeyBP = GlobalKey<FormState>();
  final _formKeyTopUp = GlobalKey<FormState>();
  // editing Controller
  final cardNameFieldController = new TextEditingController();
  final accountNoFieldController = new TextEditingController();
  final expiryDateFieldEditingController = new TextEditingController();
  final cvvFieldEditingController = new TextEditingController();
  final cvvConfirmFieldEditingController = new TextEditingController();
  final NameEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final confirmPasswordEditingController = new TextEditingController();
  final moneyAmountEditingController = new TextEditingController();
  String topUpAsString = "1.5";

  double topUp = 0.0;

  var _startDate = DateTime.now();
  String formattedDate = "Pick Date";
  bool dateSelected = false;

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    final cardNameField = TextFormField(
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
        autofocus: false,
        controller: cardNameFieldController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Card name cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid name(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          NameEditingController.text = value!;
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
          hintStyle: const TextStyle(color: Colors.white),
          hintText: "Card Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));
    final cardHolderField = TextFormField(
        inputFormatters: [LengthLimitingTextInputFormatter(25)],
        autofocus: false,
        controller: NameEditingController,
        keyboardType: TextInputType.name,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Cardholder name cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid name(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          NameEditingController.text = value!;
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
          hintStyle: const TextStyle(color: Colors.white),
          hintText: "Card Holder Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    final accountNoField = TextFormField(
        inputFormatters: [LengthLimitingTextInputFormatter(16)],
        autofocus: false,
        controller: accountNoFieldController,
        keyboardType: TextInputType.number,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{16,}$');
          if (value!.isEmpty) {
            return ("Account number cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter valid card number(Min. 16 Character)");
          }
          return null;
        },
        onSaved: (value) {
          accountNoFieldController.text = value!;
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
          hintText: "0000-0000-0000-0000",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    final expiryField = ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          primary: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
      onPressed: () async {
        await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 360)))
            .then((date) {
          if (date == null) return;
          setState(() {
            _startDate = ((date));
            formattedDate = DateFormat('yyyy-MM').format(_startDate);
            expiryDateFieldEditingController.text = formattedDate.toString();
            dateSelected = true;
          });
        });
        //Navigator.pop(context);
      },
      child: Text(
        formattedDate == null ? 'No date picked' : formattedDate,
        style: TextStyle(fontSize: 14, color: Colors.black),
      ),
    );

    final amountField = TextFormField(
        inputFormatters: [
          MoneyInputFormatter(
              maxTextLength: 8,
              trailingSymbol: MoneySymbols.POUND_SIGN,
              useSymbolPadding: true,
              mantissaLength: 2)
        ],
        autofocus: false,
        controller: moneyAmountEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == 0.0) {
            return ("Top up amount cannot be 0");
          }
          if (value!.isEmpty) {
            return ("Top up amount cannot be 0");
          }

          return null;
        },
        onSaved: (value) {
          //topUpAmount = value as double;
        },
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 3.0),
            borderRadius: BorderRadius.circular(15.0),
          ),
          prefixIcon: const Icon(Icons.upload_rounded, color: Colors.white),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: const TextStyle(color: Colors.white),
          hintText: "00.00",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));

    final cvvField = TextFormField(
        inputFormatters: [LengthLimitingTextInputFormatter(3)],
        autofocus: false,
        controller: cvvFieldEditingController,
        keyboardType: TextInputType.number,
        validator: (value) {
          RegExp regex = new RegExp("^([0-9]{3})");
          if (value!.isEmpty) {
            return ("CVV cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter valid cvv(Min. 3 digits)");
          }
          return null;
        },
        onSaved: (value) {
          cvvFieldEditingController.text = value!;
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
          hintText: "123",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));

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
            Icon(Icons.credit_card_rounded),
            Text("Bank Details"),
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
          height: 60,
        ),

        Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('bank')
                    .orderBy('cardName', descending: false)
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
                    return Text('No Banking details saved', textScaleFactor: 1);
                  }
                  final data = snapshot.requireData;

                  return Column(
                    children: [
                      Text(
                        "Select a card to top up balance",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 230,
                        //alignment: Alignment.center,
                        child: Stack(
                          children: [
                            ListView.builder(
                                itemCount: data.size,
                                itemBuilder: (context, index) {
                                  String cardName =
                                      data.docs[index]['cardName'];
                                  String cardNo = data.docs[index]['cardNo'];
                                  String maskedCardNo =
                                      ('**** **** ****' + cardNo.substring(12));
                                  String cardHolder =
                                      data.docs[index]['cardholderName'];
                                  String cardExpiry =
                                      data.docs[index]['expiryDate'];
                                  String cardCVV = data.docs[index]['cvv'];

                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: 20, left: 8, right: 8),
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            height: 85,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                90,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color: Colors.blueGrey,
                                            ),
                                            //color: Colors.blueGrey,
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ListTile(
                                                selectedTileColor: Colors.black,
                                                title: Row(children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Expanded(
                                                      child: Center(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              cardName,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            Text(
                                                              cardNo.replaceAllMapped(
                                                                  RegExp(
                                                                      r".{4}"),
                                                                  (match) =>
                                                                      "${match.group(0)} "),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                                onTap: () async {
                                                  showConfirmation(
                                                    BuildContext context,
                                                  ) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Container(
                                                          child: Form(
                                                            key: _formKeyTopUp,
                                                            child: OverflowBox(
                                                              child: Material(
                                                                color: Colors
                                                                    .blueGrey,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          IconButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                                setToDefault();
                                                                              },
                                                                              icon: Icon(Icons.arrow_back_ios)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        height: MediaQuery.of(context)
                                                                            .size
                                                                            .height,
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        child:
                                                                            Scaffold(
                                                                          resizeToAvoidBottomInset:
                                                                              false,
                                                                          backgroundColor:
                                                                              Colors.blueGrey,
                                                                          body:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(18.0),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.green.shade400,
                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(13),
                                                                                  height: 200,
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      Positioned(
                                                                                          bottom: 30,
                                                                                          child: Text(
                                                                                            cardNo.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} "),
                                                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                          )),
                                                                                      Positioned(
                                                                                          top: 10,
                                                                                          child: Text(
                                                                                            cardName,
                                                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                          )),
                                                                                      Positioned(
                                                                                          bottom: 1,
                                                                                          child: Text(
                                                                                            cardHolder,
                                                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                          )),
                                                                                      Positioned(
                                                                                          bottom: 1,
                                                                                          right: 1,
                                                                                          child: Text(
                                                                                            (cardExpiry.replaceAllMapped(RegExp(r".{2}"), (match) => "${match.group(0)}/")).substring(0, 6 - 1),
                                                                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                          ))
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Center(
                                                                                child: SizedBox(
                                                                                    width: 220,
                                                                                    child: TextFormField(
                                                                                        inputFormatters: [LengthLimitingTextInputFormatter(3)],
                                                                                        autofocus: false,
                                                                                        controller: cvvConfirmFieldEditingController,
                                                                                        keyboardType: TextInputType.number,
                                                                                        validator: (value) {
                                                                                          RegExp regex = new RegExp("^([0-9]{3})");
                                                                                          if (value != cardCVV) {
                                                                                            return ("CVV invalid");
                                                                                          }
                                                                                          if (value!.isEmpty) {
                                                                                            return ("CVV cannot be Empty");
                                                                                          }
                                                                                          if (!regex.hasMatch(value)) {
                                                                                            return ("Enter valid cvv(Min. 3 digits)");
                                                                                          }
                                                                                          return null;
                                                                                        },
                                                                                        onSaved: (value) {
                                                                                          cvvConfirmFieldEditingController.text = value!;
                                                                                        },
                                                                                        textInputAction: TextInputAction.next,
                                                                                        style: const TextStyle(color: Colors.white),
                                                                                        decoration: InputDecoration(
                                                                                          enabledBorder: OutlineInputBorder(
                                                                                            borderSide: const BorderSide(color: Colors.white, width: 3.0),
                                                                                            borderRadius: BorderRadius.circular(15.0),
                                                                                          ),
                                                                                          prefixIcon: const Icon(Icons.credit_card_outlined, color: Colors.white),
                                                                                          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                                                          hintStyle: const TextStyle(color: Colors.white),
                                                                                          hintText: "CVV",
                                                                                          border: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(15),
                                                                                          ),
                                                                                        ))),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              Center(
                                                                                child: SizedBox(
                                                                                  width: 170,
                                                                                  child: TextFormField(
                                                                                      inputFormatters: [MoneyInputFormatter(maxTextLength: 8, mantissaLength: 2)],
                                                                                      autofocus: false,
                                                                                      controller: moneyAmountEditingController,
                                                                                      keyboardType: TextInputType.number,
                                                                                      validator: (value) {
                                                                                        if (value!.isEmpty) {
                                                                                          return ("Top up amount cannot be 0");
                                                                                        }
                                                                                        if (value == 0) {
                                                                                          return ("Top up amount cannot be 0");
                                                                                        }

                                                                                        return null;
                                                                                      },
                                                                                      onSaved: (value) {
                                                                                        double value = double.parse(moneyAmountEditingController.text);
                                                                                        setState(() {
                                                                                          topUp = value;
                                                                                        });
                                                                                        //topUp = value as double;
                                                                                      },
                                                                                      onChanged: (s) {
                                                                                        double s = double.parse(moneyAmountEditingController.text);
                                                                                        setState(() {
                                                                                          topUp = s;
                                                                                        });
                                                                                      },
                                                                                      textInputAction: TextInputAction.next,
                                                                                      style: const TextStyle(color: Colors.white),
                                                                                      decoration: InputDecoration(
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderSide: const BorderSide(color: Colors.white, width: 3.0),
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        prefixIcon: const Icon(Icons.upload_rounded, color: Colors.white),
                                                                                        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                                                        hintStyle: const TextStyle(color: Colors.white),
                                                                                        hintText: "00.00",
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(15),
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsets.only(top: 40),
                                                                                child: Material(
                                                                                  elevation: 5,
                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                  color: const Color(0xFF17262A),
                                                                                  child: MaterialButton(
                                                                                      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                                                      minWidth: 200,
                                                                                      onPressed: () async {
                                                                                        //Navigator.pop(context);
                                                                                        print("this is the top up: " + topUp.toString());
                                                                                        print("this is the cvv: " + cardCVV);
                                                                                        print("this is the cvv to be matched" + cvvConfirmFieldEditingController.text);
                                                                                        print("this is top up as string" + (topUp).toString());
                                                                                        topUpValidation();

                                                                                        //Navigator.pop(context);
                                                                                      },
                                                                                      child: const Text(
                                                                                        "Submit",
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                                                                      )),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }

                                                  await showConfirmation(
                                                      context);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Expanded(
                                            child:
                                                FloatingActionButton.extended(
                                                    heroTag: cardNo,
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
                                                              "Delete card"),
                                                          content: Text(
                                                              "Do you wish to delete the card?"),
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
                                })
                          ],
                        ),
                      ),
                    ],
                  );
                })
          ],
        ),
        //add card form down here
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: 250,
              padding: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(
                    "Add a new card",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  onPressed: () async {
                    Future<void> showInfoDialog(BuildContext context) async {
                      return await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                "Add Card Details",
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
                                      padding: const EdgeInsets.all(16.0),
                                      child: Form(
                                        key: _formKeyBP,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                new Flexible(
                                                  child: Text('Bank Card Name'),
                                                ),
                                                SizedBox(
                                                  width: 90.0,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            cardNameField,
                                            SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                new Flexible(
                                                  child: Text('Name on Card'),
                                                ),
                                                SizedBox(
                                                  width: 90.0,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            cardHolderField,
                                            SizedBox(height: 15),
                                            new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                new Flexible(
                                                  child: Text('Card Number'),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            accountNoField,
                                            SizedBox(height: 25),
                                            /*new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                new Flexible(
                                                  child:
                                                      Text('Expiry Date'),
                                                ),
                                                SizedBox(
                                                  width: 90.0,
                                                ),
                                                new Flexible(
                                                    child: Text('CVV')),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                              ],
                                            ),*/

                                            SizedBox(height: 15),
                                            new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                new Flexible(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3)),
                                                        primary: Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10,
                                                                vertical: 10)),
                                                    onPressed: () async {
                                                      await showMonthPicker(
                                                              context: context,
                                                              initialDate:
                                                                  DateTime
                                                                      .now(),
                                                              firstDate:
                                                                  DateTime
                                                                      .now(),
                                                              lastDate: DateTime
                                                                      .now()
                                                                  .add(Duration(
                                                                      days:
                                                                          660)))
                                                          .then((date) {
                                                        if (date == null)
                                                          return;
                                                        //Navigator.pop(context);
                                                        setState(() {
                                                          _startDate = ((date));
                                                          formattedDate =
                                                              DateFormat(
                                                                      'yyyy-MM')
                                                                  .format(
                                                                      _startDate);
                                                          expiryDateFieldEditingController
                                                                  .text =
                                                              formattedDate
                                                                  .toString();
                                                          dateSelected = true;
                                                        });
                                                      });

                                                      //await showInfoDialog(
                                                      // context);
                                                    },
                                                    child: Text(
                                                      formattedDate == null
                                                          ? 'No date picked'
                                                          : formattedDate,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                Text('Expiry Date'),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                new Flexible(
                                                  child: cvvField,
                                                ),
                                                new Flexible(
                                                    child: Text('CVV')),
                                              ],
                                            ),
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
                  }),
            ),
          ),
        )
      ]),
    );
  }

  void submit() async {
    if (_formKeyBP.currentState!.validate()) {
      postDetailsToFirestore();
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: 'There was an error with the details');
    }
  }

  void topUpValidation() async {
    if (_formKeyTopUp.currentState!.validate()) {
      await topUpUser();
      setToDefault();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Top up succesfull');
    } else {
      Fluttertoast.showToast(msg: 'There was an error with the details');
    }
  }

  setToDefault() async {
    setState(() {
      topUp = 0.0;
      cvvConfirmFieldEditingController.text = "";
      moneyAmountEditingController.text = "";
      cardNameFieldController.text = "";
      accountNoFieldController.text = "";
      NameEditingController.text = "";
      cvvFieldEditingController.text = "";
      expiryDateFieldEditingController.text = "";
    });
  }

  topUpUser() async {
    User? user = _auth.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((document) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'money': FieldValue.increment(topUp)});
    });
    print("User Top up done" + topUp.toString());
    setToDefault();
  }

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    BankClass bankClass = BankClass();

    // writing all the values
    bankClass.cardName = cardNameFieldController.text;
    bankClass.cardNo = accountNoFieldController.text;
    bankClass.cardholderName = NameEditingController.text;
    bankClass.cvv = cvvFieldEditingController.text;
    bankClass.expiryDate = expiryDateFieldEditingController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user!.uid)
        .collection("bank")
        .doc()
        .set(bankClass.toMap());
    Fluttertoast.showToast(msg: "Bank Details saved :) ");
    setToDefault();
  }
}
