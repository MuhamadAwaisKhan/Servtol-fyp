import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/bookingprovider.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/profileprovider.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:servtol/paymentprovider.dart';
import 'servicescreenprovider.dart';

class ProviderMainLayout extends StatefulWidget {
  Function onBackPress; // Making this final and required
  ProviderMainLayout({super.key, required this.onBackPress});

  @override
  State<ProviderMainLayout> createState() => _ProviderMainLayoutState();
}

class _ProviderMainLayoutState extends State<ProviderMainLayout> {
  int myindex = 0;
  late final List<Widget> widgetlist; // Late and initialized in initState
  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    widgetlist = [
      HomeProvider( ),
      BookingScreenWidget(backPress: widget.onBackPress),
      // Corrected callback usage
      PaymentScreenWidget(backPress: widget.onBackPress),
      ServiceScreenWidget(),
      ProfileScreenWidget(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    widget.onBackPress = () {
      if (myindex == 0){

      }
        // Navigator.pop(context);
      else {
        setState(() {
          myindex = 0;
        });
      }
    };
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: widgetlist[myindex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        onTap: (index) {
          setState(() {
            myindex = index;
          });
        },
        currentIndex: myindex,
        items: const [
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
        ],
      ),
    );
  }
}
