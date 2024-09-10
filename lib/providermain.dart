import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:servtol/bookingprovider.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/paymentprovider.dart';
import 'package:servtol/profileprovider.dart';
import 'package:servtol/servicescreenprovider.dart';
import 'package:servtol/util/AppColors.dart';
class ProviderMainLayout extends StatefulWidget {
   Function onBackPress;
  ProviderMainLayout({super.key, required this.onBackPress});

  @override
  State<ProviderMainLayout> createState() => _ProviderMainLayoutState();
}

class _ProviderMainLayoutState extends State<ProviderMainLayout> {
  int myindex = 0;
  late final List<Widget> widgetlist;

  @override
  void initState() {
    super.initState();
    widgetlist = [
      HomeProvider(onBackPress: widget.onBackPress),
      BookingScreenWidget(onBackPress: widget.onBackPress),
      PaymentScreenWidget(onBackPress: widget.onBackPress),
      ServiceScreenWidget(onBackPress: widget.onBackPress),
      ProfileScreenWidget(onBackPress: widget.onBackPress),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if the current index is 0 (home tab)
        if (myindex == 0) {
          // If on the home tab, do nothing and do not allow the back action
          return false;
        } else {
          // If not on the home tab, navigate to the home tab
          setState(() {
            myindex = 0;
          });
          return false;  // Intercept the back action
        }
      },
      child: Scaffold(
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
              icon: FaIcon(FontAwesomeIcons.home),
              label: "Home",
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.calendarCheck),
              label: "Booking",
              backgroundColor: Colors.cyan,
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.moneyBillWave),
              label: "Payment",
              backgroundColor: Colors.lightGreenAccent,
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.laptopHouse),
              label: "Service",
              backgroundColor: Colors.indigo,
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user),
              label: "Profile",
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}