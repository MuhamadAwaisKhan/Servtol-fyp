import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/mainmenu.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class mainlogin extends StatefulWidget {
  const mainlogin({super.key});

  @override
  State<mainlogin> createState() => _mainloginState();
}

class _mainloginState extends State<mainlogin> {
  bool isFirstButtonClicked = false;
  bool isSecondButtonClicked = false;

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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainMenuScreen()));
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
            ],
          ),
        ),
      ),
    );
  }
}
