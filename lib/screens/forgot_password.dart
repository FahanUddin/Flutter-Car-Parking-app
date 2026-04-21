import 'dart:async';

import 'package:carparkapp_new/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Container headerSection() {
    return Container(
      child: const Text("Reset Password",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(255, 27, 26, 23),
            fontWeight: FontWeight.bold,
            fontSize: 55,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
        autofocus: false,
        controller: emailEditingController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Email");
          }
          // reg expression for email validation
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please Enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          emailEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        style: const TextStyle(
            color: Color.fromARGB(255, 27, 26, 23),
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 24, 36, 44), width: 3.0),
            borderRadius: BorderRadius.circular(15.0),
          ),
          prefixIcon: Icon(Icons.mail, color: const Color(0xFF17262A)),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintStyle: TextStyle(color: Colors.grey.shade800),
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));
    Future resetPassword() async {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailEditingController.text.trim());
        Fluttertoast.showToast(
            msg: "Password reset email has been sent, check your inbox");
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        Fluttertoast.showToast(msg: "Reset password Error :(");
      }
    }

    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      color: const Color(0xFF17262A),
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            resetPassword();
          },
          child: const Text(
            "Reset Password",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      /*const Color.fromARGB(255, 255, 150, 3),*/
      appBar: AppBar(
        backgroundColor: Colors.white,
        /*const Color.fromARGB(255, 255, 150, 3),*/
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 24, 36, 44)),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            /*const Color.fromARGB(255, 255, 150, 3),*/
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    headerSection(),
                    SizedBox(height: 45),
                    emailField,
                    SizedBox(height: 15),
                    signUpButton,
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
