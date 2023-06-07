import 'package:euphony/Login1.dart';
import 'package:euphony/MainView.dart';
import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:euphony/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../services/firebase_services.dart';


class resetPassword extends StatelessWidget {
  TextEditingController _emailTextController = TextEditingController();
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight, 
              end: Alignment.bottomLeft, 
              colors: [Color(0xFFC576F6), Color(0xFF10BBE5)]
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80,),
              SizedBox(height: 15,),
              SizedBox(height: 30,),
              Container(
                height: 270,
                width: 325,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30,),
                    Text('Reset Password',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: 250,
                      child: Column(
                        children: <Widget>[
                          reusableTextField("Email Address", Icons.person, false, _emailTextController),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    FireBaseButton(context, "Reset Password", () {
                      FirebaseAuth.instance
                      .sendPasswordResetEmail(email: _emailTextController.text)
                      .then((value) => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()))); //get input validation
                    })
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}