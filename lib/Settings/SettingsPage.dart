import 'package:euphony/HomePage.dart';  
import 'package:euphony/Settings/password.dart';
import 'package:euphony/Settings/profPic.dart';
import 'package:euphony/Settings/profileSettings.dart';
import 'package:flutter/material.dart';

class settingsPage extends StatefulWidget {
  settingsPage({Key? key}) : super(key: key);

  @override
  _settingsPage createState() => _settingsPage();
}

class _settingsPage extends State<settingsPage> {
  
  int index = 0;
  final labelStyle = TextStyle(fontWeight: FontWeight.bold);
  final selectedColor = Colors.white;
  final unselectedColor = Colors.white60;

  @override

  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black54,
        centerTitle: false,
        title: Text('Settings'),

      ),
      body: Row(  
        children: [
          NavigationRail( 
            backgroundColor: Colors.black54, 
            labelType: NavigationRailLabelType.all,
            selectedLabelTextStyle: labelStyle.copyWith(color: selectedColor),
            unselectedLabelTextStyle: labelStyle.copyWith(color: unselectedColor),
            selectedIndex : index,
            selectedIconTheme: IconThemeData(color: Colors.white),
            unselectedIconTheme: IconThemeData(color: Colors.white60),
            onDestinationSelected: (index) => setState(() => this.index = index),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.picture_in_picture),
                label: Text("Icon"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text("Name"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.lock),
                label: Text("Password"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.style),
                label: Text("Appearence"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.voice_chat),
                label: Text("Voice"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text("Notifications"),
              ),
            ],
          ),
          Expanded(child: buildPages()),
        ]
      )
    );
    
  Widget buildPages() {
    switch (index) {
      case 0: 
        return profPicture(); //icon
      case 1:
        return ProfileInfo(); //name
      case 2:
        return PasswordSettings(); //password
      case 3:  
        return Placeholder(); //appearence
      case 4:  
        return Placeholder(); //voice settings
      case 5:
        return Placeholder(); //notifications
      default:
        return Placeholder(); //make this logout
    }
  }
}