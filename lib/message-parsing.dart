import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


//this will grab a specific message from the database, to return it.
String getDoc(String group, String channel, String message)
{
  var data;
  final docRef = db.collection('Groups').doc(group).collection('Channel').doc(channel).collection('Messages').doc(message);
  docRef.get().then(
        (DocumentSnapshot doc) {
      data = doc.data() as Map<String, dynamic>;
      print(data);
      var returnMessage = data?['messageBody'];

      print(returnMessage);
      return returnMessage;
    },
    onError: (e) => print("Error getting document: $e"),
  );
  throw 'were fucked';
}



//this fxn is to listen for new messages being put into the database for the certain channel, then retrieve them
String listenForMessage(String group, String channel)
{
  var returnMessage;
  var channelPoint = db.collection('Groups').doc('$group').collection('Channel').doc('$channel').collection('Messages');
  channelPoint.doc().snapshots().listen((docSnapshot) {
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      returnMessage = data['messageBody'];
      return returnMessage;
    }
  });
  throw 'were fucked';
}

//this will grab multiple documents, such as when searching through messages
getMsgDoc(String group,String channel, msg, compare)
{
  db.collection('Groups').doc('$group').collection('Channel').doc('$channel').collection('Messages').where(msg.contains(compare)).get().then(
      (res) => print("Success"),
      onError: (e) => print ("Error getting messages: $e"),
  );
}

//this will grab a new message that has been sent to the database
grabNewMsg(collect,msg)
{
  final newMsg = db.collection(collect).doc(msg);
  newMsg.snapshots().listen(
        (event) => print("current data: ${event.data()}"),
    onError: (error) => print("Listen failed: $error"),
  );
}

//this is used to send new messages into the database using the current channel collection that we are in
sendNewMsg(String group,String channel, String msg, String uID)
{

  final newMsg ={
    "messageBody": msg,
    "time": FieldValue.serverTimestamp(),
    "uID": uID
  };

  db
    .collection('Groups')
    .doc(group)
    .collection('Channel')
    .doc(channel)
    .collection('Messages')
    .doc()
    .set(newMsg)
    .onError((e, _) => print("Error writing document $e"));
}