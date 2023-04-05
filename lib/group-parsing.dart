import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


void newGroup(String name, String uID)
{
  final newGrou ={
    "name": name,
    "owner": uID
  };

  db
      .collection('Groups')
      .doc()
      .set(newGrou)
      .onError((e, _) => print("Error writing document $e"));

  FirebaseFirestore.instance.collection('Groups').doc().collection('Channels');
}

void newChannel(int type, String group)
{
  final newChan ={
    "type": type
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
        return groupChannelList;
      },
      onError: (e) => print("Error completing: $e"),
  );
  throw "awe hell";
}