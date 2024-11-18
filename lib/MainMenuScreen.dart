import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/datamangamentadmin.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

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
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue, // Background color
                    ),
                    child: Image.asset('assets/images/startlogo.jpeg'),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => loginprovider()));
                  // setState(() {
                  //   isFirstButtonClicked = false; // Reset first button state
                  //   isSecondButtonClicked =
                  //   !isSecondButtonClicked; // Toggle second button state
                  // });
                },
                "Provider",
                40,
                130,
                // Icons.supervised_user_circle,
                // Colors.grey, // Specify the default color of the icon
                // isSecondButtonClicked, // Pass the clicked state to the button
              ),
              SizedBox(
                height: 30,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => logincustomer()));
                  // setState(() {
                  //   isSecondButtonClicked = false; // Reset second button state
                  //   isFirstButtonClicked =
                  //   !isFirstButtonClicked; // Toggle first button state
                  // });
                },
                "Customer",
                40,
                130,
                // Icons.contacts_sharp,
                // Colors.grey, // Specify the default color of the icon
                // isFirstButtonClicked, // Pass the clicked state to the button
              ),
              SizedBox(
                height: 30,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => datamanagement()));
                  // setState(() {
                  //   isSecondButtonClicked = false; // Reset second button state
                  //   isFirstButtonClicked =
                  //   !isFirstButtonClicked; // Toggle first button state
                  // });
                },
                "Admin",
                40,
                130,
                // Icons.contacts_sharp,
                // Colors.grey, // Specify the default color of the icon
                // isFirstButtonClicked, // Pass the clicked state to the button
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
