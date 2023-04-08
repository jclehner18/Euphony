import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


void newGroup(String name, String uID)
{
  final newGroup ={
    "name": name,
    "owner": uID
  };

  final newGroupID = db
      .collection('Groups')
      .doc()
      .set(
        newGroup
  )
      .onError((e, _) => print("Error writing document $e"));

  FirebaseFirestore.instance.collection('Groups').doc().collection('Channels');

  db
    .collection('Users')
    .doc(uID)
    .collection("Group List")
    .doc()
    .set({
    "groupID": newGroupID
  }).onError((e, _) => print("Error adding document to user group list: $e"));


}



void newChannel(int type, String group, String channelName)
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

List groupList(String uid)
{
  List<Map<String, dynamic>> userGroupList = [];
  db.collection("Users").doc(uid).collection("Group List").get().then(
        (querySnapshot) {
      print("Successfully completed");

      for (var docSnapshot in querySnapshot.docs) {
        print('${docSnapshot.id} => ${docSnapshot.data()}');
        userGroupList.add(docSnapshot.data());
      }
    },
    onError: (e) => print("Error completing: $e"),
  );
  return userGroupList;

  throw "awe hell";
}

List channelList(String group)
{
  List<Map<String,dynamic>> groupChannelList = [];
  db.collection("Groups").doc(group).collection("Channels").get().then(
      (querySnapshot) {
        print("successfully completed");
        for (var docSnapshot in querySnapshot.docs){
          print('${docSnapshot.id} => ${docSnapshot.data()}');
          groupChannelList.add(docSnapshot.data());

        }
      },
      onError: (e) => print("Error completing: $e"),
  );
  return groupChannelList;

  throw "awe hell";
}