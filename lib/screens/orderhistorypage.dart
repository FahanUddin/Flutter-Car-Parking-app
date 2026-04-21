import 'package:carparkapp_new/main.dart';
import 'package:carparkapp_new/screens/pastorderhistorypage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    DateTime currentTime = DateTime.now();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 24, 36, 44),
      appBar: AppBar(
        title: Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Icon(Icons.history_edu_outlined),
                  Text(" Booking History"),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PastOrderHistoryPage()));
                },
                child: Text("Past Bookings"),
              ),
            )
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
      body: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Column(children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width - 55,
                constraints: BoxConstraints(
                  maxHeight: 650,
                ),
                padding: EdgeInsets.all(4),
                margin: EdgeInsets.only(left: 8, right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  //color: Colors.indigoAccent,
                ),
                //width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    //onProgress order
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('orders')
                            .where('endDate', isGreaterThan: currentTime)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong',
                                textScaleFactor: 1);
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading bookings",
                              textScaleFactor: 1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          }
                          if (snapshot.data!.size == 0) {
                            return const Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'No bookings in progress',
                                  textScaleFactor: 1.8,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                          final data = snapshot.requireData;

                          return Column(
                            children: [
                              const Text(
                                "Select order tile to cancel order",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height - 230,
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                        itemCount: data.size,
                                        itemBuilder: (context, index) {
                                          String parkingID =
                                              data.docs[index]['parkingId'];
                                          String spaceID =
                                              data.docs[index]['spaceId'];
                                          String parkingLocation = data
                                              .docs[index]['parkingLocation'];
                                          String parkingBay =
                                              data.docs[index]['parkingBay'];
                                          String duration =
                                              data.docs[index]['duration'];

                                          Timestamp startDate =
                                              data.docs[index]['startDate'];
                                          DateTime startDateAsDate =
                                              startDate.toDate();
                                          Timestamp endDate =
                                              data.docs[index]['endDate'];
                                          DateTime endDateAsDate =
                                              endDate.toDate();
                                          double parkPrice =
                                              data.docs[index]['parkPrice'];

                                          double fee = parkPrice * 0.10;
                                          double refund = parkPrice - fee;

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                //color: Colors.indigoAccent,
                                              ),
                                              //color: Colors.blueGrey,
                                              child: ListTile(
                                                tileColor: Colors.green,
                                                selectedTileColor: Colors.black,
                                                title: Column(children: [
                                                  Container(
                                                    height: 160,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    margin:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Stack(children: [
                                                        Expanded(
                                                          child: Positioned(
                                                            top: 1,
                                                            child: Text(
                                                              ' ${parkingLocation}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                              //textScaleFactor: 0.2,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 23,
                                                          child: Text(
                                                            ' ${"Price: £" + parkPrice.toStringAsFixed(2)}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                            //textScaleFactor: 0.2,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 0,
                                                          child: Text(
                                                            ' ${"Bay: " + parkingBay}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                            //textScaleFactor: 0.2,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 0,
                                                          right: 1,
                                                          child: Text(
                                                            ' ${"End: " + endDateAsDate.toString().substring(
                                                                  10,
                                                                  19,
                                                                )}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                            //textScaleFactor: 0.2,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 24,
                                                          right: 1,
                                                          child: Text(
                                                            ' ${"Start: " + startDateAsDate.toString().substring(
                                                                  10,
                                                                  19,
                                                                )}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                            //textScaleFactor: 0.2,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 49,
                                                          right: 1,
                                                          child: Text(
                                                            ' ${"Date: " + endDateAsDate.toString().substring(
                                                                  0,
                                                                  10,
                                                                )}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 72,
                                                          right: 1,
                                                          child: Text(
                                                            "In Progress",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ),
                                                ]),
                                                onTap: () async {
                                                  print("Id car park" +
                                                      data.docs[index]['uid']);
                                                  showConfirmation(
                                                    BuildContext context,
                                                  ) {
                                                    // set up the button
                                                    Widget okButton =
                                                        TextButton(
                                                      child: Text("Yes"),
                                                      onPressed: () async {
                                                        //this refunds the money to the user,
                                                        //it increments the money field in the database
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(user.uid)
                                                            .get()
                                                            .then((document) {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(user.uid)
                                                              .update({
                                                            'money': FieldValue
                                                                .increment(
                                                                    refund)
                                                          });
                                                        });
                                                        //deletes order record
                                                        await FirebaseFirestore
                                                            .instance
                                                            .runTransaction(
                                                                (Transaction
                                                                    myTransaction) async {
                                                          await myTransaction
                                                              .delete(snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .reference);
                                                        });
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    const MyHomePage(
                                                                        title:
                                                                            'Car Parking')));
                                                        showSnackBar(context,
                                                            "Booking has been canceled");
                                                        //sets the state of the parking to free,
                                                        //so that it can be displayed in the view
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'locations')
                                                            .doc(parkingID)
                                                            .collection(
                                                                'parking_spaces')
                                                            .doc(spaceID)
                                                            .update({
                                                          'inUse': false
                                                        });
                                                      },
                                                    );

                                                    Widget cancelButton =
                                                        TextButton(
                                                      child: Text("No"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                    // set up the AlertDialog
                                                    AlertDialog alert =
                                                        AlertDialog(
                                                      title: const Text(
                                                          "Do you wish to cancel the booking?"),
                                                      content: Text("Total amount paid: £" +
                                                          parkPrice
                                                              .toStringAsFixed(
                                                                  2) +
                                                          "\n" +
                                                          "Fee: £" +
                                                          fee.toStringAsFixed(
                                                              2) +
                                                          "\n" +
                                                          "Refund amount: £" +
                                                          (parkPrice - fee)
                                                              .toStringAsFixed(
                                                                  2)),
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
                                                },
                                              ),
                                            ),
                                          );
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          );
                        })
                  ],
                )),
          ])),
    );
  }

  void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 1000,
      duration: const Duration(milliseconds: 1250),
      backgroundColor: Colors.black,
      content: Text(
        msg,
        style: const TextStyle(
            fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ));
  }
}
