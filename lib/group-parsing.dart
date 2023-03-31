import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


void newGroup(collect, String name, String uID)
{
  final newGrou ={
    "name": name,
    "owner": uID
  };

  db
      .collection(collect)
      .doc()
      .set(newGrou)
      .onError((e, _) => print("Error writing document $e"));

  FirebaseFirestore.instance.collection('Groups').doc().collection('Channels');
}

void newChannel(collect, int type, String grou)
{
  final newChan ={
    "type": type
  };

  db
      .collection(collect)
      .doc()
      .collection('Channels')
      .doc()
      .set(newChan)
      .onError((e, _) => print("Error writing document $e"));
}