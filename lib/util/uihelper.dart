import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:servtol/util/AppColors.dart';

class uihelper {
  static customPhoneField(TextEditingController controller,
      String text,
      IconData iconData,
      Function(PhoneNumber) mobileCallBack) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          // controller: controller;
          // onInputChanged: (value) => controller.text = value.phoneNumber??"",
          mobileCallBack.call(number);
          print(number.phoneNumber);
        },

        initialValue: PhoneNumber(isoCode: 'PK'),
        inputDecoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(),
          ),
          suffixIcon: Icon(iconData),
        ),

      ),
    );
  }

  static CustomTextField(TextEditingController controller,
      String text,
      IconData iconData,
      bool tohide,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: tohide,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
          suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
  static CustomNumberField(TextEditingController controller,
      String text,
      IconData iconData,
      bool tohide,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number, // Set keyboard type to numeric
        obscureText: tohide,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
          suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  static Widget CustomTextfieldpassword(BuildContext context,
      TextEditingController controller,
      String text,
      bool passwordVisible,
      Function(bool) toggleVisibility,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: !passwordVisible,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
          suffixIcon: GestureDetector(
            onTap: () {
              toggleVisibility(!passwordVisible);
            },
            child: Icon(
              passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme
                  .of(context)
                  .primaryColorDark,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  static CustomButton(VoidCallback voidCallback, String text,double h,double w) {
    return SizedBox(
      height: h,
      width: w,
      child: ElevatedButton(
        onPressed: voidCallback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.customButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white,  fontFamily: "Poppins"),
        ),
      ),
    );
  }

  static CustomTextButton(VoidCallback voidCallback, String text,
      IconData iconData, Color iconColor,
       // bool isClicked,
  ) {
    return SizedBox(
      height: 70,
      width: 150,
      child: TextButton(
        onPressed: voidCallback,
        style: ElevatedButton.styleFrom(
           // backgroundColor: isClicked ? Colors.green : AppColors.customButton,
            backgroundColor: AppColors.customButton,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData,
                color: Colors.white ,
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontFamily: "Poppins"),
            ),
          ],
        ),
      ),
    );
  }

  static CustomAlertbox(BuildContext context, String text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
