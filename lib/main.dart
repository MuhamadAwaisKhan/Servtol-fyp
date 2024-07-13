import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/profileprovider.dart';
import 'package:servtol/startscreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // theme: AppTheme.lightTheme,
    // darkTheme: AppTheme.darkTheme,
    // themeMode: ThemeMode.system,
    home:
    // ProfileScreenWidget(),
    // ServToolSplashScreen(),
    // SplashScreen(),
      // ExerciseList(),
    // myapptesting(),
     startingscreen(),
  ));
}

