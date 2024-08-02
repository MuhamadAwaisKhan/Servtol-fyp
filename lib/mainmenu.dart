import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/category.dart';
import 'package:servtol/city.dart';
import 'package:servtol/province.dart';
import 'package:servtol/service.dart';
import 'package:servtol/subcategory.dart';

import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:servtol/wage.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Data Management',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: AppColors.heading,
        ),
      ),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Padding(
    padding: EdgeInsets.all(20.0),
    child:   Lottie.asset(
      'assets/images/data.json',
      height: 200,
      fit: BoxFit.cover,
    ),
    ),
    SizedBox(
    height: 20,
    ),
      uihelper.CustomButton(
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => servicetype()));

        },
        "Service Type",
        40,
        150,
        // Icons.contacts_sharp,
        // Colors.grey, // Specify the default color of the icon
        // isFirstButtonClicked, // Pass the clicked state to the button
      ),
    SizedBox(
    height: 20,
    ),
      uihelper.CustomButton(
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => WageTypeListScreen()));

        },
        "Wage Type",
        40,
        150,
        // Icons.contacts_sharp,
        // Colors.grey, // Specify the default color of the icon
        // isFirstButtonClicked, // Pass the clicked state to the button
      ),
      SizedBox(
        height: 20,
      ),
      uihelper.CustomButton(
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => categoryscreen()));

        },
        "Category",
        40,
        150,
        // Icons.contacts_sharp,
        // Colors.grey, // Specify the default color of the icon
        // isFirstButtonClicked, // Pass the clicked state to the button
      ),
      SizedBox(
        height: 20,
      ),
      uihelper.CustomButton(
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SubcategoryScreen()));

        },
        "Sub-category",
        40,
        150,
        // Icons.contacts_sharp,
        // Colors.grey, // Specify the default color of the icon
        // isFirstButtonClicked, // Pass the clicked state to the button
      ),
      SizedBox(
        height: 20,
      ),
      uihelper.CustomButton(
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => province()));

        },
        "Province",
        40,
        150,
        // Icons.contacts_sharp,
        // Colors.grey, // Specify the default color of the icon
        // isFirstButtonClicked, // Pass the clicked state to the button
      ),
      SizedBox(
        height: 20,
      ),
      uihelper.CustomButton(
            () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CityScreen()));

        },
        "City",
        40,
        150,
        // Icons.contacts_sharp,
        // Colors.grey, // Specify the default color of the icon
        // isFirstButtonClicked, // Pass the clicked state to the button
      ),
    ],
    ),
    ),
    );
  }
}
