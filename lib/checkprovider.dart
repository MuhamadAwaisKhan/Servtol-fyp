import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/providermain.dart';
import 'package:shimmer/main.dart';
class checkprovider extends StatefulWidget {
  const checkprovider({super.key});

  @override
  State<checkprovider> createState() => _checkproviderState();
}

class _checkproviderState extends State<checkprovider> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator while checking
      ),
    );
  }

  void checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If the user is logged in, redirect to the main layout
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>providermainlayout()));
    } else {
      // If not logged in, redirect to login screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>loginprovider()));
    }
  }
}