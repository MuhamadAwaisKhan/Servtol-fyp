import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class loginuser extends StatefulWidget {
  const loginuser({super.key});

  @override
  State<loginuser> createState() => _loginuserState();
}

class _loginuserState extends State<loginuser> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _hidePassword = false;
  bool _rememberMe = false;
  bool isFirstButtonClicked = false;
  bool isSecondButtonClicked = false;

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
              uihelper.CustomTextField(
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
              SizedBox(
                height: 5,
              ),
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
              SizedBox(
                height: 30,
              ),
              uihelper.CustomButton(() {}, "Login"),
              SizedBox(
                height: 20,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 58.0),
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
            ],
          ),
        ));
  }
}
