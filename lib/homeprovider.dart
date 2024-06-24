import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servtol/NotificationProvider.dart';
import 'package:servtol/chatprovider.dart';
import 'package:servtol/loginprovider.dart';
import 'package:servtol/servicescreenprovider.dart';
import 'package:servtol/util/AppColors.dart';
import 'package:servtol/util/uihelper.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeProvider extends StatefulWidget {
  const HomeProvider({super.key});

  @override
  State<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends State<HomeProvider> {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginprovider()),
      );
    });
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => chatprovider()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => notificationprovider()),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 195.0),
                  child: Text(
                    "Hello, Awais Khan",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(right: 215.0),
                  child: Text(
                    "Welcome back!",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 18.0),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 58.0),
                    child: Text(
                      "Today's Earning",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                      ),
                    ),
                  ),
                  Text(
                    "\$0.00",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Column(
              children: [
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
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Monthly Revenue",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Container(
                width: 350, // Adjust width as needed
                height: 210, // Adjust height as needed
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 3),
                          FlSpot(1, 4),
                          FlSpot(2, 2),
                          FlSpot(3, 5),
                          FlSpot(4, 1),
                        ],
                        isCurved: false,
                        color: Colors.cyan,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Upcoming Booking",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AppColors.heading,
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: 310,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Card(child: ListTile(title: Text("Booking 1"))),
                  Card(child: ListTile(title: Text("Booking 2"))),
                  Card(child: ListTile(title: Text("Booking 3"))),
                ],
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,

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
                      color: Colors.blue,
                      // fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Container(
              width: 310,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 140,
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Service 1"),
                        )),
                      ),
                      Container(
                        width: 140,
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Service 2"),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 140,
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Service 3"),
                        )),
                      ),
                      Container(
                        width: 140,
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Service 4"),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
