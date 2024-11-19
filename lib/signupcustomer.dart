import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/customermain.dart';

import 'homecustomer.dart';
import 'logincustomer.dart';
import 'util/AppColors.dart';
import 'util/uihelper.dart';

class SignupCustomer extends StatefulWidget {
  const SignupCustomer({Key? key}) : super(key: key);

  @override
  State<SignupCustomer> createState() => _SignupCustomerState();
}

class _SignupCustomerState extends State<SignupCustomer> {
  final TextEditingController firstController = TextEditingController();
  final TextEditingController lastController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _hidePassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    firstController.dispose();
    lastController.dispose();
    usernameController.dispose();
    emailController.dispose();
    numberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _addData(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('customer').doc(uid).set({
        'UID': uid,
        'FirstName': firstController.text,
        'LastName': lastController.text,
        'Email': emailController.text,
        'Mobile': numberController.text,
        'Username': usernameController.text,
        'status': 'Offline',
      });
      Fluttertoast.showToast(msg: 'Account Created Successfully');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CustomerMainScreen(onBackPress: () {
                    Navigator.of(context).pop();
                  })));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to Create Account: $e');
    }
  }

  void _signup() {
    if (!_rememberMe) {
      Fluttertoast.showToast(
          msg: 'You must agree to the terms and conditions.');
      return;
    }
    if (firstController.text.isEmpty ||
        lastController.text.isEmpty ||
        emailController.text.isEmpty ||
        numberController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all the fields.');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((UserCredential userCredential) {
      _addData(userCredential.user!.uid);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'Failed to Sign Up: ${error.message}');
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
        ),
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Lottie.asset(
                  'assets/images/ab2.json', // Ensure this path is correct
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 22),
                const Text(
                  "Hello Customer !",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Create Your Account for Better Experience",

                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "Poppins",

                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 12),
                uihelper.CustomTextField(
                  context,
                  firstController,
                  "First Name",
                  Icons.account_circle,
                  false,
                ),
                uihelper.CustomTextField(context, lastController, "Last Name",
                    Icons.account_circle, false),
                uihelper.CustomTextField(
                  context,
                  usernameController,
                  "User Name",
                  Icons.account_circle,
                  false,
                ),
                uihelper.CustomTextField(
                  context,
                  emailController,
                  "Email Address",
                  Icons.email,
                  false,
                ),
                uihelper.CustomNumberField(context,
                    numberController, "Contact Number", Icons.phone, false),
                uihelper.CustomTextfieldpassword(
                  context,
                  passwordController,
                  'Password',
                  _hidePassword,
                  (bool value) {
                    setState(() {
                      _hidePassword = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 58.0),
                  child: Row( mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.blue;
                            // Color when checkbox is checked
                          }
                          return Colors.transparent; // Color when checkbox is unchecked
                        }),
                        value: _rememberMe,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _rememberMe = newValue!;
                          });
                        },
                      ),
                      SizedBox(width: 8), // Adds some space between the checkbox and the text
                      RichText(
                        text: TextSpan(
                          text: 'Agree to ', // First part of the text
                          style: TextStyle(color: Colors.black), // Default style for the first part
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Terms', // Clickable text "Terms"
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                // Handle tap for both "Terms & Conditions"
                                print("Terms & Conditions tapped");
                              },
                            ),
                            TextSpan(
                              text: ' & ', // Non-clickable text "&"
                              style: TextStyle(color: Colors.black), // Color stays black
                            ),
                            TextSpan(
                              text: 'Conditions', // Clickable text "Conditions"
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                // Handle tap for both "Terms & Conditions"
                                print("Terms & Conditions tapped");
                              },
                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                SizedBox(
                  height: 15,
                ),
                uihelper.CustomButton(() {
                  print("Signup button tapped");
                  _signup();

                  // print("Entered phone number: ${numbercontroller.text}");
                }, "Sign Up", 50, 190),
                SizedBox(height: 15),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      logincustomer())); // Replace this with your navigation logic
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
                const SizedBox(height: 35),
              ],
            ),
          ),
        ));
  }
}
