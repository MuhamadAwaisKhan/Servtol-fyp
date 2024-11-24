import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:servtol/AddTributeScreen.dart';
import 'package:servtol/admindashboard.dart';
import 'package:servtol/dash2.dart';
import 'package:servtol/datachart.dart';
import 'package:servtol/mainmenuInterface.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
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
      ),
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
          ), ),
              SizedBox(
                height: 15,
              ),

              uihelper.CustomButton(
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainInterface()));
                },
                "Data Management",
                40,
                200,
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
                200,
              ),
              SizedBox(
                height: 20,
              ),
              uihelper.CustomButton(
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChartScreen()));
                },
                "Graphical Data",
                40,
                200,
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
                200,
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
