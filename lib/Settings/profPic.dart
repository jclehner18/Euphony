
import 'dart:io';
//import 'dart:html';
import 'package:euphony/Settings/profileController.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class profPicture extends StatefulWidget {
@override
_profPictureState createState()  => _profPictureState();
}

class _profPictureState extends State<profPicture> {
  //File? _image;
  bool isPicked = false;
  File? pickedImage;
  

  @override
  Widget build(BuildContext context) {

    Future getImage() async {
     
    //   XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    //   setState(() {
    //     _image = image;
    //     print(_image);
        
    //   });
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        pickedImage = File(image.path);
        String fileName = basename(pickedImage!.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(pickedImage!);
        setState(() {
          isPicked = true;
        });
      }


    }

    Future uploadPic(BuildContext context) async {
      String fileName = basename(pickedImage!.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(pickedImage as File);
      setState(() {
        
      });
    }

    return Scaffold(
      body: Builder(builder: (context) => Container(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(  
                    radius: 100,
                    backgroundColor: Colors.black,
                    child: ClipOval(
                      child: SizedBox(  
                        width: 180,
                        height: 180,
                        child: isPicked ? Image.file(pickedImage!, fit: BoxFit.fill,)                      
                        : Image.network('/images/defaultProf.jpeg',
                        fit: BoxFit.fill,
                        )
                      ),)
                  ),
                ),
                Padding(  
                  padding: EdgeInsetsDirectional.only(top: 100),
                  child: IconButton(  
                    icon: Icon(FontAwesomeIcons.camera, size: 30,),
                    onPressed: () async {
                      getImage();

                      // final ImagePicker _picker = ImagePicker();
                      // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      // if (image != null) {
                      //   pickedImage = File(image.path);
                      //   setState(() {
                      //     isPicked = true;
                      //   });
                      // }

                    },
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      
                      onPressed: () {
                        //uploadPic(context);
                        
                        
                      },
                      child: Text('Save')
                    )
                  ],
                )
              ],
            )
          ],
        )
      )

      )
    );
  }
}