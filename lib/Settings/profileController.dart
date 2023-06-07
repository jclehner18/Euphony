
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class profileController with ChangeNotifier {

  final picker = ImagePicker();

  File? _image;
  File? get image => _image;

  Future getGalImage(BuildContext context) async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future getCamImage(BuildContext context) async{
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if(pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }

  void pickImage(context) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 120,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    getCamImage(context);
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.camera),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    getGalImage(context);
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                )
              ],
            ),
          ),
        );
      });
  }
}
