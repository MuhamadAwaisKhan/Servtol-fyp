import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/emailverify.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/providermain.dart';
import 'package:servtol/rules.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class SignupProvider extends StatefulWidget {
  const SignupProvider({Key? key}) : super(key: key);

  @override
  _SignupProviderState createState() => _SignupProviderState();
}

class _SignupProviderState extends State<SignupProvider> {
  final TextEditingController firstController = TextEditingController();
  final TextEditingController lastController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController occuController = TextEditingController();
  bool _hidePassword = true;
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
    cnicController.dispose();
    occuController.dispose();
    super.dispose();
  }

  Future<void> _addData(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('provider').doc(uid).set({
        'UID': uid,
        'FirstName': firstController.text,
        'LastName': lastController.text,
        'Email': emailController.text,
        'Mobile': numberController.text,
        'Username': usernameController.text,
        'CNIC': cnicController.text,
        'Occupation': occuController.text,
        'status': 'Offline',
        'userType':'provider',
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
        cnicController.text.isEmpty ||
        passwordController.text.isEmpty ||
        occuController.text.isEmpty) {
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
        // Send email verification
        await user.sendEmailVerification();
        Fluttertoast.showToast(
            msg: 'Verification email sent. Please verify your email.');

        // Save user data to Firestore
        await _addData(user.uid);

        // Navigate to a confirmation screen or show a message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              onVerified: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProviderMainLayout(
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
        Fluttertoast.showToast(msg: 'Signup successful! Please verify your email.');
      }
    }).catchError((error) {
      String errorMessage = 'Failed to Sign Up. Please try again.';
      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          errorMessage = 'The email is already in use. Try another one.';
        } else if (error.code == 'weak-password') {
          errorMessage = 'The password is too weak. Please use a stronger password.';
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
          padding: EdgeInsets.all(20),
          child: Column(children: [
            Lottie.asset('assets/images/ab2.json', height: 200),
            const SizedBox(height: 22),
            const Text(
              "Hello Provider !",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "Poppins",
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create Your Account for Better Experience",
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Poppins',
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            uihelper.CustomTextField(context, firstController, "First Name",
                Icons.account_circle, false),
            uihelper.CustomTextField(context, lastController, "Last Name",
                Icons.account_circle, false),
            uihelper.CustomTextField(context, usernameController, "User Name",
                Icons.account_circle, false),
            uihelper.CustomTextField(context, occuController, "Occupation",
                Icons.business_center, false),
            uihelper.CustomTextField(
                context, emailController, "Email Address", Icons.email, false),
            uihelper.CustomNumberField(
                context, numberController, "Contact", Icons.phone, false),
            uihelper.CustomNumberField(
                context, cnicController, "CNIC", Icons.card_membership, false),
            uihelper.CustomTextfieldpassword(
                context, passwordController, "Password", _hidePassword,
                (bool value) {
              setState(() {
                _hidePassword = value;
              });
            }),
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
                                  builder: (_) => RolesAndRegulationsScreen(

                              ),
                              ), );
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
                                  builder: (_) => RolesAndRegulationsScreen(

                              ),
                              ), );
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
            if (_isLoading) // Show loading indicator
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            SizedBox(
              height: 15,
            ),
            uihelper.CustomButton(() {
              _signup();
            }, "Sign Up", 50, 190),
            SizedBox(
              height: 15,
            ),
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
                                  loginprovider())); // Replace this with your navigation logic
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
          ]),
        ));
  }
}
