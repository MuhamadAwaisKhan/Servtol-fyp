import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:servtol/util/AppColors.dart';

class uihelper {
  static customPhoneField(TextEditingController controller, String text,
      IconData iconData, Function(PhoneNumber) mobileCallBack) {
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

  static CustomNumberField(
    TextEditingController controller,
    String text,
    IconData iconData,
    bool tohide,
  ) {
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
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  static CustomTextfieldpassword(
    BuildContext context,
    TextEditingController controller,
    String text,
    bool passwordVisible,
    Function(bool) toggleVisibility,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: !passwordVisible,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17, color: Colors.blue),
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
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            // Blue border when focused
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            // Grey border when not focused
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  static CustomButton(
      VoidCallback voidCallback, String text, double h, double w) {
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
              color: Colors.white, fontFamily: "Poppins", fontSize: 15),
        ),
      ),
    );
  }

  static CustomTextButton(
    VoidCallback voidCallback,
    String text,
    IconData iconData,
    Color iconColor,
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
            Icon(
              iconData,
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

  static CustomTimeDuration(
    TextEditingController controller,
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
          hintText: hinttext,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
          suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  static detailCard(String title, String value, {bool lastItem = false}) {
    return Card(
      margin: EdgeInsets.only(
          top: 10, left: 10, right: 10, bottom: lastItem ? 10 : 15),
      // Adjusted for consistency and visual spacing
      elevation: 2,
      // Adds a subtle shadow for depth
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        // Slightly larger padding for a better touch target
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              // Adjust flex to manage space allocation if title tends to be longer
              child: Tooltip(
                message: title,
                // Tooltip to show full title on long press if truncated
                child: Text(
                  title,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue),
                  overflow: TextOverflow
                      .ellipsis, // Ensures text does not break layout
                ),
              ),
            ),
            Expanded(
              flex: 3, // Gives more room for the value which might be longer
              child: Text(
                value,
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.right,
                maxLines: 2, // Allows text wrapping if very long
                overflow:
                    TextOverflow.ellipsis, // Adds ellipsis if text overflows
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget actionButton(
      String label, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      // Icon color is white to contrast with button color
      label: Text(label, style: TextStyle(fontFamily: 'Poppins')),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20), // Adjust padding for better visual balance
      ),
    );
  }

  static FormBuilderTextField(
    // TextEditingController controller,
    String text,
    IconData iconData,
    // bool tohide,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
      child: TextField(
        // controller: controller,
        // obscureText: tohide,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17),
          suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  static Widget customDropdownButtonFormField({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String labelText,
    InputDecoration? decoration,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      // Specify the padding you want around the dropdown
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: decoration ??
            InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(25),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
        style:
            TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 17),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
        iconSize: 24,
        elevation: 16,
        isExpanded: true,
      ),
    );
  }

  static CustomTextField(
      BuildContext context,
    TextEditingController controller,
    String text,
    IconData iconData,
    bool tohide,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: tohide,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(
              fontFamily: 'Poppins', fontSize: 17, color: Colors.blue),
          suffixIcon: Icon(
            iconData,
            color: Theme.of(context).primaryColorDark,

          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            // Blue border when focused
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  static customDescriptionField(
    TextEditingController controller,
    String labelText,
    // IconData iconData
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,

          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 17),
          // suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            // borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(25),
          ),
          // enabledBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.grey),
          //   borderRadius: BorderRadius.circular(25),
          // ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.orange,
                width:
                    2.0), // Optional: Styling for when the TextField has an error
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.only(bottom: 12, left: 115),
          // focusedBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.red, width: 2.0),
          //   borderRadius: BorderRadius.circular(25),
          // ),
          fillColor: Colors.transparent,
          filled: true,
        ),
        // style: TextStyle(color: Colors.white),
        maxLines: 3,
      ),
    );
  }

  static customDescriptionField1(
    TextEditingController controller,
    String labelText,
    // IconData iconData
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,

          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 17),
          // suffixIcon: Icon(iconData),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(25),
          ),
          //  enabledBorder: UnderlineInputBorder(
          // borderSide: BorderSide(color: Colors.blue, width: 2.0),
          //
          //   borderRadius: BorderRadius.circular(25),
          // ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.orange,
                width:
                    2.0), // Optional: Styling for when the TextField has an error
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.only(bottom: 12, left: 115),
          // focusedBorder: UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.red, width: 2.0),
          //   borderRadius: BorderRadius.circular(25),
          // ),
          fillColor: Colors.transparent,
          filled: true,
        ),
        // style: TextStyle(color: Colors.white),
        maxLines: 3,
      ),
    );
  }

  static Widget CustomButton1(
    VoidCallback voidCallback,
    String text,
    double height,
    double width, {
    icon,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton.icon(
        onPressed: voidCallback,
        icon: icon ?? Container(), // Show icon if provided
        label: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.customButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
    );
  }
}
