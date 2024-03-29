import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/main%20login.dart';
import 'package:servtol/signupcustomer.dart';
import 'package:servtol/signupmain.dart';
import 'package:servtol/signupprovider.dart';
import 'package:servtol/testing%20file.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,

    home: mainlogin(),
  ));
}


