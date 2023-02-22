import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


//this will grab a document from the firestore database. Could be used for clicking on user profile to obtain their info for a profile page
getDoc(collect, docu)
{
  final docRef = db.collection(collect).doc(docu);
  docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
      },
      onError: (e) => print("Error getting document: $e"),
  );
}


//this will grab multiple documents, such as when searching through messages
getMsgDoc(collect, msg, compare)
{
  db.collection(collect).where(msg.contains(compare)).get().then(
      (res) => print("Success"),
      onError: (e) => print ("Error getting messages: $e"),
  );
}

grabNewMsg(collect,msg)
{
  final newMsg = db.collection(collect).doc(msg);
  newMsg.snapshots().listen(
        (event) => print("current data: ${event.data()}"),
    onError: (error) => print("Listen failed: $error"),
  );
}