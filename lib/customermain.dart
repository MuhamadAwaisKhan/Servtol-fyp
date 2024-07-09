import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/bookingcustomer.dart';
import 'package:servtol/bookingprovider.dart';
import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/chatcustomer.dart';
import 'package:servtol/homecustomer.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/profilecustomer.dart';
import 'package:servtol/profileprovider.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/paymentprovider.dart';
import 'servicescreenprovider.dart';

class customermainscreen extends StatefulWidget {
  const customermainscreen({super.key});

  @override
  State<customermainscreen> createState() => _customermainscreenState();
}

class _customermainscreenState extends State<customermainscreen> {


  int myindex = 0;
  final List<Widget> widgetlist = const[
    // HomeCustomer(),
    bookingcustomer(),
    Categoriescustomer(),
    chatcustomer(),
    profilecustomer(),

    // Text("Home",style: TextStyle(fontSize: 20),),
    // Text("Booking",style: TextStyle(fontSize: 20),),
    // Text("Payment",style: TextStyle(fontSize: 20),),
    // Text("Service",style: TextStyle(fontSize: 20),),
    // Text("Profile",style: TextStyle(fontSize: 20),),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.background,
      body: Center(child: widgetlist[myindex]),
      bottomNavigationBar:
      BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          // showSelectedLabels: ,
          backgroundColor: AppColors.background,
          // showUnselectedLabels:false ,
          onTap: (index) {
            setState(() {
              myindex = index;
            });
          },
          currentIndex: myindex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_outlined),
              label: "Booking",
              backgroundColor: Colors.cyan,
            ),
            BottomNavigationBarItem(
              icon: FaIcon(Icons.category_rounded),
              label: "Categories",
              backgroundColor: Colors.lightGreenAccent,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: "Chat",
              backgroundColor: Colors.indigo,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
              backgroundColor: Colors.red,
            ),

          ]),
    );
  }
}
