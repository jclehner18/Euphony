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

  static const List<Widget> _panes = [
    GroupListPane(),
    GroupPane(),
    ChannelPane()
  ];
  int _selectedPane = GROUP_LIST_PANE_INDEX; // This is only used for the narrow view.




  @override 
  Widget build(BuildContext context) {
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
          if (constraints.maxWidth > MIN_WIDTH_FOR_WIDE_DISPLAY) {
            return _wideMainView();
          } else if (constraints.maxWidth > MIN_WIDTH_FOR_MED_DISPLAY) {
            return _midWidthMainView();
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
        SizedBox(
            width: 320,
            child: _panes[GROUP_INFO_PANE_INDEX]
        ),
        Expanded(
            child: _panes[CHAT_PANE_INDEX]
        )
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
  const ChannelPane({super.key});

  @override
  State<ChannelPane> createState() => _ChannelPaneState();
}

class _ChannelPaneState extends State<ChannelPane> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Returns a ListView widget populated with messages.
  Widget getMessages() {
    return ListView(
      children: [
        MessageCard(),
        MessageCard(),
        MessageCard()
      ]
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                        child: getMessages()
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
                              ),
                            ),
                          ),
                          Container(
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () {
                                print("Sending Message");
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
}
