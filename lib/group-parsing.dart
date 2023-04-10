import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


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

Future <List> groupList(String uid) async
{
  List<Map<String, dynamic>> userGroupList = [];


  await db.collection("Users").doc(uid).collection("Group List").get().then(
        (querySnapshot) {
      print("Successfully completed");

      for (var docSnapshot in querySnapshot.docs) {
        print('${docSnapshot.id} => ${docSnapshot.data()}');
        userGroupList.add(docSnapshot.data());
      }
      return userGroupList;
    },
    onError: (e) => print("Error completing: $e"),
  );

  throw "awe hell";
}

Future<List> channelList(String group) async
{
  List<Map<String,dynamic>> groupChannelList = [];
  await db.collection("Groups").doc(group).collection("Channels").get().then(
      (querySnapshot) {
        print("successfully completed");
        for (var docSnapshot in querySnapshot.docs){
          print('${docSnapshot.id} => ${docSnapshot.data()}');
          groupChannelList.add(docSnapshot.data());

        }
        return groupChannelList;
      },
      onError: (e) => print("Error completing: $e"),
  );
  throw "awe hell";
}