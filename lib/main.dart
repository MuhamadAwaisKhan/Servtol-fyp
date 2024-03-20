import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servtol/login.dart';
import 'package:servtol/signup.dart';
import 'package:servtol/testing%20file.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,

    home: signup(),
  ));
}


