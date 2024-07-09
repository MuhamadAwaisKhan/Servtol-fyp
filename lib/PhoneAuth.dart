// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:servtol/OtpScreen.dart';
// import 'package:servtol/util/AppColors.dart';
// import 'package:servtol/util/uihelper.dart';
//
// class PhoneAuth extends StatefulWidget {
//   const PhoneAuth({Key? key}) : super(key: key);
//
//   @override
//   State<PhoneAuth> createState() => _PhoneAuthState();
// }
//
// class _PhoneAuthState extends State<PhoneAuth> {
//   TextEditingController phoneController = TextEditingController();
//
//   void sendOTP() async {
//     String phone = "+91" + phoneController.text.trim();
//
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: phone,
//       codeSent: (verificationId, resendToken) {
//         Navigator.push(
//           context,
//           // MaterialPageRoute(
//           //   builder: (context) => OTPScreen(verificationId: verificationId),
//           // ),
//         // );
//       },
//       verificationCompleted: (credential) {},
//       verificationFailed: (ex) {
//         print(ex.code.toString());
//       },
//       codeAutoRetrievalTimeout: (verificationId) {},
//       timeout: Duration(seconds: 30),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         centerTitle: true,
//         title: Text("Sign In with Phone"),
//       ),
//       backgroundColor: AppColors.background,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           uihelper.CustomTextField(
//              phoneController,
//            "Enter Phone Number",
//             Icons.call,
//              false,
//           ),
//
//           uihelper.CustomButton(() async
//
//             {
//               sendOTP();
//             },
//             "Verify Phone",30,140,
//           ),
//         ],
//       ),
//     );
//   }
// }
