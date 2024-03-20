import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  @override
  Widget build(BuildContext context) {
    TextEditingController firstcontroller = TextEditingController();
    TextEditingController lastcontroller = TextEditingController();
    TextEditingController usernamecontroller = TextEditingController();
    TextEditingController emailcontroller = TextEditingController();
    TextEditingController numbercontroller = TextEditingController();
    TextEditingController passwordcontroller = TextEditingController();
    bool _hidePassword = false;
    bool _rememberMe = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
    body: SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: IconButton(
      
              icon: Icon(Icons.account_circle, size: 60),
              onPressed: (){},),
          ),
          Center(
          child: Text(
          "Hello User !",
      style: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: AppColors.heading,
      ))
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            "Create Your Account for Better  ",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              color: AppColors.heading,
            ),
          ),
          Text(
            "Exprience ",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              color: AppColors.heading,
            ),
          ),
          SizedBox(
            height: 12,
          ),
          uihelper.CustomTextfield(
              firstcontroller, "First Name", Icons.account_circle, false),
          uihelper.CustomTextfield(
              lastcontroller, "Last Name", Icons.account_circle, false),
          uihelper.CustomTextfield(
              usernamecontroller, "User Name", Icons.account_circle, false),
          uihelper.CustomTextfield(
              emailcontroller, "Email Address", Icons.email_rounded, false),
              uihelper.customPhoneField(numbercontroller, "Contact Number", Icons.phone_in_talk),

          uihelper.CustomTextfieldpassword(
            context,
            passwordcontroller,
            'Password',
            _hidePassword,
                (bool value) {
              setState(() {
                _hidePassword = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (bool? newValue) {
                  setState(() {
                    _rememberMe = newValue ?? false;
                  });
                },
              ),
              Text(
                'I agree to the ',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Replace the below line with your navigation logic
                  print(
                      "Terms of Services tapped"); // Placeholder action, you can replace this line
                  // Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => SignUp())); // Replace this with your navigation logic
                },
                child: Text(
                  'Terms of Services',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.indigo,
                  ),
                ),
              ),
              Text(
                ' & ',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Replace the below line with your navigation logic
                  print(
                      "Terms of Services tapped"); // Placeholder action, you can replace this line
                  // Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => SignUp())); // Replace this with your navigation logic
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
       uihelper.CustomButton(() { }, "Sign Up"),
          SizedBox(
            height: 15,
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              Padding(
                padding: const EdgeInsets.only(left: 58.0),
                child: Text(
                  "Already have an Account?",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 17,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: GestureDetector(
                  onTap: () {
                    // Replace the below line with your navigation logic
                    print(
                        "Sign Up tapped"); // Placeholder action, you can replace this line
                    // Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (context) => SignUp())); // Replace this with your navigation logic
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 35,
          ),
      ],
      ),
    ),
    );
  }
}
