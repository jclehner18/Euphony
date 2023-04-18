import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:euphony/group-parsing.dart';
import 'package:euphony/message-parsing.dart';



class GroupChannelState extends ChangeNotifier {
  var current_user = FirebaseAuth.instance.currentUser!;

  var num_groups = 2;
  var current_group = 0;
  var current_channel = 0;
  List<Map<String, dynamic>> group_list = [
    {"groupID": " "},
    {"groupID": " "},
  ];
  var channel_list = [];
  List<Message> message_list = [];
  List<Message> pinned_list = [];


  Future<void> select_group(int index) async {
    current_group = index;

    //init_channels_list();

    //notifyListeners();
  }

  Future<void> select_channel(int index) async {
    print("Selecting channel ${channel_list[current_channel]["name"]}");
    current_channel = index;
    message_list.clear();

    //init_message_list();

    // notifyListeners();
    print("Completed selecting channel");
  }

  Future<void> init_groups_list() async {
    print("Running AppState.init_groups_list");
    String uid = current_user.uid;

    group_list = await groupList(uid);

    print(group_list.length);

    //group_list = ["Sample 1", "Sample 2"];
    print('$group_list');
    select_group(current_group);

    print("Completed AppState.init_groups_list");

    //notifyListeners();
  }

  Future<void> init_channels_list() async {
    print("Running AppState.init_channels_list");

    channel_list.clear();
    channel_list = await channelList(group_list[current_group]["groupID"]);
    select_channel(current_channel);

    print("Completed AppState.init_channels_list");
  }

  Future<void> init_message_list() async {
    print("Running AppState.init_message_list");

    var retrieved_list = await messageList(
        group_list[current_group]["groupID"],
        channel_list[current_channel]["channelID"]
    );

    for (var messageDoc in retrieved_list) {
      Message message = Message(
          body: messageDoc["messageBody"],
          senderID: messageDoc["uID"],
          timestamp: messageDoc["time"]
      );
      message_list.add(message);
      if (messageDoc["isPin"]) {
        pinned_list.add(message);
      }
    }

    print("Completed AppState.init_message_list");
  }

  Future<void> create_group(String newGroupName) async {
    print("Creating group $newGroupName");

    newGroup(newGroupName, current_user.uid);
    await init_groups_list();
    current_group = group_list.length + 1;
    create_channel("General");

    print("Finished creating group $newGroupName");
  }

  Future<void> create_channel(String newChannelName) async {
    // TODO: Remove print
    print("Created channel $newChannelName");

    newChannel(group_list[current_group]['groupID']!, 0, newChannelName);

    notifyListeners();
  }

  void send_message(String body) {
    print("Message sent:");
    print("> ${current_user.uid}");
    print("> $body");

    sendNewMsg(
      group_list[current_group]["groupID"],
      channel_list[current_channel]["channelID"],
      body,
      current_user.uid
    );
    select_channel(current_channel);
  }

  void toggle_pin(int index) {

    pinned_list.add(message_list[index]);

    notifyListeners();
  }

}

class Message {
  final String body;
  final String senderID;
  final Timestamp timestamp;

  Message({required this.body, required this.senderID, required this.timestamp});
}

class Channel {
  final String name;
  final String channelID;
  final List<Message> messages = [];

  Channel({required this.name, required this.channelID});
}

class Group {
  final String name;
  final String groupID;
  final List users = [];
  final List<Channel> channels = [];

  Group({required this.name, required this.groupID});
}

