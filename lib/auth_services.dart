import 'package:carparkapp_new/model/user_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('user');

  Future getUser(String uid) async {
    try {
      var userData = await _collectionReference.doc(uid).get();
      return UserClass.fromMap(userData.data);
    } catch (e) {
      return e;
    }
  }
}
