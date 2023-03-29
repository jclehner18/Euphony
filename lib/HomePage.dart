//import 'package:euphony/Login.dart';
import 'package:euphony/Login1.dart';
import 'package:euphony/MainView.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFC576F6), Color(0xFF10BBE5)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(padding: EdgeInsets.symmetric(horizontal: 100, vertical: 40), 
        child: Column(
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
            Text('Euphony', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            //SizedBox(width: 450),
            Text('DOWNLOAD', style: TextStyle(color: Colors.white)),
            //SizedBox(width: 500,),

              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: StadiumBorder(),
              ), child: const Text('Login', style: TextStyle(color: Colors.black, /*fontSize: 30,*/ fontWeight: FontWeight.bold),), 
                onPressed: () {
                  //Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainView()));
                }),
          ])
        ],)
        ),
      ));
  }
}