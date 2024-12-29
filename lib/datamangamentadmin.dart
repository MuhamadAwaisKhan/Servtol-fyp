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

class DataManagement extends StatefulWidget {
  const DataManagement({super.key});

  @override
  State<DataManagement> createState() => _DataManagementState();
}

class _DataManagementState extends State<DataManagement> {
  @override
  Widget build(BuildContext context) {
    void logout() async {
      bool shouldLogout = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log Out'),
            ),
          ],
        ),
      );

      if (shouldLogout ?? false) {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginAdmin()),
        );
        Fluttertoast.showToast(msg: "Logged out successfully");
      }
    }

    return WillPopScope(
      onWillPop: () async {
        bool shouldLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Log Out'),
              ),
            ],
          ),
        );

        if (shouldLogout ?? false) {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginAdmin()),
          );
          Fluttertoast.showToast(msg: "Logged out successfully");
        }

        return Future.value(false); // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Lottie.asset(
                    'assets/images/datamanagement.json',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 15),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainInterface()),
                    );
                  },
                  "Data Management",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminDashboardScreen()),
                    );
                  },
                  "Dashboard",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReleasePaymentScreen()),
                    );
                  },
                  "Payment Release",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChartScreen()),
                    );
                  },
                  "Graphical Data",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddTributeScreen()),
                    );
                  },
                  "Add Contributor",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RolesAndRegulationsScreen()),
                    );
                  },
                  "Rules & Regulations",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddEditCEOScreen()),
                    );
                  },
                  "Add About",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => dataprofiles()),
                    );
                  },
                  "Profiles",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
                uihelper.CustomButton(
                      () {
                    logout();
                  },
                  "Log Out",
                  40,
                  230,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
