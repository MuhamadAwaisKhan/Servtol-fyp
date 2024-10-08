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
  final Function onBackPress;

  customermainscreen({Key? key, required this.onBackPress}) : super(key: key);

  @override
  State<customermainscreen> createState() => _customermainscreenState();
}

class _customermainscreenState extends State<customermainscreen> {
  int myindex = 0;
  late List<Widget> widgetlist ;
  @override
  void initState() {
    super.initState();
    widgetlist = [
      HomeCustomer( onBackPress: widget.onBackPress,),
      BookingCustomer(
        onBackPress: widget.onBackPress,
      ),
      CategoriesCustomer( onBackPress: widget.onBackPress,),
      chatcustomer(onBackPress: widget.onBackPress,),
      profilecustomer(onBackPress: widget.onBackPress,),
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
            return false; // Intercept the back action
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
                  icon: FaIcon(FontAwesomeIcons.thList),
                  label: "Categories",
                  backgroundColor: Colors.lightGreenAccent,
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.commentDots),
                  label: "Chat",
                  backgroundColor: Colors.indigo,
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.user),
                  label: "Profile",
                  backgroundColor: Colors.red,
                ),
              ]),
        )
    );
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              // Perform logout or any other action here
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    ) ?? false;
  }
}
