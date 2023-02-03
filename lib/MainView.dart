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
      body: Center(  
        child: ElevatedButton(
          child: Text("Logout"), 
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            });
          },
        ),
      ),
    );
  }
}