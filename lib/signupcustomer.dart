import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:servtol/customermain.dart';
import 'package:servtol/emailverify.dart';
import 'package:servtol/rules.dart';

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
// Formatter for phone number: 0300-0000000
  final phoneFormatter = MaskTextInputFormatter(
    mask: '####-#######',
    filter: {"#": RegExp(r'[0-9]')},
  );

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
        'FirstName': firstController.text.trim(),
        'LastName': lastController.text.trim(),
        'Email': emailController.text.trim(),
        'Mobile': numberController.text.trim(),
        'Username': usernameController.text.trim(),
        'status': 'Offline',
        'userType': 'customer',
        'CreatedAt': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(msg: 'Account Created Successfully');
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

    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text.trim())) {
      Fluttertoast.showToast(msg: 'Please enter a valid email address.');
      return;
    }

    if (passwordController.text.length < 6) {
      Fluttertoast.showToast(
          msg: 'Password must be at least 6 characters long.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((UserCredential userCredential) async {
      User? user = userCredential.user;
      if (user != null) {
        // Add user data to Firestore
        await _addData(user.uid);

        // Send email verification
        await user.sendEmailVerification();
        Fluttertoast.showToast(
            msg: 'Verification email sent. Please verify your email.');
        // Add user data to Firestore
        await _addData(user.uid);
        // Navigate to the EmailVerificationScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              onVerified: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerMainScreen(
                      onBackPress: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );

        Fluttertoast.showToast(
            msg: 'Signup successful! Please verify your email.');
      }
    }).catchError((error) {
      String errorMessage = 'Failed to Sign Up. Please try again.';
      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          errorMessage = 'The email is already in use. Try another one.';
        } else if (error.code == 'weak-password') {
          errorMessage =
              'The password is too weak. Please use a stronger password.';
        }
      }
      Fluttertoast.showToast(msg: errorMessage);
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
                    fontSize: 17,
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
                  textAlign: TextAlign.center,
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
                uihelper.CustomNumberField1(
                  context,
                  numberController,
                  "Phone Number",
                  Icons.phone,
                  false,
                  "0300-0000000",
                  phoneFormatter, // Apply the phone number formatter
                ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.blue;
                            // Color when checkbox is checked
                          }
                          return Colors
                              .transparent; // Color when checkbox is unchecked
                        }),
                        value: _rememberMe,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _rememberMe = newValue!;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      // Adds some space between the checkbox and the text
                      RichText(
                        text: TextSpan(
                          text: 'Agree to ',
                          // First part of the text
                          style: TextStyle(color: Colors.black),
                          // Default style for the first part
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Terms', // Clickable text "Terms"
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RolesAndRegulationsScreen(),
                                      ));
                                  // Handle tap for both "Terms & Conditions"
                                  print("Terms & Conditions tapped");
                                },
                            ),
                            TextSpan(
                              text: ' & ', // Non-clickable text "&"
                              style: TextStyle(
                                  color: Colors.black), // Color stays black
                            ),
                            TextSpan(
                              text: 'Conditions', // Clickable text "Conditions"
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RolesAndRegulationsScreen(),
                                    ),
                                  ); // Handle tap for both "Terms & Conditions"
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
                }, "Sign Up", 40, 150),
                SizedBox(height: 15),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Already have an Account?",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
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
