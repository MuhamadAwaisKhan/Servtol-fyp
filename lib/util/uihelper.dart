import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:servtol/util/AppColors.dart';

class uihelper {
  static customPhoneField(
      BuildContext context,
      TextEditingController controller, String text,
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
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17,color: Colors.blue),
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
          suffixIcon: Icon(iconData,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
    );
  }

  static CustomNumberField(
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
        keyboardType: TextInputType.number, // Set keyboard type to numeric
        obscureText: tohide,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 17,color: Colors.blue),
          suffixIcon: Icon(iconData,
            color: Theme.of(context).primaryColorDark,
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
  static Widget CustomTextfieldpassword1(
      BuildContext context,
      TextEditingController controller,
      String text,
      bool passwordVisible,
      Function(bool) toggleVisibility, {
        String? Function(String?)? validator, // Optional validator parameter
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: TextFormField( // Changed from TextField to TextFormField for validation support
        controller: controller,
        obscureText: !passwordVisible,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 17, color: Colors.blue),
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
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        validator: validator, // Adding validation support
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
              color: Colors.blue,
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
          suffixIcon: Icon(iconData,
          color: Colors.blue,
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

  static detailCard(String title, String value, {bool lastItem = false}) {
    return Card(
      color: Colors.lightBlueAccent.shade200,
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
                      color: AppColors.heading),
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

  static detailCard1(BuildContext context, String title, String value, {bool lastItem = false}) {
    // Define the maximum number of characters before truncation
    const int maxCharacters = 7;

    // Determine if truncation is needed
    bool isTruncated = value.length > maxCharacters;

    // Truncated display text with ellipsis
    String displayText = isTruncated ? "${value.substring(0, maxCharacters)}..." : value;

    return Card(
      color: Colors.lightBlueAccent.shade200,
      margin: EdgeInsets.only(
          top: 10, left: 10, right: 10, bottom: lastItem ? 10 : 15),
      elevation: 2, // Adds a subtle shadow for depth
      child: GestureDetector(
        onTap: () {
          // Show a dialog or bottom sheet with full content
          showDialog(
            context: context, // Pass the context here
            builder: (context) => AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Text(
                  value,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Close"),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: title,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayText,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isTruncated)
                      Text(
                        "Click to view full text",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget actionButton(
      String label, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      // Icon color is white to contrast with button color
      label: Text(label, style: TextStyle(fontFamily: 'Poppins',color: Colors.white)),
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
              labelStyle: TextStyle(color: Colors.blue,fontFamily: 'Poppins'),
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
              filled: true,
              fillColor: AppColors.background,
            ),

        style:
            TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 17),
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
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
  static Widget CustomTextField12(
      BuildContext context,
      TextEditingController controller,
      String text,
      IconData iconData,
      bool toHide, {
        String? Function(String?)? validator, // Optional validator for form validation
        bool isPasswordField = false,        // Flag to indicate password fields
        Function(bool)? toggleVisibility,    // Callback for toggling password visibility
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextFormField(
        controller: controller,
        obscureText: isPasswordField ? toHide : false,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            color: Colors.blue,
          ),
          suffixIcon: isPasswordField
              ? GestureDetector(
            onTap: () {
              if (toggleVisibility != null) {
                toggleVisibility(!toHide);
              }
            },
            child: Icon(
              toHide ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColorDark,
            ),
          )
              : Icon(
            iconData,
            color: Theme.of(context).primaryColorDark,
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        validator: validator, // Added validation support
      ),
    );
  }

  static CustomTextField1(
      BuildContext context,
      TextEditingController controller,
      String text,
      String hinttext,
      IconData iconData,

      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 25),
      child: TextField(
        controller: controller,
        // obscureText: tohide,
        decoration: InputDecoration(
          hintText: hinttext,
          hintStyle:  TextStyle(
              fontFamily: 'Poppins', fontSize: 13, color: Colors.blueGrey),
          labelText: text,
          labelStyle: TextStyle(
              fontFamily: 'Poppins', fontSize: 17, color: Colors.blue),
          suffixIcon: Icon(
            iconData,
            color: Theme.of(context).primaryColorDark,

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

          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 17,color: Colors.blue),
          // suffixIcon: Icon(iconData),
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
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.orange,
                width:
                    2.0), // Optional: Styling for when the TextField has an error
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          // contentPadding: EdgeInsets.only(bottom: 12, left: 115),
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

          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 17,color: Colors.blue),

          // suffixIcon: Icon(iconData),
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
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.orange,
                width:
                    2.0), // Optional: Styling for when the TextField has an error
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          // contentPadding: EdgeInsets.only(bottom: 12, left: 115),
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
