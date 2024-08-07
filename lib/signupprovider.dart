import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/providermain.dart';
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
      });
      Fluttertoast.showToast(msg: 'Account Created Successfully');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProviderMainLayout(onBackPress: () {
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
        cnicController.text.isEmpty ||
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
          title: Text('Sign Up as Provider'),
        ),
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            Lottie.asset('assets/images/ab2.json', height: 200),
            SizedBox(height: 20),
            Text("Hello Provider!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 10),
            Text("Create Your Account for a Better Experience",
                textAlign: TextAlign.center),
            SizedBox(height: 20),
            uihelper.CustomTextField(
                firstController, "First Name", Icons.account_circle, false),
            uihelper.CustomTextField(
                lastController, "Last Name", Icons.account_circle, false),
            uihelper.CustomTextField(
                usernameController, "User Name", Icons.account_circle, false),
            uihelper.CustomTextField(
                emailController, "Email Address", Icons.email, false),
            uihelper.CustomNumberField(
                numberController, "Contact", Icons.phone, false),
            uihelper.CustomNumberField(
                cnicController, "CNIC", Icons.card_membership, false),
            uihelper.CustomTextfieldpassword(
                context, passwordController, "Password", _hidePassword,
                (bool value) {
              setState(() {
                _hidePassword = value;
              });
            }),
            CheckboxListTile(
              value: _rememberMe,
              onChanged: (bool? newValue) {
                setState(() {
                  _rememberMe = newValue!;
                });
              },
              title: Text("Agree to Terms and Conditions"),
              controlAffinity: ListTileControlAffinity
                  .leading, // Ensures the checkbox is on the left
            ),
            if (_isLoading) // Show loading indicator
              Center(
                child: CircularProgressIndicator(),
              ),
            SizedBox(
              height: 25,
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
