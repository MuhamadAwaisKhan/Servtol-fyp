import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/TributeScreen.dart';
import 'package:servtol/aboutsection.dart';
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

      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50,),
            // Inspirations and About section with professional design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Inspirations Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TributeScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.customButton, Colors.indigo],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 3),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.lightbulb, size: 30, color: Colors.white),
                            // SizedBox(height: 10),
                            // Text(
                            //   "Inspirations",
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontFamily: "Poppins",
                            //     fontSize: 15,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // SizedBox(height: 5),
                            // Text(
                            //   "Discover the people behind our success",
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: Colors.white70,
                            //     fontFamily: "Poppins",
                            //     fontSize: 12,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // About Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutCEOScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.customButton, Colors.indigo],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 3),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info, size: 30, color: Colors.white),
                            // SizedBox(height: 10),
                            // Text(
                            //   "About",
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontFamily: "Poppins",
                            //     fontSize: 15,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // SizedBox(height: 5),
                            // Text(
                            //   "Learn more about our vision and mission",
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: Colors.white70,
                            //     fontFamily: "Poppins",
                            //     fontSize: 12,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Logo Section
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
            SizedBox(height: 15),

            // Buttons Section with FontAwesome icons
            uihelper.CustomButton2(
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => loginprovider()),
                );
              },
              "Provider  ",
              40,
              160,
              icon: FontAwesomeIcons.userTie, // Add FontAwesome icon
            ),
            SizedBox(height: 20),
            uihelper.CustomButton2(
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => logincustomer()),
                );
              },
              "Customer",
              40,
              160,
              icon: FontAwesomeIcons.user, // Add FontAwesome icon
            ),
            SizedBox(height: 20),
            uihelper.CustomButton2(
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginAdmin()),
                );
              },
              " Admin     ",
              40,
              160,
              icon: FontAwesomeIcons.userShield, // Add FontAwesome icon
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
