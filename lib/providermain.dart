import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/motiontabbar.dart';

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
  // late TabController _tabController;
  late MotionTabBarController _motionTabBarController;
  bool _isBackPressedOnce = false;
  Timer? _backPressTimer;

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 5, vsync: this);
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );
  }

  @override
  void dispose() {
    // _tabController.dispose();
    _motionTabBarController.dispose();
    _backPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button
        if (_motionTabBarController.index == 0) {
          // If on the first tab
          if (_isBackPressedOnce) {
            _backPressTimer?.cancel();
            return await _showLogoutDialog(); // Show logout dialog
          } else {
            _isBackPressedOnce = true;
            _backPressTimer = Timer(const Duration(seconds: 2), () {
              _isBackPressedOnce = false; // Reset the flag after 2 seconds
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(child: Text('Press back again to log out')),
                duration: Duration(seconds: 2),
              ),
            );
            return false; // Prevent default back navigation
          }
        } else {
          // Navigate back to the first tab
          // _tabController.animateTo(0);
          setState(() {
            _motionTabBarController.index=0;
          });
          return false; // Prevent default back navigation
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: TabBarView(
          controller: _motionTabBarController,
          children: [
            HomeProvider(onBackPress: widget.onBackPress),
            BookingScreenWidget(onBackPress: widget.onBackPress),
            PaymentScreenWidget(onBackPress: widget.onBackPress),
            ServiceScreenWidget(onBackPress: widget.onBackPress),
            ProfileScreenWidget(onBackPress: widget.onBackPress),
          ],
        ),
        bottomNavigationBar: MotionTabBar(
          labels: const ["Home", "Booking", "Payment", "Service", "Profile"],
          initialSelectedTab: "Home",
          controller: _motionTabBarController,
          tabIconColor: Colors.blueGrey,
          tabSelectedColor: Colors.blue,
          tabSize: 50,
          tabBarHeight: 55,
          onTabItemSelected: (int value) {
            // Update the tab controller index
            setState(() {
              _motionTabBarController.index = value;
              // _tabController.animateTo(value);
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
              )
            ],
          ),
        ) ??
        false;
  }
}
