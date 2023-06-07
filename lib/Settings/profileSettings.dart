
import 'dart:io';

import 'package:euphony/reusable_widgets/reusable_widget.dart';
import 'package:euphony/userSetup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class SettingsUI extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Setting UI",
      home: ProfileInfo(),
    );
  }
}



class ProfileInfo extends StatefulWidget {
  
  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery,);
    Reference ref = FirebaseStorage.instance.ref().child("profilepic.jpg");
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      print(value);
    });
  }


  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  

  String imageUrl = '';

  TextEditingController _usernameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(  
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(  
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15,),
              Center(
                
                  child: GestureDetector(
                    onTap: () async {
                      
                      ImagePicker imagePicker=ImagePicker();
                      XFile? file= await imagePicker.pickImage(source: ImageSource.gallery);
                      print('${file?.path}');
                      if(file == null) return;
                      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages = referenceRoot.child('images');
                      Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

                      // try{
                      // await referenceImageToUpload.putFile(File(file!.path));
                      // imageUrl = await referenceImageToUpload.getDownloadURL();

                      // } catch(error) {

                      // }

                      


                    },
                    child: Stack(  
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration( 
                            border: Border.all(  
                              width: 4,
                              color: Colors.black,
                            ), 
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 2, blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10)
                              )
                            ],
                            shape: BoxShape.circle,
                            image: DecorationImage(  
                              fit: BoxFit.cover,
                              image: NetworkImage('/images/defaultProf.jpeg')
                            )
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(  
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(  
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Colors.black,
                            ),
                            color: Colors.purple,
                          ),
                          child: Icon(Icons.edit, color: Colors.white,),
                          ) 
                        )
                      ],
                    ),
                  ),
                ),
              
              Container(
                        width: 250,
                        child: Column(
                          children: <Widget>[
                            reusableTextField("Username", Icons.person, false, _usernameTextController)
                          ],
                        ),
                      ),
              
              SizedBox(height: 20,),
              Row(  
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      User? updateUser = FirebaseAuth.instance.currentUser;
                      updateUser!.updateDisplayName(_usernameTextController.text);
                      userSetup(_usernameTextController.text);
                      
                    },
                    child: Text("Save", style: TextStyle(fontSize: 14, color: Colors.white),),
                  )
                  
                ],
              )
            ],
            
          ),
        ),
      )
    );
    
  }
}