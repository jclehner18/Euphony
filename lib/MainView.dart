import 'package:euphony/Login1.dart';
import 'package:euphony/SettingsPage.dart';
import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:euphony/message-parsing.dart';
import 'package:euphony/group-parsing.dart';
import 'package:euphony/app_state.dart';
import 'package:euphony/calendar.dart';


// DEFINE CONSTANTS
int NARROW_SCREEN_WIDTH = 600;


class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}
class _MainViewState extends State<MainView> {

  String _newChannelName = '';
  String _newGroupName = '';

  // List<Group> group_list = [];
  // int current_group = 0;
  // List<Channel> channel_list = [];
  // int current_channel = 0;

  User current_user = FirebaseAuth.instance.currentUser!;

  Future<void> _onPressNewChannel() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Channel'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter channel name'),
            onChanged: (value) {
              _newChannelName = value;
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _newChannelName = '';
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                print(_newChannelName);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onPressNewGroup() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Group'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter group name'),
            onChanged: (value) {
              _newGroupName = value;
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _newGroupName = '';
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () async {
                print(_newGroupName);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /*
  Future<void> _initGroupsList() async {
    var db_list = await groupList(current_user.uid);

    print("Fetched ${group_list.length} groups");

    group_list.clear();

    for (var group in db_list) {
      group_list.add(Group(
        name: group['name'],
        groupID: group['groupID']
      ));
    }

    await _initChannelsList();

    print('$group_list');
  }
  */
  /*
  Future<void> _initChannelsList() async {
    /*
    for (var group in group_list) {
      var db_list = await channelList(group.groupID);

      // for (var channel in db_list) {
      //  group.channels.add(Channel(
      //    name: channel['name'],
      //    channelID: channel['channelID']
      //  ));
      // }

      print("Added to group ${group.name} the following channels: ${group.channels}");

    }
    */

    var db_list = await channelList(group_list[current_group].groupID);
    channel_list.clear();
    for (var channel in db_list) {
      channel_list.add(Channel(name: channel['name'], channelID: channel['channelID']));
    }
  }
  */
  /*
  Future<void> _createGroup(String newGroupName) async {
    Group new_group = await newGroup(newGroupName, current_user.uid);
    group_list.add(new_group);
    _createChannel(new_group.groupID, "General");
    setState(
      () {
        current_group = group_list.length - 1;
      }
    );
  }
  */
  /*
  Future<void> _createChannel(String groupID, String newChannelName) async {
    Channel new_channel = await newChannel(groupID, 0, newChannelName);
    setState(() {
      group_list[current_group].channels.add(new_channel);
      current_channel = group_list[current_group].channels.length - 1;
    });
  }
  */

  @override
  void initState() {
    // _initGroupsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GroupChannelState appState = Provider.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool wide_display = (constraints.maxWidth >= NARROW_SCREEN_WIDTH);
        if (wide_display) {
          return Scaffold(
            appBar: AppBar(
                title: Text("Welcome to Euphony, ${current_user.displayName}"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        /*
                    print("Opened Settings Page);
                    */
                        Navigator.push(context, MaterialPageRoute(builder: ((context) => settingsPage())));
                      },
                      child: const Icon(Icons.settings)
                  ),
                  ElevatedButton(
                      onPressed: () {
                        /*
                    print("Logged Out");
                    */
                        FirebaseAuth.instance.signOut().then((value) {
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => LoginPage())));
                        });
                      },
                      child: const Icon(Icons.logout_outlined)
                  ),
                  
                ]
            ),
            body: Row(
              children: [
                SafeArea(
                  child: buildNavigationRails(context, wide_display),
                ),
                Expanded(
                  child: ChannelPane(
                    groupID: appState.group_list[appState.current_group].groupID,
                    channelID: appState
                      .group_list[appState.current_group]
                      .channel_list[appState.current_channel]
                      .channelID
                  )
                )
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Euphony"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      /*
                  print("Opened Settings Page);
                  */
                    },
                    child: const Icon(Icons.settings)
                ),
                ElevatedButton(
                    onPressed: () {
                      /*
                  print("Logged Out");
                  */
                    },
                    child: const Icon(Icons.logout_outlined)
                ),
              ]
            ),
            body: ChannelPane(
              groupID: appState
                .group_list[appState.current_group]
                .groupID,
              channelID: appState
                .group_list[appState.current_group]
                .channel_list[appState.current_channel]
                .channelID
            ),
            drawer: Drawer(
              child: buildNavigationRails(context, wide_display),
            )
          );
        }
      }
    );
  }

  Widget buildNavigationRails(BuildContext context, bool wide_display) {
    GroupChannelState appState = Provider.of(context);
    // appState.init_groups_list();
    // appState.init_channels_list();

    return Builder(
      builder: (BuildContext context) {
        return Row(
            children: [
              SizedBox(
                  width: (wide_display ? 100 : 60),
                  child: Builder(
                    // future: appState.initGroupsList(),
                    builder: (BuildContext context) {
                      //if (snapshot.connectionState == ConnectionState.done) {
                        if (appState.group_list.length >= 2) {
                          return NavigationRail(
                            extended: false,
                            destinations: [
                              for (var group in appState.group_list)
                                NavigationRailDestination(
                                    icon: Icon(Icons.group_work),
                                    label: Text(group.name)
                                )
                            ],
                            selectedIndex: appState.current_group,
                            onDestinationSelected: (value) {
                              setState(() {
                                appState.current_group = value;
                              });
                            },
                            trailing: ElevatedButton(
                                onPressed: () async {
                                  await _onPressNewGroup();
                                  if (_newGroupName != '') appState.createGroup(_newGroupName);
                                  _newGroupName = '';
                                },
                                child: Icon(Icons.add)
                            ),
                          );
                        } else {
                          return Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text("It looks like you're not a member of any groups! Click the '+' or wait to be added to a group."),
                                SizedBox(height: 16),
                                ElevatedButton(
                                    onPressed: () async {
                                      await _onPressNewGroup();
                                      if (_newGroupName != '') appState.createGroup(_newGroupName);
                                      _newGroupName = '';
                                    },
                                    child: Icon(Icons.add)
                                )
                              ],
                            )
                          );
                        }
                      //} else {
                        // return CircularProgressIndicator();
                      //}
                    }
                  )
              ),
              DefaultTabController(
                length: 2,
                child: SizedBox(
                  width: (wide_display ? 220 : 90),
                  child: Column(
                    children: [
                      SizedBox(
                        height: (wide_display ? null : 50),
                        child: TabBar(
                            labelColor: Theme
                                .of(context)
                                .focusColor,
                            tabs: [
                              Tab(
                                  icon: Icon(Icons.list),
                                  text: (wide_display
                                      ? "Channels"
                                      : null)
                              ),
                              Tab(
                                  icon: Icon(Icons.people),
                                  text: (wide_display
                                      ? "Members"
                                      : null)
                              )
                            ]
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (BuildContext context) {
                            // print("Rebuilding channels pane");
                            // print("Building channel nav rail: ${appState.channel_list}");
                            if (appState.group_list[appState.current_group].channel_list.length >= 2) {
                                return TabBarView(
                                  children: [
                                    NavigationRail(
                                      extended: wide_display,
                                      destinations: [
                                        for (var channel in appState.group_list[appState.current_group].channel_list)
                                          NavigationRailDestination(
                                              padding: EdgeInsets.all(2),
                                              icon: Icon(Icons.tag),
                                              label: Text(channel.name)
                                          )
                                      ],
                                      selectedIndex: appState.current_channel,
                                      onDestinationSelected: (value) async {
                                        setState(() {
                                          appState.current_channel = value;
                                        });
                                      },
                                      trailing: ElevatedButton(
                                        onPressed: () async {
                                          await _onPressNewChannel();
                                          if (_newChannelName != '') {
                                            appState.createChannel(appState.group_list[appState.current_group].groupID, _newChannelName);
                                          }
                                          _newChannelName = '';
                                        },
                                        child: Text("New Channel")
                                      )
                                    ),
                                    ListView.builder(
                                      itemCount: 3,
                                      itemBuilder: (context, value) {
                                        return GroupMemberCard();
                                        // TODO: Get members from db
                                      },
                                    )
                                  ]
                                );
                              } else {
                                return Container(
                                  alignment: Alignment.topCenter,
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Text("Looks like there's nothing here! Click 'Create Channel' to get started."),
                                      SizedBox(
                                        height: 16
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await _onPressNewChannel();
                                          if (_newChannelName != '') {
                                            appState.createChannel(appState.group_list[appState.current_group].groupID, _newChannelName);
                                          }
                                          _newChannelName = '';
                                        },
                                        child: Text("New Channel")
                                      )
                                    ],
                                  )
                                );
                              }
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]
        );
      }
    );

    throw UnimplementedError();
  }
}



class ChannelPane extends StatefulWidget {
  ChannelPane({super.key, required this.channelID, required this.groupID});
  String channelID;
  String groupID;

  @override
  State<ChannelPane> createState() => _ChannelPaneState();
}
class _ChannelPaneState extends State<ChannelPane> with TickerProviderStateMixin {
  late TabController _tab_controller;
  late TextEditingController _message_body_controller;

  List<Message> message_list = [];
  List<Message> pinned_message_list = [];

  /*
  Future<void> _init_message_list() async {
    var db_list = await messageList(widget.groupID, widget.channelID);

    message_list.clear();
    for (var messageDoc in db_list) {
      Message message = Message(
          body: messageDoc["messageBody"],
          timestamp: messageDoc["time"],
          senderID: messageDoc["uID"]
      );
      message_list.add(message);
      if (messageDoc["isPin"]) {
        pinned_message_list.add(message);
      }
    }
  }
  */
  /*
  Future<void> _toggle_pin(int index) async {

  }
  */

  _send_message(String message) {
    print("Sending message $message");
    _message_body_controller.clear();
  }


  @override
  void initState() {
    _tab_controller = TabController(length: 3, vsync: this);
    _message_body_controller = TextEditingController();
    // _init_message_list();
    super.initState();
  }

  @override
  void dispose() {
    _message_body_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GroupChannelState appState = Provider.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Column(
            children: [
              TabBar(
                  labelColor: Theme.of(context).focusColor,
                  controller: _tab_controller,
                  tabs: const <Tab>[
                    Tab(
                      icon: Icon(Icons.forum),
                      text: "Messages",
                    ),
                    Tab(
                      icon: Icon(Icons.calendar_month),
                      text: "Calendar",
                    ),
                    Tab(
                      icon: Icon(Icons.push_pin),
                      text: "Pins",
                    )
                  ]
              ),
              Expanded(
                child: TabBarView(
                  controller: _tab_controller,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (BuildContext context) {
                                return ListView.builder(
                                  itemCount: appState
                                    .group_list[appState.current_group]
                                    .channel_list[appState.current_channel]
                                    .messages.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    var message = appState
                                      .group_list[appState.current_group]
                                      .channel_list[appState.current_channel]
                                      .messages[index];
                                    return _ContextMenuRegion(
                                      contextMenuBuilder: (context, offset) {
                                        return AdaptiveTextSelectionToolbar.buttonItems(
                                          anchors: TextSelectionToolbarAnchors(
                                            primaryAnchor: offset,
                                          ),
                                          buttonItems: [
                                            ContextMenuButtonItem(
                                              onPressed: () {
                                                appState.toggle_pin(index);
                                                ContextMenuController.removeAny();
                                              },
                                              label: pinned_message_list.contains(message) ? "Unpin" : "Pin"
                                            )
                                          ],
                                        );
                                      },
                                      child: MessageCard(
                                        messageBody: message.body,
                                        messageTimestamp: message.timestamp.toString(),
                                        messageSender: message.senderID,
                                      )
                                    );
                                  }
                                );
                              }
                            )
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: TextField(
                                      controller: _message_body_controller,
                                      onSubmitted: (value) {
                                        appState.send_message(value);
                                        _send_message(value);
                                      }
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    /*
                                  print("Sent Message");
                                  */
                                    appState.send_message(_message_body_controller.text);
                                    _send_message(_message_body_controller.text);
                                  },
                                  child: const Icon(Icons.send),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      /*
                                  print("Attaching File to Message");
                                  */
                                    },
                                    child: const Icon(Icons.attach_file)
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: EuphonyCalendar()
                    ),
                    Container(
                      child: ListView.builder(
                        itemCount: appState
                            .group_list[appState.current_group]
                            .channel_list[appState.current_channel]
                            .pinned_messages
                            .length,
                        itemBuilder: (BuildContext context, int index) {
                          var message = appState
                              .group_list[appState.current_group]
                              .channel_list[appState.current_channel]
                              .pinned_messages[index];
                          return _ContextMenuRegion(
                              contextMenuBuilder: (context, offset) {
                                return AdaptiveTextSelectionToolbar.buttonItems(
                                  anchors: TextSelectionToolbarAnchors(
                                    primaryAnchor: offset,
                                  ),
                                  buttonItems: [
                                    ContextMenuButtonItem(
                                        onPressed: () {
                                          appState.toggle_pin(index);
                                          ContextMenuController.removeAny();
                                        },
                                        label: "Unpin"
                                    )
                                  ],
                                );
                              },
                              child: MessageCard(
                                messageBody: message.body,
                                messageSender: message.senderID,
                                messageTimestamp: message.timestamp.toString(),
                              )
                          );
                        }
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }
}



typedef ContextMenuBuilder = Widget Function(
  BuildContext context, Offset offset
);
class _ContextMenuRegion extends StatefulWidget {
  const _ContextMenuRegion({
    required this.contextMenuBuilder,
    required this.child
  });

  final ContextMenuBuilder contextMenuBuilder;

  final Widget child;

  @override
  State<_ContextMenuRegion> createState() => _ContextMenuRegionState();
}
class _ContextMenuRegionState extends State<_ContextMenuRegion> {
  Offset? _longPressOffset;

  final ContextMenuController _contextMenuController = ContextMenuController();

  static bool get _longPressEnabled {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return true;
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
        return false;
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.linux:
        return false;
      case TargetPlatform.windows:
        return false;
      default:
        throw UnimplementedError();
    }
  }

  void _onSecondaryTapUp(TapUpDetails details) {
    _show(details.globalPosition);
  }

  void _onTap() {
    if (!_contextMenuController.isShown) {
      return;
    }
    _hide();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _longPressOffset = details.globalPosition;
  }

  void _onLongPress() {
    assert(_longPressOffset != null);
    _show(_longPressOffset!);
    _longPressOffset = null;
  }

  void _show(Offset position) {
    _contextMenuController.show(
      context: context,
      contextMenuBuilder: (BuildContext context) {
        return widget.contextMenuBuilder(context, position);
      },
    );
  }

  void _hide() {
    _contextMenuController.remove();
  }

  //Begin overridden functions
  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapUp: _onSecondaryTapUp,
      onTap: _onTap,
      onLongPress: _longPressEnabled ? _onLongPress : null,
      onLongPressStart: _longPressEnabled ? _onLongPressStart : null,
      child: widget.child,
    );
  }
}
