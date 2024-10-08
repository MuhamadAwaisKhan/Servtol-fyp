import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/customermain.dart';
import 'package:servtol/homecustomer.dart';
import 'package:servtol/logincustomer.dart';
import 'package:shimmer/main.dart';
class checkcustomer extends StatefulWidget {
  const checkcustomer({super.key});

  @override
  State<checkcustomer> createState() => _checkcustomerState();
}

class _checkcustomerState extends State<checkcustomer> {

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
        child: CircularProgressIndicator(),
      ),
    );
  }

  void checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerMainScreen(onBackPress: onBackPress)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => logincustomer()));
    }
  }

  void onBackPress() {
    // Define what should happen when the back button is pressed
    Navigator.of(context).pop();
  }
}
