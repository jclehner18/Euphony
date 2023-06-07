import 'package:euphony/firebase_options.dart';
import 'package:euphony/group-parsing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euphony/message-parsing.dart';

import 'package:firebase_core/firebase_core.dart';
Future<void> main()async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore db = FirebaseFirestore.instance;

  String uid = "I7AaNZTdSZl8HIs1f8Xd";
  String groupID = "gEsXF5sWSU4BKZpBZXgq";
  String channelID = "ChxJtAf1CivPswlb21QQ";
  String msgID = "WNbWKadZMEjGoFLJ7DDZ";
  List<Map<String, dynamic>> testing=[];

  //testing = await searchMessages(groupID, channelID, 'Darius', compare);

  print(testing);

}