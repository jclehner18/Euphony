/*
Last updated 1 March, 2023 by Darius Surgenavic.
MainView.dart is the main screen users will interact with.
 It contains three primary widgets: a view for selecting the current active
 group, a view for selecting the current active channel, and a view for the
 contents of the current active channel.
*/

// ignore_for_file: non_constant_identifier_names, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
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

  String name = FirebaseAuth.instance.currentUser!.displayName.toString();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool wide_display = (constraints.maxWidth >= NARROW_SCREEN_WIDTH);
        if (wide_display) {
          return Scaffold(
            appBar: AppBar(
                title: const Text("Euphony"),
                actions: [
                  Align(alignment: Alignment.center, child: Text('Welcome $name', style: const TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
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
                    child: ChannelPane()
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
            body: ChannelPane(),
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
    appState.init_groups_list();
    appState.init_channels_list();

    return Builder(
      builder: (BuildContext context) {
        return Row(
            children: [
              SizedBox(
                  width: (wide_display ? 100 : 60),
                  child: FutureBuilder(
                    future: appState.init_groups_list(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (appState.group_list.length >= 2) {
                          return NavigationRail(
                            extended: false,
                            destinations: [
                              for (var group in appState.group_list)
                                NavigationRailDestination(
                                    icon: Icon(Icons.group_work),
                                    label: Text(group["groupID"]!)
                                )
                            ],
                            selectedIndex: appState.current_group,
                            onDestinationSelected: (value) async {
                              setState(() {
                                appState.select_group(value);
                              });
                            },
                            trailing: ElevatedButton(
                                onPressed: () async {
                                  await _onPressNewGroup();
                                  if (_newGroupName != '') appState.create_group(_newGroupName);
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
                                      if (_newGroupName != '') appState.create_group(_newGroupName);
                                      _newGroupName = '';
                                    },
                                    child: Icon(Icons.add)
                                )
                              ],
                            )
                          );
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
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
                        child: FutureBuilder(
                          future: appState.init_channels_list(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            // print("Rebuilding channels pane");
                            if (snapshot.connectionState == ConnectionState.done) {
                              // print("Building channel nav rail: ${appState.channel_list}");
                              if (appState.channel_list.length >= 2) {
                                return TabBarView(
                                    children: [
                                      NavigationRail(
                                          extended: wide_display,
                                          destinations: [
                                            for (var channel in appState.channel_list)
                                              NavigationRailDestination(
                                                  padding: EdgeInsets.all(2),
                                                  icon: Icon(Icons.tag),
                                                  label: Text(channel['name'])
                                              )
                                          ],
                                          selectedIndex: appState.current_channel,
                                          onDestinationSelected: (value) {
                                            setState(() {
                                              appState.select_channel(value);
                                            });
                                          },
                                          trailing: ElevatedButton(
                                              onPressed: () async {
                                                await _onPressNewChannel();
                                                if (_newChannelName != '') appState.create_channel(_newChannelName);
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
                                            if (_newChannelName != '') appState.create_channel(_newChannelName);
                                            _newChannelName = '';
                                          },
                                          child: Text("New Channel")
                                      )
                                    ],
                                  )
                                );
                              }
                            } else {
                              return CircularProgressIndicator();
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
  const ChannelPane({super.key});

  @override
  State<ChannelPane> createState() => _ChannelPaneState();
}
class _ChannelPaneState extends State<ChannelPane> with TickerProviderStateMixin {
  late TabController _tab_controller;
  late TextEditingController _message_body_controller;

  List<Widget> messages = [
  ];
  List<Widget> pins = [

  ];


  sendMessage(String message){
    setState(() {
      messages.add(
          MessageCard(
              MessageBody: message,
              MessageTimestamp: Timestamp.now().toDate().toLocal().toString(),
              MessageSender: "dsurgenavic"
          )
      );
    });
    getDoc('gEsXF5sWSU4BKZpBZXgq','HW3GaiDPb0kcf4aJP6pj','wDHaNCTcWWeSsihuBIJ2');
    ////Groups/gEsXF5sWSU4BKZpBZXgq/Channel/HW3GaiDPb0kcf4aJP6pj/Messages/wDHaNCTcWWeSsihuBIJ2
    _message_body_controller.clear();
  }


  @override
  void initState() {
    super.initState();
    _tab_controller = TabController(length: 3, vsync: this);
    _message_body_controller = TextEditingController();
    messages = []; // TODO: replace this line with fetching messages from database.
  }

  @override
  void dispose() {
    _message_body_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<GroupChannelState>();

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
                            child: FutureBuilder(
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                return ListView.builder(
                                  itemCount: appState.message_list.length,
                                  itemBuilder: (BuildContext context, int index) {
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
                                                label: appState.pinned_list[index] ? "Unpin" : "Pin"
                                              )
                                            ],
                                          );
                                        },
                                        child: appState.message_list[index]
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
                                        sendMessage(value);
                                        appState.send_message(value);
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
                                    sendMessage(_message_body_controller.text);
                                    appState.send_message(_message_body_controller.text);
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
                        itemCount: appState.message_list.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (!appState.pinned_list[index]) return null;
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
                                        label: appState.pinned_list[index] ? "Unpin" : "Pin"
                                    )
                                  ],
                                );
                              },
                              child: appState.message_list[index]
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
