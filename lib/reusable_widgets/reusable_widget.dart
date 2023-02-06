
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
  TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      //cursorColor: Colors.white,
      //style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: Icon(
          icon, 
          size: 20,
        ),
        labelText: text,
        //labelStyle: TextStyle(color: Colors.grey),
        //filled: true,
        //floatingLabelBehavior: FloatingLabelBehavior.never,
        //fillColor: Colors.grey,
        //border: OutlineInputBorder(
          //borderRadius: BorderRadius.circular(30),
          //borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
        ),
        keyboardType: isPasswordType
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,

      );
      
  }

Container signInSignUpButton(
  BuildContext context, bool isLogin, Function onTap) {
    return Container(
      width: 250,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFC576F6), Color(0xFF10BBE5)])),
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        child: Text(
          isLogin ? 'LOG IN' : 'SIGN UP',
          style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black26;
              }
              return Color(0x00FFFFFF);
            }),
            
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))))
        ),
      );
  }
