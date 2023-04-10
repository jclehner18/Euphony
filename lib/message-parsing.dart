import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


//this will grab a specific message from the database, to return it.
Future<String> getDoc(String group, String channel, String message) async
{
  var data;
  final docRef = db.collection('Groups').doc(group).collection('Channel').doc(channel).collection('Messages').doc(message);
  await docRef.get().then(
        (DocumentSnapshot doc) {
      data = doc.data() as Map<String, dynamic>;
      print(data);
      var returnMessage = data?['messageBody'];

      print(returnMessage);
      return returnMessage;
    },
    onError: (e) => print("Error getting document: $e"),
  );
  throw 'awe hell';
}



//this fxn is to listen for new messages being put into the database for the certain channel, then retrieve them
Future<String> listenForMessage(String group, String channel) async
{
  var returnMessage;
  var channelPoint = db.collection('Groups').doc('$group').collection('Channel').doc('$channel').collection('Messages');
  await channelPoint.doc().snapshots().listen((docSnapshot) {
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      returnMessage = data['messageBody'];
      return returnMessage;
    }
  });
  throw 'awe hell';
}

//this will pull all the messages from a channel
Future<List> messageList(String group, String channel) async
{
  List<Map<String,dynamic>> channelMessageList = [];
  await db.collection("Groups").doc(group).collection("Channels").doc(channel).collection("Messages").get().then(
        (querySnapshot) {
      print("successfully completed");
      for (var docSnapshot in querySnapshot.docs){
        print('${docSnapshot.id} => ${docSnapshot.data()}');
        channelMessageList.add(docSnapshot.data());

      }
      return channelMessageList;
    },
    onError: (e) => print("Error completing: $e"),
  );
  throw "awe hell";
}

//this will grab multiple documents, such as when searching through messages
getMsgDoc(String group,String channel, msg, compare)
{
  db.collection('Groups').doc('$group').collection('Channel').doc('$channel').collection('Messages').where(msg.contains(compare)).get().then(
      (res) => print("Success"),
      onError: (e) => print ("Error getting messages: $e"),
  );
}

//this fxn will update the pin status of a message
void pinMsg(String group, String channel, String message, bool pin)
{
  db
    .collection('Groups')
    .doc(group)
    .collection('Channel')
    .doc(channel)
    .collection('Messages')
    .doc(message)
    .update({
    "isPin": pin
    })
    .onError((e, _) => print ("Error pinning document: $e"));
}

Future<List> getPinnedMessages(String group, String channel) async{
  List<Map<String,dynamic>> pinMessageList = [];
  await db.collection("Groups").doc(group).collection("Channels").doc(channel).collection("Messages").where("isPin",isEqualTo: true).get().then(
        (querySnapshot) {
      print("successfully completed");
      for (var docSnapshot in querySnapshot.docs){
        print('${docSnapshot.id} => ${docSnapshot.data()}');
        pinMessageList.add(docSnapshot.data());

      }
      return pinMessageList;
    },
    onError: (e) => print("Error completing: $e"),
  );
  throw "awe hell";
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