import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/customermain.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/providermain.dart';
import 'package:servtol/util/AppColors.dart';

class EmailVerificationScreen extends StatefulWidget {

  final VoidCallback onVerified; // Callback when email is verified
  const EmailVerificationScreen({Key? key, required this.onVerified, }) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Verify Email", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold,color: AppColors.heading)),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation for email verification
              Lottie.asset('assets/images/emailverify.json', height: 150),

              const SizedBox(height: 20),
              const Text(
                "A verification email has been sent to your email address. Please check your inbox.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 30),

              // Check verification button with FontAwesome icon
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkEmailVerification,
                icon: _isChecking
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Icon(FontAwesomeIcons.checkCircle),
                label: const Text("Check Verification Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Resend email button
              ElevatedButton.icon(
                onPressed: _isResending ? null : _resendVerificationEmail,
                icon: _isResending
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Icon(FontAwesomeIcons.envelope),
                label: const Text("Resend Verification Email"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                ),
              ),
               SizedBox(height: 20),

              // Cancel Button with FontAwesome Icon
              TextButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context); // Navigate back to login or previous screen
                },
                icon: Icon(
                  FontAwesomeIcons.timesCircle,
                  color: Colors.white, // Icon color
                ),
                label: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontFamily: 'Poppins', // Poppins font
                    fontSize: 16, // Optional: adjust font size
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red, // Button background color
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                  // ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
  Future<void> _checkEmailVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        Fluttertoast.showToast(msg: "Email verified successfully!");

        // Determine if the user is a customer or provider
        bool isProvider = await _checkIfUserIsProvider(user.uid);

        if (isProvider) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => loginprovider()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => logincustomer()));
        }
      } else {
        Fluttertoast.showToast(msg: "Email is not verified yet.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error checking verification status: $e");
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }


  Future<bool> _checkIfUserIsProvider(String userId) async {
    try {
      // Check in 'provider' collection
      DocumentSnapshot providerDoc = await FirebaseFirestore.instance
          .collection('provider')
          .doc(userId)
          .get();

      if (providerDoc.exists) {
        // User is a provider
        return true;
      }

      // Check in 'customer' collection
      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('customer')
          .doc(userId)
          .get();

      if (customerDoc.exists) {
        // User is a customer
        return false;
      }

      // If no document is found in either collection
      print("User not found in any collection");
      return false; // Or handle this case as needed

    } catch (e) {
      print("Error checking user type: $e");
      return false; // Return false in case of an error
    }
  }


  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        Fluttertoast.showToast(msg: "Verification email sent successfully!");
      } else {
        Fluttertoast.showToast(msg: "No user logged in.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error resending verification email: $e");
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }
}
