import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Message {
  static const sample_sender = User();
  static const sample_body = "Lorem ipsum dolor sit amet";

  final User sender;
  final String body;
  final Timestamp timestamp;

  const Message({
    this.sender = sample_sender,
    this.body = sample_body,
    required this.timestamp
  });
}

class User {
  static const sample_user = "Sample User";
  static const sample_profile = Image(image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'));

  final String username;
  final Image profile;

  const User({
    this.username = sample_user,
    this.profile = sample_profile
  });
}

class Channel {
  static const sample_channel_name = "Sample Channel";
  static List<Message> sample_message_feed = [
    Message(timestamp: Timestamp.fromDate(DateTime(2023, 1, 1, 0))),
    Message(timestamp: Timestamp.fromDate(DateTime(2023, 1, 1, 1))),
    Message(timestamp: Timestamp.fromDate(DateTime(2023, 1, 1, 2))),
    Message(timestamp: Timestamp.fromDate(DateTime(2023, 1, 1, 3))),
    Message(timestamp: Timestamp.fromDate(DateTime(2023, 1, 1, 4))),
  ];
  static List<Message> sample_pinned_message_list = [
    sample_message_feed[2]
  ];

  final String channel_name;
  late List<Message> message_feed;
  late List<Message> pinned_messages;

  Channel({
    this.channel_name = sample_channel_name,
    message_feed = const [],
    pinned_messages = const []
  }) {
    if (message_feed == []) {
      this.message_feed = sample_message_feed;
    } else {
      this.message_feed = message_feed;
    }

    if (pinned_messages == []) {
      this.pinned_messages = sample_pinned_message_list;
    } else {
      this.pinned_messages = pinned_messages;
    }
  }

}

User user1 = const User(
    username: "Sample User 01"
);
User user2 = const User(
    username: "Sample User 02"
);
User user3 = const User(
    username: "Sample User 03"
);


Channel channel1 = Channel(
    channel_name: "Sample Channel 01",
    message_feed: [
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1)),
          sender: user1,
          body: "Lorem ipsum"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 1)),
          sender: user2,
          body: "Lorem ipsum dolor"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 2)),
          sender: user1,
          body: "Lorem ipsum dolor sit"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 3)),
          sender: user3,
          body: "Lorem ipsum dolor sit amet"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 4)),
          sender: user2,
          body: "Lorem ipsum"
      ),
    ],
    pinned_messages: [
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 3)),
          sender: user3,
          body: "Lorem ipsum dolor sit amet"
      )
    ]
);
Channel channel2 = Channel(
    channel_name: "Sample Channel 02",
    message_feed: [
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1)),
          sender: user1,
          body: "Lorem ipsum"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 1)),
          sender: user2,
          body: "Lorem ipsum dolor"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 4)),
          sender: user2,
          body: "Lorem ipsum"
      ),
    ],
    pinned_messages: [
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 4)),
          sender: user2,
          body: "Lorem ipsum"
      )
    ]
);
Channel channel3 = Channel(
    channel_name: "Sample Channel 03",
    message_feed: [
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1)),
          sender: user1,
          body: "Lorem ipsum"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 1)),
          sender: user2,
          body: "Lorem ipsum dolor"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 2)),
          sender: user1,
          body: "Lorem ipsum dolor sit"
      ),
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 3)),
          sender: user3,
          body: "Lorem ipsum dolor sit amet"
      ),
    ],
    pinned_messages: [
      Message(
          timestamp: Timestamp.fromDate(DateTime(2023, 2, 22, 1, 2)),
          sender: user1,
          body: "Lorem ipsum dolor sit"
      )
    ]
);
