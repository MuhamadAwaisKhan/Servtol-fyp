
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
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
          labelText: text,
            labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17,),
            // hintText: text,
            suffixIcon: Icon(iconData),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            )
        ),
      ),
    );
  }

  static Widget CustomTextfieldpassword(BuildContext context, TextEditingController controller,
      String text, bool passwordVisible, Function(bool) toggleVisibility, ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: !passwordVisible,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17,),
          suffixIcon: GestureDetector(
            onTap: () {
              toggleVisibility(!passwordVisible);
            },
            child: Icon(
              passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
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
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.customButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),

          ),


        ),
        child: Text(
          text, style: TextStyle(color: Colors.white, fontSize: 28,fontFamily:"Poppins"),)),
    );
  }
  static CustomtextButton(VoidCallback voidCallback, String text) {
    return  SizedBox(
        height: 58, width: 130, child: TextButton(

          onPressed: () {
            voidCallback();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.heading,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),

            ),


          ),
          child: Text(
            text, style: TextStyle(color: Colors.white, fontSize: 18,fontFamily:"Poppins"),)),

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
