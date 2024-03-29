import 'package:euphony/MainView.dart';
import 'package:euphony/Settings/resetPassword.dart';
import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:euphony/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'app_state.dart';
import 'services/firebase_services.dart';


class LoginPage extends StatelessWidget {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _usernameTextController = TextEditingController();



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
                height: 480,
                width: 325,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30,),
                    Text('Welcome Back!',
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

                    Container(
                      width: 250,
                      child: Column(
                        children: <Widget>[
                          reusableTextField("Password", Icons.lock, true, _passwordTextController),
                          
                        ],                      
                      ),
                    ),
                    
                    forgotPassword(context),
                    SizedBox(height: 10,),
                    Container(
                        child: Column(children: <Widget>[
                          FireBaseButton(context, "Login", () {
                            final newUser = FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailTextController.text, 
                              password: _passwordTextController.text)
                              .catchError((err) {
                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Error"),
                                      content: Text("Email or Password is incorrect"),
                                      actions: [
                                        FloatingActionButton(
                                          child: Text("Ok"),
                                          backgroundColor: Colors.grey,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }
                                        )
                                      ],
                                    );
                                  });
                              }).then((value) => {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MainView())),
                              });
                              
                          }
                          )
                        ],)
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFC576F6), 
                            Color(0xFF10BBE5)
                          ]
                        )
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () async {
                          //GoogleSignIn().signIn();
                          FirebaseService().signInWithGoogle().then((value) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                // Initialize the app's global state.
                                GroupChannelState appState = Provider.of(context);
                                appState.initGroupsList();
                                return MainView();
                              }
                            ));
                          });
                        },
                        // async {
                        //   await FirebaseService().signInWithGoogle();
                        //   Navigator.push(context, MaterialPageRoute(builder: (context) => MainView()));
                        // },
                        label: Text('Login using Google'),
                        backgroundColor: Colors.transparent,
                        icon: Icon(FontAwesomeIcons.google),
                      ),                     
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",
                          style:TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                            },
                            child: const Text(" Sign Up",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                          )                       
                      ],
                    )
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

Widget forgotPassword(BuildContext context) {
  return Container(
    width: 250,
    height: 35,
    alignment: Alignment.bottomRight,
    child: TextButton(  
      child: const Text("Forgot Password?",
      style: TextStyle(color: Colors.grey),
      textAlign: TextAlign.right,
      ),
      onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => resetPassword()));
      },
    ),
  );
}