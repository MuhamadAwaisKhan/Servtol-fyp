import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/PhoneAuth.dart';
import 'package:servtol/customermain.dart';
import 'package:servtol/emailverify.dart';
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
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      // var user = FirebaseAuth.instance.currentUser;
      // if (user != null)
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => logincustomer()));
    }
  }
  TextEditingController emailcontroller = TextEditingController(text:'lodhiawais123@gmail.com');
  TextEditingController passwordcontroller = TextEditingController(text:'123456789');
  bool _hidePassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  // GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
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

  // Input validation for email and password
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
    // Firebase Authentication to sign in user
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('customer').where('Email', isEqualTo: email).get();

    User? user = userCredential.user;

    if (user != null) {
      // Check if email is verified
      if (!user.emailVerified) {
        await user.sendEmailVerification(); // Optionally resend verification email
        Fluttertoast.showToast(msg: "Your email is not verified. Please verify your email.");

        // Navigate to the EmailVerificationScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              onVerified: () {
                // Navigate to the next screen after email verification
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerMainScreen(onBackPress: () {
                    Navigator.of(context).pop();
                  })),
                );
              },
            ),
          ),
        );

        return;
      }

      // Fetch user data from Firestore using UID for faster lookup
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('customer')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // User found in Firestore
        NotificationService().uploadFcmToken(); // Call FCM token upload after successful login

        // Navigate to the main customer screen
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
      } else {
        // No user found in Firestore
        uihelper.CustomAlertbox(context, "No account found with this email.");
      }
    }
  } on FirebaseAuthException catch (ex) {
    String errorMessage = "An error occurred. Please try again.";
    // Customize error messages based on FirebaseAuthException codes
    if (ex.code == 'user-not-found') {
      errorMessage = "No user found for that email.";
    } else if (ex.code == 'wrong-password') {
      errorMessage = "Wrong password provided for that user.";
    }

    uihelper.CustomAlertbox(context, errorMessage);
  } catch (e) {
    // Catch any other general errors
    print('Login error: ${e.toString()}');
    uihelper.CustomAlertbox(context, "An unexpected error occurred. Please try again.");
  } finally {
    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });
  }
}
  // Future<void> _handleSignIn() async {
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
                  fontSize: 15,
                  color: AppColors.heading,
                ),
              ),
              Text(
                "Missed For A Long Time ",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
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
                            _rememberMe = newValue ?? false;
                          });
                        },
                      ),
                      Text(
                        'Remember Me',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontFamily: 'Poppins',
                          fontSize: 15,
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
                  "Login",40,150),
              SizedBox(
                height: 20,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
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
                height: 28,
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
