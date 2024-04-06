import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class servicesaddition extends StatefulWidget {
  const servicesaddition({super.key});

  @override
  State<servicesaddition> createState() => _servicesadditionState();
}


class _servicesadditionState extends State<servicesaddition> {
  File? profilepic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Your Services",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,

      ),
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              XFile ? selectedImage = await ImagePicker().pickImage(
                  source: ImageSource.gallery);


              if (selectedImage != null) {
                File convertedfile = File(selectedImage!.path);
                uihelper.CustomAlertbox(context, "Image Selected!");
                setState(() {
                  profilepic = convertedfile;
                });
              }
              else {
                uihelper.CustomAlertbox(context, "No Image Selected!");
              }
            },
            child: Center(
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.grey,
                backgroundImage: (profilepic != null) ? FileImage(profilepic!): null,

              ),
            ),

          ),

        ],
      ),
    );
  }
}
