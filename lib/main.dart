import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servtol/customermain.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/profileprovider.dart';
import 'package:servtol/startscreen.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('your-actual-recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );
  } catch (e) {
    print('Failed to initialize Firebase App: $e');
  }


  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // theme: AppTheme.lightTheme,
    // darkTheme: AppTheme.darkTheme,
    // themeMode: ThemeMode.system,
    home:
      // customermainscreen(),
    // ProfileScreenWidget(),
    // ServToolSplashScreen(),
    // SplashScreen(),
      // ExerciseList(),
    // myapptesting(),
      startingscreen(),
  ));
}

