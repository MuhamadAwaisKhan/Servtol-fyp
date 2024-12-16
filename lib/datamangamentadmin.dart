import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/AddTributeScreen.dart';
import 'package:servtol/ReleasePaymentScreen.dart';
import 'package:servtol/aboutadd.dart';
import 'package:servtol/admindashboard.dart';
import 'package:servtol/datachart.dart';
import 'package:servtol/dataprofiles.dart';
import 'package:servtol/loginadmin.dart';
import 'package:servtol/mainmenuInterface.dart';
import 'package:servtol/rules.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class datamanagement extends StatefulWidget {
  const datamanagement({super.key});

  @override
  State<datamanagement> createState() => _datamanagementState();
}

class _datamanagementState extends State<datamanagement> {
  @override
  Widget build(BuildContext context) {
    void logout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginAdmin()));
      Fluttertoast.showToast(msg: "Logged out successfully");
    }

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColors.background,
        // title: (isFirstButtonClicked && !isSecondButtonClicked)
        //     ? Center(
        //         child: Text(
        //           'Provider Portal',
        //           style: TextStyle(
        //             fontFamily: 'Poppins',
        //             fontWeight: FontWeight.bold,
        //             fontSize: 17,
        //             color: AppColors.heading,
        //           ),
        //         ),
        //       )
        //     : (isSecondButtonClicked && !isFirstButtonClicked)
        //         ? Center(
        //           child: Text('Customer Portal',
        //               style: TextStyle(
        //                 fontFamily: 'Poppins',
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 17,
        //                 color: AppColors.heading,
        //               )),
        //         )
        //         : null,
        // Text('Default Title'),
      // ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Lottie.asset(
                  'assets/images/datamanagement.json',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainInterface()));
                },
                "Data Management",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminDashboardScreen()));
                },
                "Dashboard",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReleasePaymentScreen()));
                },
                "Payment Release",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChartScreen()));
                },
                "Graphical Data",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddTributeScreen()));
                },
                "Add Contributor",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RolesAndRegulationsScreen()));
                },
                "Rules & Regulations",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddEditCEOScreen()));
                },
                "Add About",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => dataprofiles()));
                },
                "Profiles",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                () {
                  logout();
                },
                "Log Out",
                40,
                230,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
