import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:servtol/NotificationProvider.dart';
import 'package:servtol/ServiceScreenDetail.dart';
import 'package:servtol/chatprovider.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/servicescreenprovider.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeProvider extends StatefulWidget {
  HomeProvider({super.key});

  @override
  State<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends State<HomeProvider> {
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Initial loading text

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _userName = 'No user logged in';
      });
      return; // Exit if no user is logged in
    }

    final userEmail = currentUser.email;
    if (userEmail == null) {
      setState(() {
        _userName = 'User email is not available';
      });
      return; // Exit if email is null
    }

    try {
      // Query Firestore for a document where the 'Email' field matches the user's email
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('provider')
          .where('Email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _userName = 'No matching user found in Firestore';
        });
      } else {
        Map<String, dynamic> userData = snapshot.docs.first.data();
        String? name = userData['FirstName'] as String?;
        if (name == null) {
          setState(() {
            _userName = 'Name field is missing in Firestore document';
          });
        } else {
          setState(() {
            _userName = name;
          });
        }
      }
    } catch (e) {
      setState(() {
        _userName = 'Failed to fetch user data: $e';
      });
      print(e); // Print the error to the console for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Provider Home",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.heading,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.message_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => chatprovider())),
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => notificationprovider())),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Container(
            //   height: 100, // Example fixed height
            //   child: WidgetThatNeedsHeight(
            //
            //   ),// Any child widget that needs a defined size
            // ),
            greetingSection(),
            earningsSection(),
            customButtonSection(),
            monthlyRevenueChart(),
            upcomingBookings(),
            servicesList(),
          ],
        ),
      ),
    );
  }

  Widget greetingSection() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 195.0),
            child: Text("Hello,$_userName ",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading)),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(right: 215.0),
            child: Text("Welcome back!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.grey,
                  fontWeight: FontWeight.bold,
                )),
          ),
          SizedBox(height: 5),
        ],
      );

  Widget earningsSection() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 78.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: Colors.black, size: 28),
            Text("Today's Earning:",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.heading)),
            Text("\$0.00",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: AppColors.grey)),
          ],
        ),
      );

  Widget customButtonSection() => Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              uihelper.CustomButton(() {}, "Booking", 50, 170),
              uihelper.CustomButton(() {}, "Total Services", 50, 170)
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              uihelper.CustomButton(() {}, "Monthly Earning", 50, 180),
              uihelper.CustomButton(() {}, "Wallet History", 50, 170)
            ],
          ),
          SizedBox(height: 20),
        ],
      );

  Widget monthlyRevenueChart() => Column(
        children: [
          Text("Monthly Revenue",
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading)),
          SizedBox(height: 15),
          Center(
            child: Container(
              width: 350,
              height: 210,
              child: LineChart(LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: true)),
                ),
                borderData: FlBorderData(
                    show: true, border: Border.all(color: Colors.black)),
                lineBarsData: [
                  LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 4),
                        FlSpot(2, 2),
                        FlSpot(3, 5),
                        FlSpot(4, 1)
                      ],
                      isCurved: false,
                      color: Colors.cyan,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: true))
                ],
              )),
            ),
          ),
          SizedBox(height: 20),
        ],
      );

  Widget upcomingBookings() => Column(
        children: [
          Text("Upcoming Booking",
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading)),
          SizedBox(height: 15),
          Container(
            width: 310,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1)),
            child: Column(
              children: [
                Card(child: ListTile(title: Text("Booking 1"))),
                Card(child: ListTile(title: Text("Booking 2"))),
                Card(child: ListTile(title: Text("Booking 3")))
              ],
            ),
          ),
          SizedBox(height: 15),
        ],
      );

  Widget servicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Services",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                  // Rich purple color for headings
                  fontSize: 18,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceScreenWidget(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                    // Soft teal for interactive elements
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Padding(
          // Additional padding for overall grid spacing
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          // Adjust the horizontal padding
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('service')
                .where('providerId', isEqualTo: currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text("No Data Available"));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.docs.length < 4
                    ? snapshot.data!.docs.length
                    : 4,
                // Show only top 4 services
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ServiceDetailScreen(service: doc),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      // Adjusted for individual card margin
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey[100]!.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                doc['ImageUrl'] ?? 'default_image_url',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    // Lighter gradient for text emphasis
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  doc['Category'] ?? 'No category',
                                  style: TextStyle(
                                    color: Colors.amber[200],
                                    // Bright amber for categories
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc['ServiceName'] ?? 'No name',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "\$" +
                                          (doc['Price']?.toString() ??
                                              'No Price'),
                                      style: TextStyle(
                                        color: Colors.lightGreenAccent[400],
                                        // Light green accent for pricing
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),

                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
