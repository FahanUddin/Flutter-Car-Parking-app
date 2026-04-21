import 'package:carparkapp_new/auth_services.dart';
import 'package:carparkapp_new/login_controller.dart';
import 'package:carparkapp_new/login_page.dart';
import 'package:carparkapp_new/model/user_class.dart';
import 'package:carparkapp_new/screens/bankpage.dart';
import 'package:carparkapp_new/screens/carpage.dart';
import 'package:carparkapp_new/screens/orderhistorypage.dart';
import 'package:carparkapp_new/screens/testpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../circle_transition.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({Key? key}) : super(key: key);

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  @override
  void initState() {
    super.initState();
  }

  late final String uid;
  final firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  final padding = const EdgeInsets.symmetric(horizontal: 40);

  final controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Material(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Container(
                  height: 170,
                  color: const Color.fromARGB(255, 27, 26, 23),
                  child: ListView(
                    children: <Widget>[
                      Container(
                          // color: Colors.amber,
                          height: 170,
                          padding: const EdgeInsets.only(left: 20),
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: usersCollection.doc(user!.uid).snapshots(),
                            builder: (ctx, streamSnapshot) {
                              if (streamSnapshot.hasError) {
                                return Text("");
                              }
                              if (streamSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                );
                              }
                              return Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 55,
                                    child: Text(
                                      'Balance: £' +
                                          streamSnapshot.data!['money']
                                              .toStringAsFixed(2),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    child: Text('Welcome, ' +
                                        streamSnapshot.data!['firstName'] +
                                        "\n" +
                                        streamSnapshot.data!['email']),
                                  ),
                                ],
                              );
                            },
                          ))
                    ],
                  )),
              const SizedBox(
                height: 20,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white)),
              ),
              ListTile(
                tileColor: Color.fromARGB(255, 27, 26, 23),
                leading: Icon(Icons.credit_card, color: Colors.white),
                title: const Text(
                  'Bank Details',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BankInfoPage()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                tileColor: Color.fromARGB(255, 27, 26, 23),
                leading: Icon(Icons.drive_eta, color: Colors.white),
                title: const Text(
                  'Car Details',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CarInfoPage()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                tileColor: Color.fromARGB(255, 27, 26, 23),
                leading: Icon(Icons.history_edu_rounded, color: Colors.white),
                title: const Text(
                  'Order History',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderHistoryPage()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 270,
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 200,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          controller.logout();
                          Navigator.of(context).pushReplacement(_routelogin());
                        },
                        heroTag: "logoutbtn",
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late String _uid;

  var userData = FirebaseFirestore.instance
      .collection("users")
      .doc()
      .collection('email')
      .snapshots();

  Widget BuildMenuItem({
    required String text,
    required IconData icon,
  }) {
    final color = Colors.white;

    return ListTile(
      tileColor: Color.fromARGB(255, 27, 26, 23),
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      onTap: () {},
    );
  }

  Route _routelogin() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionDuration: const Duration(milliseconds: 1300),
        reverseTransitionDuration: const Duration(milliseconds: 1300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var screenSize = MediaQuery.of(context).size;
          var centerCircular =
              Offset(screenSize.width / 2, screenSize.height / 2);

          double beginRadius = 0.0;
          double endRadius = screenSize.height * 1.2;

          var radiusTween = Tween(begin: beginRadius, end: endRadius);
          var radiusTweenAnimation = animation.drive(radiusTween);

          return ClipPath(
            child: child,
            clipper: CircleTransition(
              radius: radiusTweenAnimation.value,
              center: centerCircular,
            ),
          );
        });
  }
}
