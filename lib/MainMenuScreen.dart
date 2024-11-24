import 'package:flutter/material.dart';
import 'package:servtol/TributeScreen.dart';
import 'package:servtol/datamangamentadmin.dart';
import 'package:servtol/loginadmin.dart';
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
                      },
                "Provider",
                40,
                140,
                   ),
              SizedBox(
                height: 30,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => logincustomer()));
                    },
                "Customer",
                40,
                140,
                   ),
              SizedBox(
                height: 30,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginAdmin()));

                },
                "Admin",
                40,
                140,
               ),
              SizedBox(
                height: 30,
              ),
              uihelper.CustomButton(
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TributeScreen()));
                  },
                "Inspirations",
                40,
                140,
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
