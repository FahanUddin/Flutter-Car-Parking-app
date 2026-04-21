import 'dart:async';

import 'package:carparkapp_new/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerification();

      timer = Timer.periodic(
        Duration(seconds: 4),
        (_) => checkVerification(),
      );
    }
  }

  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkVerification() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const LoginPage()
      : Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Icon(
                      Icons.email_rounded,
                      size: 90,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Verification Email sent, please check your inbox.",
                    style: TextStyle(color: Colors.black, fontSize: 48),
                  )
                ],
              ),
            ),
          ),
        );
}

Future sendVerification() async {
  try {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
  } catch (e) {
    Fluttertoast.showToast(msg: "Verification Error :(");
  }
}
