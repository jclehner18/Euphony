
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Future<void> userSetup(String displayName) async {
//   CollectionReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection('Userstest');
//   FirebaseAuth auth = FirebaseAuth.instance;
//   String uid = auth.currentUser!.uid.toString();
//   String email = auth.currentUser!.email.toString();
//   users.add({'displayName' : displayName, 'uid' : uid, 'email' : email});
//   return;
// }

Future<void> userSetup(String displayName) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String email = auth.currentUser!.email.toString();
  String uid = auth.currentUser!.uid.toString();
  FirebaseFirestore.instance.collection('Users').doc(email).set(
    {"email" : email, "username" : displayName, "uid" : uid}
  );
}


