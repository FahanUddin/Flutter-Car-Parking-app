import 'package:carparkapp_new/screens/orderhistorypage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PastOrderHistoryPage extends StatefulWidget {
  const PastOrderHistoryPage({Key? key}) : super(key: key);
  @override
  State<PastOrderHistoryPage> createState() => _PastOrderHistoryPageState();
}

class _PastOrderHistoryPageState extends State<PastOrderHistoryPage> {
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
                  Text("Past Booking"),
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
                  Navigator.pop(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderHistoryPage()));
                },
                child: Text("Current Bookings"),
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
                            .where('endDate', isLessThan: currentTime)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong',
                                textScaleFactor: 1);
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              "Loading bookings",
                              textScaleFactor: 1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          }
                          if (snapshot.data!.size == 0) {
                            return Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No past bookings',
                                  textScaleFactor: 1.8,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                          final data = snapshot.requireData;

                          return Stack(
                            children: [
                              ListView.builder(
                                  itemCount: data.size,
                                  itemBuilder: (context, index) {
                                    String parkingUid = data.docs[index]['uid'];
                                    String parkingLocation =
                                        data.docs[index]['parkingLocation'];
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
                                    double parkPrice =
                                        data.docs[index]['parkPrice'];
                                    DateTime endDateAsDate = endDate.toDate();

                                    return ListTile(
                                      //tileColor: Colors.amber,
                                      title: Column(children: [
                                        Container(
                                          height: 160,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.blueGrey,
                                                blurRadius: 0,
                                                offset: Offset(
                                                    0, 3), // Shadow position
                                              ),
                                            ],
                                            //color: Colors.black,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(children: [
                                              Expanded(
                                                child: Positioned(
                                                  top: 1,
                                                  child: Text(
                                                    ' ${parkingLocation}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                    //textScaleFactor: 0.2,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors.white),
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
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                child: Text(
                                                  ' ${"Bay: " + parkingBay}', //' ${data.docs[index]['uid'] /*+ data.docs[index]['parkingLevel']*/}',
                                                  //textScaleFactor: 0.2,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white),
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
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white),
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
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 49,
                                                right: 1,
                                                child: Text(
                                                  ' ${"Date: " + startDateAsDate.toString().substring(
                                                        0,
                                                        10,
                                                      )}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ]),
                                    );
                                  }),
                            ],
                          );
                        })
                  ],
                )),
          ])),
    );
  }
}
