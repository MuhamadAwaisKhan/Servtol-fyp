import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/loginprovider.dart';

class homeprovider extends StatefulWidget {
  const homeprovider({super.key});

  @override
  State<homeprovider> createState() => _homeproviderState();
}

class _homeproviderState extends State<homeprovider> {

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginprovider()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
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