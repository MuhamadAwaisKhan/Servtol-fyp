import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/util/AppColors.dart';
class profilecustomer extends StatefulWidget {
  const profilecustomer({super.key});

  @override
  State<profilecustomer> createState() => _profilecustomerState();
}

class _profilecustomerState extends State<profilecustomer> {
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
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                child: Text('Customer Profile'),
              ),

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              ElevatedButton(
                onPressed: () => logout(context),
                child: Text("Logout"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}