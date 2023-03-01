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
import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


// DEFINE CONSTANTS
int NARROW_SCREEN_WIDTH = 600;
int TWELVE = 12;  // This is kind of a joke. It's only used for taking the hour number in a 24 hour format to 12 hour format.


class GroupChannelState extends ChangeNotifier {
  var current_user = "dsurgenavic";

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
    //TODO: fetch groups from database
    group_list = [
      "Sample Group 1",
      "Sample Group 2",
    ];
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

  void create_group() {
    notifyListeners();
  }

  void create_channel() {

    channel_list[current_group].add("New Group");
    notifyListeners();
  }

  void send_message(String body) {
    var ts = Timestamp.now().toDate();
    var timestamp = "Today at ${ts.hour % TWELVE}:${ts.minute}";
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



class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}
class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<GroupChannelState>();
    appState.init_groups_list();
    appState.init_channel_list();
    appState.init_messages();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool wide_display = (constraints.maxWidth >= NARROW_SCREEN_WIDTH);
        if (wide_display) {
          return Scaffold(
            appBar: AppBar(
                title: const Text("Euphony"),
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
                        })
                      },
                      child: const Icon(Icons.logout_outlined)
                  ),
                ]
            ),
            body: Row(
              children: [
                SafeArea(
                  child: Row(
                      children: [
                        SizedBox(
                            width: (wide_display ? 100 : 60),
                            child: NavigationRail(
                              extended: false,
                              destinations: [
                                for (var group in appState.group_list)
                                  NavigationRailDestination(
                                      icon: Icon(Icons.group_work),
                                      label: Text(group)
                                  )
                              ],
                              selectedIndex: appState.current_group,
                              onDestinationSelected: (value) {
                                appState.select_group(value);
                              },
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
                                  child: TabBarView(
                                      children: [
                                        NavigationRail(
                                            extended: wide_display,
                                            destinations: [
                                              for (var channel in appState
                                                  .channel_list[appState
                                                  .current_group])
                                                NavigationRailDestination(
                                                    padding: EdgeInsets.all(2),
                                                    icon: Icon(Icons.tag),
                                                    label: Text(channel)
                                                )
                                            ],
                                            selectedIndex: appState
                                                .current_channel,
                                            onDestinationSelected: (value) {
                                              appState.select_channel(value);
                                            },
                                            trailing: ElevatedButton(
                                                onPressed: () {
                                                  appState.create_channel();
                                                },
                                                child: Text("New Channel")
                                            )
                                        ),
                                        ListView.builder(
                                          itemCount: 3,
                                          itemBuilder: (context, value) {
                                            return Placeholder();
                                          },
                                        )
                                      ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ]
                  ),
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
              child: Row(
                  children: [
                    SizedBox(
                        width: 60,
                        child: NavigationRail(
                          extended: false,
                          destinations: [
                            for (var group in appState.group_list)
                              NavigationRailDestination(
                                  icon: Icon(Icons.group_work),
                                  label: Text(group)
                              )
                          ],
                          selectedIndex: appState.current_group,
                          onDestinationSelected: (value) {
                            appState.select_group(value);
                          },
                        )
                    ),
                    DefaultTabController(
                      length: 2,
                      child: SizedBox(
                        width: 220,
                        child: Column(
                          children: [
                            TabBar(
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
                            Expanded(
                              child: TabBarView(
                                  children: [
                                    NavigationRail(
                                        extended: true,
                                        destinations: [
                                          for (var channel in appState
                                              .channel_list[appState
                                              .current_group])
                                            NavigationRailDestination(
                                                padding: EdgeInsets.all(2),
                                                icon: Icon(Icons.tag),
                                                label: Text(channel)
                                            )
                                        ],
                                        selectedIndex: appState
                                            .current_channel,
                                        onDestinationSelected: (value) {
                                          appState.select_channel(value);
                                        },
                                        trailing: ElevatedButton(
                                            onPressed: () {
                                              appState.create_channel();
                                            },
                                            child: Text("New Channel")
                                        )
                                    ),
                                    ListView.builder(
                                      itemCount: 3,
                                      itemBuilder: (context, value) {
                                        return Placeholder();
                                      },
                                    )
                                  ]
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]
              ),
            )
          );
        }
      }
    );
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


  void sendMessage(String message) {
    setState(() {
      messages.add(
          MessageCard(
              MessageBody: message,
              MessageTimestamp: Timestamp.now().toDate().toLocal().toString(),
              MessageSender: "dsurgenavic"
          )
      );
    });
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

    return Builder(
        builder: (context) {
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
                              child: ListView.builder(
                                itemCount: appState.current_message_list.length,
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
                                              },
                                              label: appState.current_pinned_list[index] ? "Unpin" : "Pin"
                                            )
                                          ],
                                        );
                                      },
                                      child: appState.current_message_list[index]
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
                        child: SfCalendar(
                          view: CalendarView.month
                        )
                      ),
                      Container(
                        child: ListView.builder(
                          itemCount: appState.current_message_list.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (!appState.current_pinned_list[index]) return null;
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
                                          },
                                          label: appState.current_pinned_list[index] ? "Unpin" : "Pin"
                                      )
                                    ],
                                  );
                                },
                                child: appState.current_message_list[index]
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
        break;
      case TargetPlatform.iOS:
        return true;
        break;
      case TargetPlatform.macOS:
        return false;
        break;
      case TargetPlatform.fuchsia:
        return false;
        break;
      case TargetPlatform.linux:
        return false;
        break;
      case TargetPlatform.windows:
        return false;
        break;
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
