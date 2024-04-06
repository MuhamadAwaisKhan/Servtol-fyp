import 'package:flutter/material.dart';
import 'package:servtol/addservices.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';

class ServiceScreenWidget extends StatefulWidget {
  const ServiceScreenWidget({Key? key}) : super(key: key);

  @override
  State<ServiceScreenWidget> createState() => _ServiceScreenWidgetState();
}

class _ServiceScreenWidgetState extends State<ServiceScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Services",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.category_rounded),
            onPressed: () {

            },
          ),
          IconButton(
            icon: Icon(Icons.add_box_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>servicesaddition()));

            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            uihelper.CustomButton(
                  () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (Context) => physicalservices()));
              },
              "Physical ",
              40,
              150,
              // Icons.supervised_user_circle,
              // Colors.grey, // Specify the default color of the icon
              // isSecondButtonClicked, // Pass the clicked state to the button
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(), // This SizedBox is used only to create space
            ),
            uihelper.CustomButton(
                  () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         // builder: (Context) => digitalservices()));
              },
              "Digital ",
              40,
              150,
              // Icons.contacts_sharp,
              // Colors.grey, // Specify the default color of the icon
              // isFirstButtonClicked, // Pass the clicked state to the button
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(), // This SizedBox is used only to create space
            ),
            uihelper.CustomButton(
                  () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (Context) => hybridservices()));
              },
              "Hybrid ",
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
