import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:servtol/homeprovider.dart';
import 'package:shimmer/main.dart';
class checkprovider extends StatefulWidget {
  const checkprovider({super.key});

  @override
  State<checkprovider> createState() => _checkproviderState();
}

class _checkproviderState extends State<checkprovider> {

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
  checkuser() async{
    final user=FirebaseAuth.instance.currentUser;
    if(user != Null){
      return homeprovider();
    }
  }
