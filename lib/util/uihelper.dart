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

  static  CustomTextfieldpassword(BuildContext context,
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

  static CustomButton(VoidCallback voidCallback, String text, double h,
      double w) {
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
              color: Colors.white, fontFamily: "Poppins"),
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
              color: Colors.white,
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

  static CustomTimeDuration(TextEditingController controller,
      String text,
      IconData iconData,
      String hinttext,
     ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(
        controller: controller,
      keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: text,
          hintText:hinttext,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
          suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),

      ),
    );
  }
  static CustomDescritionfield(TextEditingController controller,
      String text,
      IconData iconData,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(

        controller: controller,

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
  static detailCard(String title, String value, {bool lastItem = false}) {
    return Card(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: lastItem ? 10 : 15),  // Adjusted for consistency and visual spacing
      elevation: 2,  // Adds a subtle shadow for depth
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),  // Slightly larger padding for a better touch target
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,  // Adjust flex to manage space allocation if title tends to be longer
              child: Tooltip(
                message: title,  // Tooltip to show full title on long press if truncated
                child: Text(
                  title,
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.lightBlue),
                  overflow: TextOverflow.ellipsis,  // Ensures text does not break layout
                ),
              ),
            ),
            Expanded(
              flex: 3,  // Gives more room for the value which might be longer
              child: Text(
                value,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.right,
                maxLines: 2,  // Allows text wrapping if very long
                overflow: TextOverflow.ellipsis,  // Adds ellipsis if text overflows
              ),
            ),
          ],
        ),
      ),
    );
  }


  static Widget actionButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white), // Icon color is white to contrast with button color
      label: Text(label, style: TextStyle(fontFamily: 'Poppins')),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding for better visual balance
      ),
    );
  }

}



