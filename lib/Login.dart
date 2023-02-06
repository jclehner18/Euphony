import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';

class Login extends StatelessWidget {
  const Login({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: Scaffold(
        
        body: Padding(padding: EdgeInsets.symmetric(horizontal: 100, vertical: 40),
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFC576F6), Color(0xFF10BBE5)])),
          child: Stack(
            children: <Widget> [
              Container(
                padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 80, fontWeight: FontWeight.bold)
                  )
                ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 175, 0, 0),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 80, fontWeight: FontWeight.bold)
                  )
                ),
                Container(
                padding: EdgeInsets.fromLTRB(190, 175, 0, 0),
                child: Text(
                  '.',
                  style: TextStyle(
                    fontSize: 80, fontWeight: FontWeight.bold)
                  )
                ),
            ]
          ),),

    ),),);
  }
}

