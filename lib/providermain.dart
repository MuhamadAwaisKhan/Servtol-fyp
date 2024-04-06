import 'package:flutter/material.dart';
import 'package:servtol/bookingprovider.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/profileprovider.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:servtol/paymentprovider.dart';
import 'serviceprovider.dart';

class providermainlayout extends StatefulWidget {
  const providermainlayout({super.key});

  @override
  State<providermainlayout> createState() => _providermainlayoutState();
}

class _providermainlayoutState extends State<providermainlayout> {
  int myindex = 0;
  final List<Widget> widgetlist = const[
    homeprovider(),
    BookingScreenWidget(),
    PaymentScreenWidget(),
    ServiceScreenWidget(),
    ProfileScreenWidget(),

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
                    icon: Icon(Icons.payment_rounded),
                    label: "Payment",
                    backgroundColor: Colors.lightGreenAccent,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_repair_service),
                    label: "Service",
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
