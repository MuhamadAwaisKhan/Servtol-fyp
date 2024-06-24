import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/homecustomer.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:servtol/util/uihelper.dart';

class signupcustomer extends StatefulWidget {
  const signupcustomer({super.key});

  @override
  State<signupcustomer> createState() => _signupcustomerState();
}

class _signupcustomerState extends State<signupcustomer> {
  TextEditingController firstcontroller = TextEditingController();
  TextEditingController lastcontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController numbercontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _hidePassword = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    Future<void> _addData(String fname,
        String lname,
        String mobile,
        String username,
        String email,) async {
      try {
        await FirebaseFirestore.instance.collection('customer').add({
          fname = 'FirstName': firstcontroller.text,
          lname = 'LastName': lastcontroller.text,
          email = 'email': emailcontroller.text,
          mobile = 'mobile': numbercontroller.text,
          username = 'Username': usernamecontroller.text,
          // Add more fields as needed
        }).then((value) {
        firstcontroller.clear();
            lastcontroller.clear();
        usernamecontroller.clear();
        emailcontroller.clear();
        numbercontroller.clear();
        // Show a success message or navigate to a different screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account Created successfully')),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeCustomer()));
      });
      // Reset text fields after data is added

      } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to Created Account: $e')),
      );
      }
    }

    signup({required String email,
      required String password,
      required String fname,
      required String lname,
      required String mobile,
      required String username}) async {
      print("Signup function called");
      if (fname != "" && lname != "" && mobile != "" && username != "") {
        try {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password)
              .then((value) {
            print("Sign up complete");
            _addData(
              firstcontroller.text.toString().trim(),
              lastcontroller.text.toString().trim(),
              usernamecontroller.text.toString().trim(),
              emailcontroller.text.toString().trim(),
              mobile="+92"+ numbercontroller.text.trim(),
            );
          });
        } on FirebaseAuthException catch (ex) {
          return uihelper.CustomAlertbox(context, ex.code.toString());
        }
      } else {
        if (fname == "") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid first Name')),
          );
        }
        if (lname == "") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid last name')),
          );
        }
        if (mobile == "") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid mobile number')),
          );
        }

        if (username == "") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid userName')),
          );
        }
      }
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
        ),
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: IconButton(
                icon: Icon(Icons.account_circle, size: 60),
                onPressed: () {},
              ),
            ),
            Center(
                child: Text("Hello Customer !",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.heading,
                    ))),
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
            uihelper.CustomTextField(
                firstcontroller, "First Name", Icons.account_circle, false),
            uihelper.CustomTextField(
                lastcontroller, "Last Name", Icons.account_circle, false),
            uihelper.CustomTextField(
                usernamecontroller, "User Name", Icons.account_circle, false),
            uihelper.CustomTextField(
                emailcontroller, "Email Address", Icons.email_rounded, false),
            uihelper.CustomNumberField(
                numbercontroller, "Contact Number", Icons.phone_in_talk,false),
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: InputDecorator(
            //     decoration: InputDecoration(
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(25),
            //       ),
            //       contentPadding: const EdgeInsets.all(20),
            //     ),)
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
                    fontSize: 9,
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
                      fontSize: 9,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                Text(
                  ' & ',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 9,
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
                      fontSize: 9,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
            uihelper.CustomButton(() {

              print("Signup button tapped");
              signup(
                email: emailcontroller.text.toString().trim(),
                password: passwordcontroller.text.toString(),
                fname: firstcontroller.text.toString().trim(),
                lname: lastcontroller.text.toString().trim(),
                mobile: emailcontroller.text.toString().trim(),
                username: usernamecontroller.text.toString().trim(),
              );

              // print("Entered phone number: ${numbercontroller.text}");
            }, "Sign Up",50,190),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => logincustomer()));
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
          ]),
        ));
  }
}
