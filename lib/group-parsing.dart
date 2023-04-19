import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_state.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//creates a new group giving itself a name and group id, as well as add it to the creator's group list
//CONFIRM WORKS
Future<Group> newGroup(String name, String uID) async {
  final newGroup = db.collection('Groups').doc();

  await newGroup.set({
    "name":name,
    "owner":uID,
    "groupID":newGroup.id
  });

  await db
    .collection('Users')
    .doc(uID)
    .collection("Group List")
    .doc()
    .set({
    "groupID": newGroup.id
  }).onError((e, _) => print("Error adding document to user group list: $e"));

  return Group(name: name, groupID: newGroup.id);

}


//creates a new channel given a group, a type and a name for the channel
//CONFIRM WORKS
Future<Channel> newChannel(String group, int type, String channelName) async {
  final newChannel = db.collection("Groups").doc(group).collection("Channels").doc();

  await newChannel.set({
    "name": channelName,
    "type": type,
    "channelID": newChannel.id
  });

  return Channel(name: channelName, channelID: newChannel.id);

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

  for (var docSnapshot in query.docs) {
    var groupDocID = docSnapshot.data()["groupID"];
    var groupDoc = await db.collection("Groups").doc(groupDocID).get();

    print('Found group ${groupDocID}');
    print('Here is its data: ${groupDoc.data()}');

    userGroupList.add(groupDoc.data()!);
  }

  print('Found ${userGroupList.length} groups!');
  return userGroupList;
}


//generates a list of channels from a group
//CONFIRM WORKS
Future<List<Map<String, dynamic>>> channelList(String group) async {
  List<Map<String,dynamic>> groupChannelList = [];
  var query = await db.collection("Groups").doc(group).collection("Channels").get();

  for (var docSnapshot in query.docs){
    print("Found channel with ID ${docSnapshot.id}");
    print("Here is its data: ${docSnapshot.data()}");
    groupChannelList.add(docSnapshot.data());
  }

  print("Found ${groupChannelList.length} channels.");
  return groupChannelList;
}


//generates a list of events from a channel
//CONFRIM WORKS
Future<List<Map<String, dynamic>>> eventList(String group, String channel) async {
  List<Map<String,dynamic>> channelEventList = [];
  var query = await db.collection("Groups").doc(group).collection("Channels").doc(channel).collection("Events").get();
  for (var docSnapshot in query.docs){
    print('${docSnapshot.id} => ${docSnapshot.data()}');
    channelEventList.add(docSnapshot.data());
  }
  return channelEventList;
}

