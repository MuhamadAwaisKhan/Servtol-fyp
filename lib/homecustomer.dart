import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/util/AppColors.dart';

class homecustomer extends StatefulWidget {
  const homecustomer({super.key});

  @override
  State<homecustomer> createState() => _homecustomerState();
}

class _homecustomerState extends State<homecustomer> {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => logincustomer()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => logout(context),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
