import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Login1.dart';

class PasswordSettings extends StatefulWidget {
  const PasswordSettings({super.key});

  @override
  _PasswordSettings createState() => _PasswordSettings();
}
class _PasswordSettings extends State<PasswordSettings> {

  final _formKey = GlobalKey<FormState>();
  var newPassword = " ";
  final newPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }

  final currentUser = FirebaseAuth.instance.currentUser;

  changePassword() async {
    try{
      await currentUser!.updatePassword(newPassword);
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),
      ),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.black26,
        content: Text("Your password has been changed. Login again"),
      ),
      );

    } catch(error) {

    }
  }

  @override
  Widget build(BuildContext context) {
    // return Card(
    //   child: Column(
    //     children: [
    //       const Padding(padding: EdgeInsets.only(),
    //       child: Text("Password"),)
    //     ],
    //   ),
    // );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(  
        key: _formKey,
        child: Padding(padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: ListView(  
          children: [
            SizedBox(height: 20,),
            Padding(padding: const EdgeInsets.all(10),
            child: Image.asset("images/change.png", height: 200, width: 200,),),
            Container(  
              margin: EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(  
                autofocus: false,
                obscureText: true,
                decoration: InputDecoration(  
                  labelText: 'New Password',
                  hintText: 'Enter new Password',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  errorStyle: TextStyle(color: Colors.black26, fontSize: 15),
                ),
                controller: newPasswordController,
                validator: (value){
                  if(value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              )
            ),
            ElevatedButton(onPressed: () {
              if(_formKey.currentState!.validate()) {
                setState(() {
                  newPassword = newPasswordController.text;
                });
                changePassword();
              }
            }, child: Text('Change Password',
            style: TextStyle(fontSize: 18),
            ),
            ),
          ],
        )
        )
      )
    );
  }
}