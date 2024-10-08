import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/PhoneAuth.dart';
import 'package:servtol/customermain.dart';
import 'package:servtol/forgetpassword.dart';
import 'package:servtol/homecustomer.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/notifications/notificationmessageservice.dart';
import 'package:servtol/signupcustomer.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class logincustomer extends StatefulWidget {

   logincustomer({super.key,});

  @override
  State<logincustomer> createState() => _logincustomerState();
}

class _logincustomerState extends State<logincustomer> {

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _hidePassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  // GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
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
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('customer').where('Email', isEqualTo: email).get();

      if (snapshot.docs.isNotEmpty) {
        NotificationService().uploadFcmToken(); // Call FCM token upload after successful login

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CustomerMainScreen(onBackPress: () {
            Navigator.of(context).pop();
          })),
        );
      } else {
        uihelper.CustomAlertbox(context, "No account found with this email.");
      }
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
  }  // Future<void> _handleSignIn() async {
  //   try {
  //     await _googleSignIn.signIn();
  //     // After sign in, you can get the user's information like this:
  //     // print(_googleSignIn.currentUser.displayName);
  //     // print(_googleSignIn.currentUser.email);
  //     // You can navigate to another screen or do further actions here
  //   } catch (error) {
  //     print(error);
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          // title: (isFirstButtonClicked && !isSecondButtonClicked)
          //     ? Center(
          //         child: Text(
          //           'Provider Portal',
          //           style: TextStyle(
          //             fontFamily: 'Poppins',
          //             fontWeight: FontWeight.bold,
          //             fontSize: 17,
          //             color: AppColors.heading,
          //           ),
          //         ),
          //       )
          //     : (isSecondButtonClicked && !isFirstButtonClicked)
          //         ? Center(
          //           child: Text('Customer Portal',
          //               style: TextStyle(
          //                 fontFamily: 'Poppins',
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 17,
          //                 color: AppColors.heading,
          //               )),
          //         )
          //         : null,
          // Text('Default Title'),
        ),
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                'assets/images/customer.json',
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 22),
              Center(
                  child: Text(
                "Hello Customer !",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.heading,
                ),
              )),
              SizedBox(
                height: 12,
              ),
              Text(
                "Welcome Back, You Have Been ",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  color: AppColors.heading,
                ),
              ),
              Text(
                "Missed For A Long Time ",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  color: AppColors.heading,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              uihelper.CustomTextField
                (
                context,
                  emailcontroller, "Email Address", Icons.email_rounded, false),
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
              // SizedBox(
              //   height: 5,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       _rememberMe = !_rememberMe;
                  //     });
                  //   },
                  //   child: Container(
                  //     width: 20.0,
                  //     height: 20.0,
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       border: Border.all(color: Colors.black),
                  //     ),
                  //     child: Center(
                  //       child: _rememberMe
                  //           ? Icon(Icons.check, size: 20.0, color: Colors.black)
                  //           : Container(),
                  //     ),
                  //   ),
                  // ),
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
                        'Remember Me',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontFamily: 'Poppins',
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),

                  // TextButton(
                  //   style: TextButton.styleFrom(
                  //     foregroundColor: Colors.indigo,
                  //
                  //   ),
                  //   onPressed: () {
                  //     // Navigator.pushReplacement(context,
                  //     //     MaterialPageRoute(builder: (Context) => signup()));
                  //   },
                  //   child: Text('Forget Password?',style: TextStyle( fontFamily: 'Poppins', fontWeight:FontWeight.w600, fontSize: 15),),
                  // ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (Context) => forgetpassword()));
                      // Replace the below line with your navigation logic
                      print(
                          "Forget Password tapped"); // Placeholder action, you can replace this line
                      // Navigator.pushReplacement(context,
                      //     MaterialPageRoute(builder: (context) => SignUp())); // Replace this with your navigation logic
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

                  // Text(
                  //    'Forget Password?',
                  //    style: TextStyle(
                  //      color: Colors.indigo,
                  //        fontFamily: 'Poppins', fontWeight:FontWeight.w600, fontSize: 15,
                  //    ),
                  //  ),
                ],
              ),
              if (_isLoading == true) Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue),
              )),
              SizedBox(
                height: 30,
              ),
              uihelper.CustomButton(() {
      login(emailcontroller.text.toString().trim(),
          passwordcontroller.text.toString().trim());

                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => homecustomer()));
      },
                  "Login",50,190),
              SizedBox(
                height: 20,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 38.0),
                    child: Text(
                      "Don't have an account?",
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
                                builder: (Context) => SignupCustomer()));
                        // Replace the below line with your navigation logic
                        print(
                            "Sign Up tapped"); // Placeholder action, you can replace this line
                        // Navigator.pushReplacement(context,
                        //     MaterialPageRoute(builder: (context) => SignUp())); // Replace this with your navigation logic
                      },
                      child: Text(
                        'Sign Up',
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
                height: 18,
              ),

              // uihelper.CustomTextButton(() {
              //   emailcontroller.text = "";
              //   passwordcontroller.text = "";
              // }, "Reset", Icons.cancel_presentation_outlined),

              // Row(children: [
              //   Expanded(child: Divider(  thickness: 2,
              //     indent: 2,
              //     endIndent: 2,
              //     color: AppColors.grey,)),
              //   Padding(
              //       padding: EdgeInsets.only(left: 10, right: 10),
              //       child: Text("Or Continue With",style: TextStyle(
              //         fontSize: 16,
              //         fontFamily: "Poppins"
              //       ),)),
              //   Expanded(child: Divider(
              //     thickness: 2,
              //     indent: 2,
              //     endIndent: 2,
              //     color: AppColors.grey,
              //   )),
              // ]),
              //
              // // Text(
              // //   "-------------------  Or Continue With-------------------",
              //
              // // ),
              // SizedBox(
              //   height: 20,
              // ),
              // uihelper.CustomButton(() {
              //   _handleSignIn;
              //   print("google tapped");
              // }, "Sign In With Google"),
              //
              // SizedBox(
              //   height: 20,
              // ),
              // uihelper.CustomButton(() {
              //   Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneAuth()));
              // }, "Sign In With OTP"),
              //
              //

            ],
          ),
        ));
  }
}
