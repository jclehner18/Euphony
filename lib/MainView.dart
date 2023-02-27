import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euphony/Login1.dart';
import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


const int MIN_WIDTH_FOR_WIDE_DISPLAY = 900;
const int MIN_WIDTH_FOR_MED_DISPLAY = 600;

const int PANE_LIST_LENGTH = 3;
const int GROUP_LIST_PANE_INDEX = 0;
const int GROUP_INFO_PANE_INDEX = 1;
const int CHAT_PANE_INDEX = 2;


class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  static int active_group = 0;
  static int active_channel = 0;

  static List<Widget> _panes = [
    GroupListPane(),
    GroupPane(),
    ChannelPane()
  ];
  int _selectedPane = GROUP_LIST_PANE_INDEX; // This is only used for the narrow view.


  // TODO make this something.
  final channel_list = [
    ChannelPane(),
    ChannelPane(),
    ChannelPane(),
  ];
  final channel_buttons = const [
    NavigationRailDestination(
        icon: Icon(Icons.tag),
        label: Text('Sample Channel 1')
    ),
    NavigationRailDestination(
        icon: Icon(Icons.tag),
        label: Text('Sample Channel 2')
    ),
    NavigationRailDestination(
        icon: Icon(Icons.tag),
        label: Text('Sample Channel 3')
    )
  ];
  int selected_channel_index = 0;


  @override 
  Widget build(BuildContext context) {
    Widget current_channel = channel_list[selected_channel_index];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Euphony"),
        actions: [
          ElevatedButton(
            onPressed: () {
              print("Opened Settings");
            },
            child: const Icon(Icons.settings)
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              });
            },
            child: Row(
              children: const [
                Icon(Icons.logout),
                Text("Logout"),
              ],
            )
          )
        ]
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > MIN_WIDTH_FOR_MED_DISPLAY) {
            return Row(
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      SizedBox(
                        child: _panes[GROUP_LIST_PANE_INDEX],
                        width: 120
                      ),
                      NavigationRail(
                        extended: constraints.maxWidth >= MIN_WIDTH_FOR_WIDE_DISPLAY,
                        destinations: channel_buttons,
                        selectedIndex: selected_channel_index,
                        onDestinationSelected: (value) {
                          setState( () {
                            selected_channel_index = value;
                            print("Channel $selected_channel_index selected");
                          });
                        },
                      ),
                    ],
                  )
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: current_channel
                  )
                )
              ]
            );
          } else {
            return _narrowMainView();
          }
        },
      )
    );
  }

  Widget _wideMainView() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: _panes[GROUP_LIST_PANE_INDEX]
        ),
        /*
        SizedBox(

            width: 320,
            child: _panes[GROUP_INFO_PANE_INDEX]
        ),
        Expanded(
            child: _panes[CHAT_PANE_INDEX]
        )
        */
        ChannelDrawer()

      ],
    );
  }

  Widget _midWidthMainView() {
    var groups = [
      Row (
        children: [
          SizedBox(
              //width: 120,
              child: _panes[GROUP_LIST_PANE_INDEX]
          ),
          Expanded(
              child: _panes[GROUP_INFO_PANE_INDEX]
          )
        ],
      ),
      _panes[CHAT_PANE_INDEX]
    ];
    return Column(
      children: [
        Expanded(
          child: groups.elementAt(_selectedPane)
        ),
        BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.group_work),
              label: "Groups/Channels"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: "Content"
            )
          ],
          currentIndex: _selectedPane,
          onTap: (int index) {
            setState(() {
              _selectedPane = index;
            });
          }
        )
      ]
    );
  }

  Widget _narrowMainView() {
    return Column(
      children: [
        Expanded(
          child: _panes.elementAt(_selectedPane)
        ),
        BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.group_work),
              label: "Groups",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag),
              label: "Channels"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: "Content"
            )
          ],
          currentIndex: _selectedPane,
          onTap: (int index) {
            setState(() {
              _selectedPane = index;
            });
          }
        )
      ],
    );
  }
}

class GroupListPane extends StatelessWidget {
  const GroupListPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10
            ),
            child: Text("Groups"),
          ),
          Expanded(
            child: ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: SizedBox(
                      height: 80,
                      width: 100,
                      child: Placeholder()
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: SizedBox(
                      height: 80,
                      width: 100,
                      child: Placeholder()
                  ),
                ),
              ],
            )
          )
        ]
      )
    );
  }
}

class GroupPane extends StatefulWidget {
  const GroupPane({super.key});

  @override
  State<GroupPane> createState() => _GroupPaneState();
}

class _GroupPaneState extends State<GroupPane> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final channels_list = [];
  int selected_channel = 0;


  List<Widget> getChannelsList () {
    return [
      ChannelButton(onClickCallback: onClickChannel),
      ChannelButton(onClickCallback: onClickChannel),
      ChannelButton(onClickCallback: onClickChannel),
    ];
  }

  // Callback function when selecting a channel
  void onClickChannel() {
    print("Channel Selected");
  }


  //
  // Required overridden functions below here
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).backgroundColor,
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.list),
                text: "Channels"
              ),
              Tab(
                icon: Icon(Icons.people),
                text: "Members"
              )
            ]
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: Column(
                    children: getChannelsList()
                  )
                ),
                Container(
                  child: Column(
                    children: [
                      GroupMemberCard(),
                      GroupMemberCard(),
                      GroupMemberCard()
                    ],
                  )
                )
              ],
            ),
          )
        ],
      ),

    );
  }
}

class ChannelPane extends StatefulWidget {
  ChannelPane({super.key});

  @override
  State<ChannelPane> createState() => _ChannelPaneState();
}

class _ChannelPaneState extends State<ChannelPane> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _messageFieldController;

  List<Widget> messageList = [];

  // Returns a ListView widget populated with messages.
  List<Widget> getMessages() {
    return [
      MessageCard(),
      MessageCard(),
      MessageCard()
    ];
  }

  void onClickSendMessage() {
    if (_messageFieldController.text == "") {
      return;
    }
    getMessages();

    messageList.add(
      MessageCard(
        MessageBody: _messageFieldController.text,
        MessageTimestamp: Timestamp.now().toString(),
      )
    );

    _messageFieldController.clear();

    build(context);
  }

  // BEGIN OVERRIDDEN METHODS

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _messageFieldController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Builder(
      builder: (context) {
        return Card(
          child: Column(
            children: [
              TabBar(
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).backgroundColor,
                  tabs: const [
                  Tab(
                    icon: Icon(Icons.forum),
                    text: "Messages"
                  ),
                  Tab(
                    icon: Icon(Icons.calendar_month),
                    text: "Calendar"
                  ),
                  Tab(
                    icon: Icon(Icons.push_pin),
                    text: "Pins"
                  )
                ],
                controller: _tabController
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: messageList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return messageList[index];
                              },
                            )
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    bottom: 6,
                                    left: 20,
                                    right: 20
                                  ),
                                  child: TextField(
                                    controller: _messageFieldController,
                                    onSubmitted: (String value) {
                                      onClickSendMessage();
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                child: ElevatedButton(
                                  onPressed: () {
                                    print("Sending Message");
                                    onClickSendMessage();
                                  },
                                  child: Text("SEND")
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    print("Attaching File");
                                  },
                                  child: Icon(Icons.attach_file)
                              ),

                            ],
                          )
                        ],
                      )
                    ),
                    Container(child: Placeholder()),
                    Container(child: Placeholder())
                  ]
                ),
              )
            ],
          ),
        );
      }
    );
  }
}


class ChannelDrawer extends StatefulWidget {
  const ChannelDrawer({super.key});

  @override
  State<ChannelDrawer> createState() => _ChannelDrawerState();
}

class _ChannelDrawerState extends State<ChannelDrawer> {
  var selectedIndex = 0;

  // TODO make this something.
  final channel_list = [
      ChannelPane(),
      ChannelPane(),
      ChannelPane(),
    ];

  final channel_buttons = const [
    NavigationRailDestination(
    icon: Icon(Icons.tag),
    label: Text('Sample Channel 1')
    ),
    NavigationRailDestination(
        icon: Icon(Icons.tag),
        label: Text('Sample Channel 2')
    ),
    NavigationRailDestination(
        icon: Icon(Icons.tag),
        label: Text('Sample Channel 3')
    )
  ];

  @override
  Widget build(BuildContext context) {

    Widget channel = channel_list[selectedIndex];

    return Row(
      children: [
        SafeArea(
          child: NavigationRail(
            extended: true,
            destinations: channel_buttons,
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            }
          )
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: channel
          )
        )
      ],
    );
  }
}
