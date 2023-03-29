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


  void select_group(int index) {
    current_group = index;
    select_channel(0);

    // TODO: Retrieve channels from db. Store them in the channel_list variable.

    notifyListeners();
  }

  void select_channel(int index) {
    current_channel = index;

    // TODO: Retrieve messages from db. Store them in the message_list variable.

    notifyListeners();
  }

  void init_groups_list() {
    group_list.clear();

    //TODO: fetch groups from database
    for (var i = 0; i < num_groups; i++) {
      group_list.add("Sample Group");
    }
    channel_list.add("Sample Channel");
    channel_list.add("Sample Channel");
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


