import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euphony/MainView.dart';
import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:euphony/userSetup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  
  
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
                height: 400,
                width: 325,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30,),
                    Text('Sign Up!',
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
                            reusableTextField("Username", Icons.person, false, _usernameTextController)
                          ],
                        ),
                      ),
                   
                      Container(
                        width: 250,
                        child: Column(
                          children: <Widget>[
                            reusableTextField("Email Address", Icons.email, false, _emailTextController)
                          ],
                        ),
                      ),
                  
                      Container(
                        width: 250,
                        child: Column(
                          children: <Widget>[
                            reusableTextField("Password", Icons.lock, true, _passwordTextController)
                          ],
                        ),
                      ),
                    SizedBox(height: 20,),
                    // Container(
                    //   child: Column(children: <Widget>[
                    //     FireBaseButton(context, "Sign Up", () {

                    //       FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailTextController.text, 
                    //         password: _passwordTextController.text);
                            
                    //         User? updateUser = FirebaseAuth.instance.currentUser;
                    //         updateUser!.updateProfile(displayName: _usernameTextController.text);
                    //         userSetup(_usernameTextController.text)
                            
                            
                    //         //  catchError((err) {
                              
                    //         //   showDialog(
                    //         //     context: context, 
                    //         //     builder: (BuildContext context) {
                    //         //       return AlertDialog(  
                    //         //         title: Text("Error"),
                    //         //         content: Text("Email is already in use or entered improperly. Also check your password. It needs to be at least 6 characters."),
                    //         //         actions: [
                    //         //           FloatingActionButton(
                    //         //             child: Text("Ok"),
                    //         //             backgroundColor: Colors.grey,                   
                    //         //             onPressed: () {
                    //         //             Navigator.of(context).pop();
                    //         //           })
                    //         //         ],
                    //         //       );
                    //         //     });
                    //         // }
                    //         // );
                               
                            

                            
                            
                    //         .then((value) => {  
                                     
                    //           Navigator.push(context, MaterialPageRoute(builder: (context) => MainView())),
                    //         }).onError((error, stackTrace) => {
                    //           //print("Error ${error.toString()}"),
                    //         });
                    //     })
                    //   ]),

                      


                    // ),

                    Container(
                      width: 250,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFC576F6), Color(0xFF10BBE5)])),
                      child: ElevatedButton(  
                        onPressed: () {
                          FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailTextController.text, 
                            password: _passwordTextController.text);
                            
                            User? updateUser = FirebaseAuth.instance.currentUser;
                            updateUser!.updateDisplayName(_usernameTextController.text);
                            userSetup(_usernameTextController.text);

                            Navigator.push(context, MaterialPageRoute(builder: (context) => MainView()));
                        },
                        child: Text(
                          'Sign Up',
                          style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ButtonStyle(  
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              if(states.contains(MaterialState.pressed)) {
                                return Colors.black26;
                              }
                              return Color(0x00FFFFFF);
                            }),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                            )
                          ),
                        )
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(colors: [
                          Color(0xFFC576F6),
                          Color(0xFF10BBE5)
                        ])
                      ),
                    ),  
                  ],
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}
