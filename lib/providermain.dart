import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int myindex = 0;
  late final List<Widget> widgetlist;
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
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
          return false;
        } else {
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
}
