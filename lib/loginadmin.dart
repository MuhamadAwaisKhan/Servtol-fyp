import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/datamangamentadmin.dart';
import 'package:servtol/forgetpassword.dart';
import 'package:servtol/notifications/notificationmessageservice.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController emailcontroller = TextEditingController(text: 'admin@example.com'); // Update with admin email
  TextEditingController passwordcontroller = TextEditingController(text: 'admin123'); // Update with admin password
  bool _hidePassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  void showError(String message) {
    setState(() {
      _isLoading = false;
    });
    uihelper.CustomAlertbox(context, message);
  }
  void login(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    if (email.isEmpty || password.isEmpty) {
      uihelper.CustomAlertbox(context, "Please enter all required fields.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      uihelper.CustomAlertbox(context, "Please enter a valid email address.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // Authentication successful, navigate to the next screen
      NotificationService().uploadFcmToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => datamanagement()),
      );
    } on FirebaseAuthException catch (ex) {
      String errorMessage = "An error occurred. Please try again.";
      if (ex.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      } else if (ex.code == 'wrong-password') {
        errorMessage = "Wrong password provided for that user.";
      }

      uihelper.CustomAlertbox(context, errorMessage);
    } catch (e) {
      print('Login error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Lottie.asset(
              'assets/images/admin.json', // Update with appropriate Lottie animation
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 22),
            Center(
              child: Text(
                "Hello Admin!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.heading,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Welcome Back",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                color: AppColors.heading,
              ),
            ),
            SizedBox(height: 12),
            uihelper.CustomTextField(context, emailcontroller, "Email Address", Icons.email_rounded, false),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.blue;
                        }
                        return Colors.transparent;
                      }),
                      value: _rememberMe,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _rememberMe = newValue ?? false;
                        });
                      },
                    ),
                    Text(
                      'Remember Me',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontFamily: 'Poppins',
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (Context) => forgetpassword()));
                  },
                  child: Text(
                    'Forget Password?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading == true)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            SizedBox(height: 30),
            uihelper.CustomButton(() {
              login(emailcontroller.text.toString().trim(), passwordcontroller.text.toString().trim());
            }, "Login", 40, 150),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}