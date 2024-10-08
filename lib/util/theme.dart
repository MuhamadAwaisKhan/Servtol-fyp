import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF007BFF); // Example blue
  static const Color secondaryColor = Color(0xFF6C757D); // Example gray
  static const Color accentColor = Color(0xFF28A745); // Example green
  static const Color errorColor = Color(0xFFDC3545); // Example red

  // Fonts
  static const String fontFamily = 'Poppins'; // Or your preferred font

  // Text Styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle bodyText1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
  );

  // You can add more text styles (headline2, subtitle1, etc.)

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue ,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    fontFamily: fontFamily,
    textTheme: const TextTheme(
      displayLarge: headline1,
      bodyLarge: bodyText1,
      // ... other text styles
    ),
    // Add other theme properties like buttonTheme, elevatedButtonTheme, etc.
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    fontFamily: fontFamily,
    textTheme: const TextTheme(
      displayLarge: headline1,
      bodyLarge: bodyText1,
      // ... other text styles
    ),
    // Add other dark theme properties
  );
}