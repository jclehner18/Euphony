import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:euphony/group-parsing.dart';



class GroupChannelState extends ChangeNotifier {
  var current_user = FirebaseAuth.instance.currentUser;

  var num_groups = 2;
  var current_group = 0;
  var current_channel = 0;
  var group_list = [];
  var channel_list = [];
  var message_list = [];
  var pinned_list = [];


  void select_group(int index) {
    current_group = index;
    channel_list.clear();

    //List retrievedChannelList = channelList(group_list[current_group]);

    //for (var i = 0; i < retrievedChannelList.length; i++) {
    //  channel_list.add(retrievedChannelList[i]);
    //}

    notifyListeners();
  }

  void select_channel(int index) {
    current_channel = index;

    // TODO: Retrieve messages from db. Store them in the message_list variable.

    notifyListeners();
  }

  Future<void> init_groups_list() async {
    group_list.clear();
    String uid = current_user!.uid;

    var retrievedGroupList = await groupList(uid);

    print(retrievedGroupList.length);

    for (var i = 0; i < retrievedGroupList.length; i++) {
      group_list.add(retrievedGroupList[i]['groupID']);
      print('${retrievedGroupList[i]['groupID']}');
    }

    group_list = ["", ""];
    channel_list = ["Sample 1", "Sample 2"];

  }

  void create_group(String newGroupName) {
    // TODO: Remove print
    print("Created group $newGroupName");

    newGroup(newGroupName, current_user!.uid);

    notifyListeners();
  }

  void create_channel(String newChannelName) {
    // TODO: Remove print
    print("Created channel $newChannelName");

    newChannel(0, group_list[current_group], newChannelName);

    notifyListeners();
  }

  void send_message(String body) {
    var ts = Timestamp.now().toDate();
    var timestamp = "Today at ${ts.hour % 12}:${ts.minute}";

    // TODO: Remove print
    print("Message sent:");
    print("> $current_user");
    print("> $timestamp");
    print("> $body");

    // TODO: Connect to db
  }

  void toggle_pin(int index) {

    pinned_list.add(message_list[index]);

    notifyListeners();
  }

}


