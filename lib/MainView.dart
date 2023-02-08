import 'package:euphony/Login1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
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
      body: Row(
        children: [
          SizedBox(
            width: 120,
            child: GroupListPane()
          ),
          SizedBox(
            width: 320,
            child: GroupPane()
          ),
          Expanded(
            child: ChannelPane()
          )
        ],
      )
    );
  }
}

class GroupListPane extends StatelessWidget {
  const GroupListPane({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        width: 60,
        child: Placeholder()
      ),
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
      child: SizedBox(
        width: 250,
        child: Column(
          children: [
            TabBar(
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
                    child: Placeholder()
                  ),
                  Container(
                    child: Placeholder()
                  )
                ],
              ),
            )
          ],
        ),
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
                Container(child: Placeholder()),
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
