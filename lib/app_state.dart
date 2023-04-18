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
  List<Group> group_list = [];
  // var channel_list = [];
  // List<Message> message_list = [];
  // List<Message> pinned_list = [];


  Future<void> select_group(int index) async {
    current_group = index;

    //init_channels_list();

    //notifyListeners();
  }

  Future<void> select_channel(int index) async {
    // print("Selecting channel ${channel_list[current_channel]["name"]}");
    current_channel = index;
    // message_list.clear();

    //init_message_list();

    // notifyListeners();
    print("Completed selecting channel");
  }

  Future<void> initGroupsList() async {
    var dbList = await groupList(current_user.uid);

    print("Fetched ${group_list.length} groups");

    group_list.clear();

    for (var group in dbList) {
      group_list.add(Group(
          name: group['name'],
          groupID: group['groupID']
      ));
    }

    await initChannelsList();
    // notifyListeners();
  }

  Future<void> initChannelsList() async {

    for (var group in group_list) {
      var dbList = await channelList(group.groupID);

      group.channel_list.clear();
      for (var channel in dbList) {
        group.channel_list.add(Channel(
         name: channel['name'],
         channelID: channel['channelID']
        ));
      }
    }
    initMessageList();
    // notifyListeners();
    /*
    var db_list = await channelList(group_list[current_group].groupID);
    channel_list.clear();
    for (var channel in db_list) {
      channel_list.add(Channel(name: channel['name'], channelID: channel['channelID']));
    }
    */
  }

  Future<void> initMessageList() async {
    print("Running AppState.init_message_list");

    /*
    var retrievedList = await messageList(
        group_list[current_group].groupID,
        group_list[current_group].channel_list[current_channel].channelID
    );

    for (var messageDoc in retrievedList) {
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
    */

    for (var group in group_list) {
      for (var channel in group.channel_list) {
        var retrievedList = await messageList(group.groupID, channel.channelID);

        channel.messages.clear();
        channel.pinned_messages.clear();
        for (var messageDoc in retrievedList) {
          Message message = Message(
              body: messageDoc['messageBody'],
              senderID: messageDoc['uID'],
              timestamp: messageDoc['time']
          );
          channel.messages.add(message);
          if (messageDoc['isPin']) channel.pinned_messages.add(message);
        }
      }
    }

    notifyListeners();
  }

  Future<void> createGroup(String newGroupName) async {
    Group new_group = await newGroup(newGroupName, current_user.uid);
    group_list.add(new_group);
    createChannel(new_group.groupID, "General");
    current_group = group_list.length - 1;
    notifyListeners();
  }

  Future<void> createChannel(String groupID, String newChannelName) async {
    Channel new_channel = await newChannel(groupID, 0, newChannelName);
    group_list[current_group].channel_list.add(new_channel);
    current_channel = group_list[current_group].channel_list.length - 1;
    notifyListeners();
  }

  void send_message(String body) {
    print("Message sent:");
    print("> ${current_user.uid}");
    print("> $body");

    sendNewMsg(
      group_list[current_group].groupID,
      group_list[current_group].channel_list[current_channel].channelID,
      body,
      current_user.uid
    );
    select_channel(current_channel);

    notifyListeners();
  }

  void toggle_pin(int index) {

    // pinned_list.add(message_list[index]);

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
  final List<Message> pinned_messages = [];

  Channel({required this.name, required this.channelID});
}

class Group {
  final String name;
  final String groupID;
  final List users = [];
  final List<Channel> channel_list = [];

  Group({required this.name, required this.groupID});
}

