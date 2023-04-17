import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


//this will grab a specific message from the database, to return it.
//IRRELEVANT FOR ACTUAL USE. USED FOR TESTING READING
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
//CONFIRM WORKS
Future<List<Map<String, dynamic>>> messageList(String group, String channel) async {
  print("Fetching messages from database...");

  List<Map<String,dynamic>> channelMessageList = [];
  var query = await db
      .collection("Groups").doc(group)
      .collection("Channels").doc(channel)
      .collection("Messages")
      .orderBy("time")
      .get();

  for (var docSnapshot in query.docs){
    print('Found message ${docSnapshot.id} with contents ${docSnapshot.data()['messageBody']}');
    channelMessageList.add(docSnapshot.data());
  }

  print("Retrieved messages from database.");
  return channelMessageList;
}

//this will grab multiple documents, such as when searching through messages
//NEEDS WORK
//
//CANNOT COMPLETE THIS WITHOUT THIRD PARTY SEARCH
/*Future<List<Map<String, dynamic>>> searchMessages(String group,String channel, msg, compare) async {




  List<Map<String,dynamic>> searchList = [];
  var query = await db.collection('Groups').doc(group).collection('Channels').doc(channel).collection('Messages').get();
  for (var docSnapshot in query.docs){
    print('${docSnapshot.id} => ${docSnapshot.data()}');

    searchList.add(docSnapshot.data());
  }
  for(var i in searchList){

  }
  return searchList;
}*/

//this fxn will update the pin status of a message
//CONFIRM WORKS
Future<void> pinMsg(String group, String channel, String message, bool pin) async
{
  final msgToPin = db
      .collection('Groups')
      .doc(group)
      .collection('Channels')
      .doc(channel)
      .collection('Messages')
      .doc(message);
  await msgToPin
    .update({"isPin": true})
    .onError((e, _) => print ("Error pinning document: $e"));
}

//this fxn will grab a list of all pinned messages
//CONFIRM WORKS
Future<List<Map<String, dynamic>>> getPinnedMessages(String group, String channel) async {
  List<Map<String,dynamic>> pinMessageList = [];
  var query = await db.collection("Groups").doc(group).collection("Channels").doc(channel).collection("Messages").where("isPin",isEqualTo: true).get();
  for (var docSnapshot in query.docs){
    print('${docSnapshot.id} => ${docSnapshot.data()}');
    pinMessageList.add(docSnapshot.data());

  }
  return pinMessageList;
}

//this is used to send new messages into the database using the current channel collection that we are in
//CONFIRM WORKS
sendNewMsg(String group, String channel, String msg, String uID)
{

  final newMsg ={
    "messageBody": msg,
    "time": FieldValue.serverTimestamp(),
    "uID": uID,
    "isPin": false
  };

  db
    .collection('Groups')
    .doc(group)
    .collection('Channels')
    .doc(channel)
    .collection('Messages')
    .doc()
    .set(newMsg)
    .onError((e, _) => print("Error writing document $e"));
}