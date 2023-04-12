import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//creates a new group giving itself a name and group id, as well as add it to the creator's group list
//CONFIRM WORKS
void newGroup(String name, String uID)
{

  final newGroup = db
      .collection('Groups')
      .doc();

  newGroup.set({
    "name":name,
    "owner":uID,
    "groupID":newGroup.id
  });

  FirebaseFirestore.instance.collection('Groups').doc().collection('Channels');

  db
    .collection('Users')
    .doc(uID)
    .collection("Group List")
    .doc()
    .set({
    "groupID": newGroup.id
  }).onError((e, _) => print("Error adding document to user group list: $e"));

}


//creates a new channel given a group, a type and a name for the channel
//CONFIRM WORKS
void newChannel(String group, int type, String channelName)
{
  final newChan ={
    "type": type,
    "name": channelName
  };

  db
      .collection('Groups')
      .doc(group)
      .collection('Channels')
      .doc()
      .set(newChan)
      .onError((e, _) => print("Error writing document $e"));
}

//this fxn will create a new event to be used in the calendar
//CONFIRM WORKS
void createEvent(String group, String channel, String eventName, Timestamp eventTime){

  db
    .collection('Groups').doc(group)
      .collection('Channels').doc(channel)
      .collection('Events').doc()
      .set({
    "name": eventName,
    "time": eventTime
  }).onError((e, _) => print("Error writing document $e"));
}

//this function will a user to the group
//CONFIRM WORKS
void addUserToGroup(String group, String newUser){
  db
    .collection('Groups').doc(group)
      .collection('Users').doc(newUser)
      .set({
      "uid": newUser
  }).onError((e, _) => print("Error writing document $e"));

  db
    .collection('Users').doc(newUser)
    .collection('Group List').doc(group)
    .set({
    "groupID": group
  }).onError((e, _) => print("Error writing document $e"));
}


//grabs a list of the groups that a user is in
//CONFIRM WORKS
Future <List<Map<String,dynamic>>> groupList(String uid) async
{
  List<Map<String, dynamic>> userGroupList = [];
  var query = await db.collection("Users").doc(uid).collection("Group List").get();
  print(query);
  await db.collection("Users").doc(uid).collection("Group List").get();


    for (var docSnapshot in query.docs) {
      print('${docSnapshot.id} => ${docSnapshot.data()}');
      userGroupList.add(docSnapshot.data());
    }

  return userGroupList;
}


//generates a list of channels from a group
//CONFIRM WORKS
Future<List<Map<String, dynamic>>> channelList(String group) async
{
  List<Map<String,dynamic>> groupChannelList = [];
  var query = await db.collection("Groups").doc(group).collection("Channels").get();

  for (var docSnapshot in query.docs){
    print('${docSnapshot.id} => ${docSnapshot.data()}');
    groupChannelList.add(docSnapshot.data());

  }
  return groupChannelList;
}


//generates a list of events from a channel
//CONFRIM WORKS
Future<List<Map<String, dynamic>>> eventList(String group, String channel) async{
  List<Map<String,dynamic>> channelEventList = [];
  var query = await db.collection("Groups").doc(group).collection("Channels").doc(channel).collection("Events").get();
  for (var docSnapshot in query.docs){
    print('${docSnapshot.id} => ${docSnapshot.data()}');
    channelEventList.add(docSnapshot.data());
  }
  return channelEventList;
}

