import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servtol/main%20login.dart';
import 'package:servtol/startscreen.dart';
import 'package:servtol/tester%20file.dart';
import 'package:servtol/text.dart';
import 'package:servtol/util/theme.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications/notificationmessageservice.dart';


Future <void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // await FirebaseAppCheck.instance.activate(
    //   // webProvider: ReCaptchaV3Provider('your-actual-recaptcha-v3-site-key'),
    //   androidProvider: AndroidProvider.debug,
    //   // appleProvider: AppleProvider.appAttest,
    // );
  } catch (e) {
    print('Failed to initialize Firebase App: $e');
  }

  NotificationService().requestNotificationPermission();
   NotificationService().initLocalNotification();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme:
    // ThemeData(
    //   primarySwatch: Colors.blue,
    //   primaryColor: Colors.blue,
    //   progressIndicatorTheme: ProgressIndicatorThemeData(
    //     color: Colors.blue, // Customize the color of progress indicators
    //     linearMinHeight: 4.0, // Customize the height for linear progress indicators
    //   ),
    //   // primaryTextTheme: TextTheme(
    //   //   titleLarge: TextStyle(color: Colors.blue), // Customize text for titles
    //   //   bodyMedium: TextStyle(color: Colors.blue), // Customize text for body
    //   // ),
    //   primaryIconTheme: IconThemeData(
    //     color: Colors.blue, // Customize the color of icons in the primary theme
    //     size: 24.0, // Customize the size of icons
    //   ),
    //
    //
    // ),
  //    ThemeData(
  //   fontFamily: 'Poppins',
  // ),
    AppTheme.lightTheme,
    // darkTheme: AppTheme.darkTheme,
    // themeMode: ThemeMode.system,

    home:
    // MainMenuScreen(),
      // customermainscreen(),
    // ProfileScreenWidget(),
    // ServToolSplashScreen(),
    // SplashScreen(),
      // ExerciseList(),
    // myapptesting(),
      startingscreen(),
    // MyApp(),
    // FeedbackAndReview(),
    //     tester(),
    //  mainlogin(),
    //   BookServiceScreen(service: widget.service),
  ));
}

