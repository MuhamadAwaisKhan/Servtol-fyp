import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:servtol/bookingcustomer.dart';
import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/chatcustomer.dart';
import 'package:servtol/homecustomer.dart';
import 'package:servtol/logincustomer.dart';
import 'package:servtol/profilecustomer.dart';
import 'package:servtol/util/AppColors.dart';

class CustomerMainScreen extends StatefulWidget {
  final Function onBackPress;

  CustomerMainScreen({Key? key, required this.onBackPress}) : super(key: key);

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen>
    with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;
  bool _isBackPressedOnce = false;
  Timer? _backPressTimer;
  String customerId = ''; // Variable to store customer ID

  @override
  void initState() {
    super.initState();
    _fetchCustomerId();
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
            _motionTabBarController.index = 0;
          });
          return false; // Prevent default back navigation
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: TabBarView(
          controller: _motionTabBarController,
          children: [
            HomeCustomer(onBackPress: widget.onBackPress),
            BookingCustomer(onBackPress: widget.onBackPress),
            CategoriesCustomer(onBackPress: widget.onBackPress),
            CustomerLogScreen(
              onBackPress: widget.onBackPress,
            ),
            profilecustomer(onBackPress: widget.onBackPress),
          ],
        ),
        bottomNavigationBar: MotionTabBar(
          labels: const ["Home", "Booking", "Category", "Chat", "Profile"],
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
            FontAwesomeIcons.house,
            FontAwesomeIcons.calendarCheck,
            FontAwesomeIcons.tableList,
            FontAwesomeIcons.commentDots,
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
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => logincustomer()));
                  Fluttertoast.showToast(msg: "Logged out successfully");
                },
                child: const Text('Logout'),
              )
            ],
          ),
        ) ??
        false;
  }

  Future<void> _fetchCustomerId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('customer')
            .where('customerId', isEqualTo: user.uid)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            customerId = snapshot.docs.first.id;
          });
        } else {
          print('No customer found with the current user\'s email');
        }
      } else {
        print('No user is currently logged in.');
      }
    } catch (e) {
      print('Error fetching customer ID: $e');
    }
  }
}
