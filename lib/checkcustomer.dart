import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/homecustomer.dart';
import 'package:shimmer/main.dart';
class checkcustomer extends StatefulWidget {
  const checkcustomer({super.key});

  @override
  State<checkcustomer> createState() => _checkcustomerState();
}

class _checkcustomerState extends State<checkcustomer> {

  Widget build(BuildContext context) {
    return Scaffold();
  }
  checkuser() async{
    final user=FirebaseAuth.instance.currentUser;
    if(user != Null){
      return homecustomer();
    }
  }
}