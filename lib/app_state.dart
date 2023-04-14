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
  List<Map<String, dynamic>> group_list = [
    {"groupID": " "},
    {"groupID": " "},
  ];
  var channel_list = [];
  var message_list = [];
  var pinned_list = [];


  Future<void> select_group(int index) async {
    current_group = index;
    channel_list.clear();

    channel_list = await channelList(group_list[current_group]['groupID']!);
  }

  void select_channel(int index) {
    current_channel = index;

    // TODO: Retrieve messages from db. Store them in the message_list variable.

    notifyListeners();
  }

  Future<void> init_groups_list() async {
    print("-- Fetching groups list");
    group_list.clear();
    String uid = current_user!.uid;

    group_list = await groupList(uid);

    print(group_list.length);

    //group_list = ["Sample 1", "Sample 2"];
    print('$group_list');
    select_group(current_group);

    print("Done fetching groups list");

    //notifyListeners();
  }

  Future<void> create_group(String newGroupName) async {
    // TODO: Remove print
    print("Created group $newGroupName");

    newGroup(newGroupName, current_user!.uid);
    await init_groups_list();
    select_group(group_list.length - 1);
    newChannel(group_list[current_group]['groupID'], 0, "Announcements");
    newChannel(group_list[current_group]['groupID'], 0, "General");

    notifyListeners();
  }

  void create_channel(String newChannelName) {
    // TODO: Remove print
    print("Created channel $newChannelName");

    newChannel(group_list[current_group]['groupID']!, 0, newChannelName);

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


