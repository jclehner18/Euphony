
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


class MessageCard extends StatelessWidget {
  static const SampleMessageSenderProfile = Image(image: NetworkImage("https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg"));
  static const SampleMessageSender = "Sample User";
  static const SampleMessageTimestamp = "12:03";
  static const SampleMessage = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

  const MessageCard({super.key,
    this.MessageBody = SampleMessage,
    this.MessageSender = SampleMessageSender,
    this.MessageSenderProfile = SampleMessageSenderProfile,
    this.MessageTimestamp = MessageCard.SampleMessageTimestamp
  });

  final String MessageSender;
  final Image MessageSenderProfile;
  final String MessageTimestamp;
  final String MessageBody;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColorLight,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                height: 32,
                width: 32,
                child: MessageSenderProfile,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        MessageSender,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,

                        )
                      ),
                      const SizedBox(width: 6),
                      Text(
                        MessageTimestamp,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w100,
                          color: Colors.grey
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(MessageBody)
                      )
                    ],
                  )
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
