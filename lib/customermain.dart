import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:servtol/bookingcustomer.dart';
import 'package:servtol/categoriescustomer.dart';
import 'package:servtol/chatcustomer.dart';
import 'package:servtol/homecustomer.dart';
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
  int myIndex = 0; // Store the current index
  bool _isBackPressedOnce = false; // Flag to track if back is pressed once
  Timer? _backPressTimer; // Timer to reset back press state
  late final List<Widget> widgetList;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    widgetList = [
      HomeCustomer(onBackPress: widget.onBackPress),
      BookingCustomer(onBackPress: widget.onBackPress),
      CategoriesCustomer(onBackPress: widget.onBackPress),
      chatcustomer(onBackPress: widget.onBackPress),
      profilecustomer(onBackPress: widget.onBackPress),
    ];

    // Initialize TabController
    _tabController = TabController(
      length: widgetList.length,
      vsync: this,
    );

    // Add a listener to update the index whenever the tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          myIndex = _tabController.index; // Sync with the current tab index
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backPressTimer?.cancel(); // Dispose timer if it exists
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index == 0) {
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
                content: Center(child: Text('Press back again to log out')),
                duration: Duration(seconds: 2),
              ),
            );
            return false; // Prevent default behavior
          }
        } else {
          // Reset to home screen if not on index 0
          // _tabController.animateTo(0); // Animate to the first tab
          setState(() {
            myIndex = 0; // Upd
            // await Future.delayed(Duration.zero);
            // WidgetsBinding.instance.addPostFrameCallback((_) {
              _tabController.index = 0;
            });// ate myIndex
          // });


          return false; // Prevent default back navigation
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: widgetList[myIndex]), // Show the current widget
        bottomNavigationBar: MotionTabBar(
          labels: const ["Home", "Booking", "Category", "Chat", "Profile"],
          initialSelectedTab: "Home",
          tabIconColor: Colors.blueGrey,
          tabSelectedColor: Colors.blue,
          tabSize: 50,
          tabBarHeight: 55,
          onTabItemSelected: (int value) {
            setState(() {
              myIndex = value; // Update myIndex
              _tabController
                  .animateTo(value); // Use animateTo for smooth transition
            });
          },
          icons: const [
            FontAwesomeIcons.home,
            FontAwesomeIcons.calendarCheck,
            FontAwesomeIcons.thList,
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
                onPressed: () {
                  Navigator.of(context).pop(true);
                  // Perform logout or any other action here
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
