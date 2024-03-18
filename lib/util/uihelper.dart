
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:servtol/util/AppColors.dart';
class uihelper {
  static CustomTextfield(TextEditingController controller,
      String text, IconData iconData, bool tohide,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: tohide,
        decoration: InputDecoration(
            hintText: text,
            suffixIcon: Icon(iconData),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            )
        ),
      ),
    );
  }

  static CustomButton(VoidCallback voidCallback, String text) {
    return SizedBox(
      height: 58, width: 300, child: ElevatedButton(

        onPressed: () {
      voidCallback();
    },
        style: ElevatedButton.styleFrom(backgroundColor:AppColors.customButton,shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),

        ),


        ),
        child: Text(
          text, style: TextStyle(color: AppColors.green, fontSize: 28),)),
    );
  }

  static CustomAlertbox(BuildContext context, String text) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text(text),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("OK"))
        ],
      );
    });
  }
}
