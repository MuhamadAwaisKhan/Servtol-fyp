import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motion_tab_bar/motiontabbar.dart';
import 'dart:async'; // Import to use Timer

import 'package:servtol/bookingprovider.dart';
import 'package:servtol/homeprovider.dart';
import 'package:servtol/paymentprovider.dart';
import 'package:servtol/profileprovider.dart';
import 'package:servtol/servicescreenprovider.dart';
import 'package:servtol/util/AppColors.dart';

class ProviderMainLayout extends StatefulWidget {
  final Function onBackPress;

  ProviderMainLayout({super.key, required this.onBackPress});

  @override
  State<ProviderMainLayout> createState() => _ProviderMainLayoutState();
}

class _ProviderMainLayoutState extends State<ProviderMainLayout>
    with TickerProviderStateMixin {
  int myindex = 0;
  bool _isBackPressedOnce = false; // Flag to track if back is pressed once
  Timer? _backPressTimer; // Timer to reset back press state
  late final List<Widget> widgetlist;
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    _backPressTimer?.cancel(); // Dispose timer if it exists
    super.dispose();
  }

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
    _tabController = TabController(
      initialIndex: 0,
      length: widgetlist.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (myindex == 0) {
          // If back is pressed once
          if (_isBackPressedOnce) {
            // Show logout confirmation dialog
            _backPressTimer?.cancel(); // Cancel timer when dialog shows
            return await _showLogoutDialog();
          } else {
            // Set the flag and start the timer
            _isBackPressedOnce = true;
            _backPressTimer = Timer(const Duration(seconds: 2), () {
              _isBackPressedOnce = false; // Reset after 2 seconds
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back again to log out'),
                duration: Duration(seconds: 2),
              ),
            );
            return false; // Prevent default behavior
          }
        } else {
          // Reset to home screen if not on index 0
          setState(() {
            myindex = 0;
            _tabController.index = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: widgetlist[myindex]),
        bottomNavigationBar: MotionTabBar(
          labels: const ["Home", "Booking", "Payment", "Service", "Profile"],
          initialSelectedTab: "Home",
          tabIconColor: Colors.blueGrey,
          tabSelectedColor: Colors.blue,
          tabSize: 50,
          tabBarHeight: 55,
          onTabItemSelected: (int value) {
            setState(() {
              myindex = value;
              _tabController.index = value;
            });
          },
          icons: const [
            FontAwesomeIcons.home,
            FontAwesomeIcons.calendarCheck,
            FontAwesomeIcons.moneyBillWave,
            FontAwesomeIcons.houseLaptop,
            FontAwesomeIcons.user,
          ],
          textStyle: const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  // Function to show a logout confirmation dialog
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
