import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:euphony/reusable_widgets/reusable_widget.dart';



class GroupChannelState extends ChangeNotifier {
  var current_user = "dsurgenavic";

  var num_groups = 2;
  var current_group = 0;
  var current_channel = 0;
  var group_list = [];
  var channel_list = [];
  var message_list = [];
  var pinned_list = [];

  var current_message_list = [];
  var current_pinned_list = [];


  void select_group(int index) {
    select_channel(0);
    current_group = index;
    notifyListeners();
  }

  void select_channel(int index) {
    message_list[current_group][current_channel] = current_message_list;
    pinned_list[current_group][current_channel] = current_pinned_list;
    current_channel = index;
    current_message_list = message_list[current_group][current_channel];
    current_pinned_list = pinned_list[current_group][current_channel];
    notifyListeners();
  }

  void init_groups_list() {
    group_list.clear();
    //TODO: fetch groups from database
    for (var i = 0; i < num_groups; i++) {
      group_list.add("Sample Group");
    }
  }

  void init_channel_list() {
    for (var group in group_list) {
      channel_list.add([
        "Sample Channel 1",
        "Sample Channel 2",
        "Sample Channel 3"
      ]);
    }
  }

  void init_messages() {
    for (var i = 0; i < group_list.length; i ++) {
      message_list.add([]);
      pinned_list.add([]);
      for (var j = 0; j < channel_list.length; j++) {
        message_list[i].add([]);
        pinned_list[i].add([]);
      }
    }
  }

  void create_group(String newGroupName) {
    // TODO: Remove print
    print("Created group $newGroupName");
    notifyListeners();
  }

  void create_channel(String newChannelName) {
    // TODO: Remove print
    print("Created channel $newChannelName");
    notifyListeners();
  }

  void send_message(String body) {
    var ts = Timestamp.now().toDate();
    var timestamp = "Today at ${ts.hour % 12}:${ts.minute}";
    current_message_list.add(
        MessageCard(
          MessageSender: current_user,
          MessageTimestamp: timestamp,
          MessageBody: body,
        )
    );
    current_pinned_list.add(false);
  }

  void toggle_pin(int index) {
    current_pinned_list[index] = !current_pinned_list[index];
    notifyListeners();
  }

}


